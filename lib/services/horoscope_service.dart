import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/horoscope.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class HoroscopeService {
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta';
  static final String _apiKey = dotenv.env['GEMINI_API_KEY']!;
  static String? _resolvedModelName;

  static const int _maxContinuationTurns = 3;
  static const int _maxOutputTokens = 2048;

  Future<Horoscope?> getDailyHoroscope(ZodiacSign sign) async {
    try {
      final prompt = _buildDailyPrompt(sign);
      final response = await _callGeminiAPI(prompt);

      if (response != null) {
        return Horoscope(
          sign: sign,
          dailyCommentary: response,
          weeklyCommentary: '',
          createdAt: DateTime.now(),
        );
      }
    } catch (e) {
      debugPrint('Horoscope API error: $e');
    }
    return null;
  }

  // Haftalık burç yorumunu getir (Gemini AI ile)
  Future<Horoscope?> getWeeklyHoroscope(ZodiacSign sign) async {
    try {
      final prompt = _buildWeeklyPrompt(sign);
      final response = await _callGeminiAPI(prompt);

      if (response != null) {
        return Horoscope(
          sign: sign,
          dailyCommentary: '',
          weeklyCommentary: response,
          createdAt: DateTime.now(),
        );
      }
    } catch (e) {
      debugPrint('Horoscope API error: $e');
    }
    return null;
  }

  // Gemini API'yi çağır
  Future<String?> _callGeminiAPI(String prompt) async {
    try {
      final modelName = await _getModelName();
      if (modelName == null) {
        debugPrint('ERROR: No suitable Gemini model found.');
        return null;
      }

      String currentPrompt = prompt;
      final buffer = StringBuffer();

      for (var turn = 0; turn < _maxContinuationTurns; turn++) {
        debugPrint('=== GEMINI API CALL START ===');
        debugPrint('Turn: ${turn + 1}/$_maxContinuationTurns');
        final previewLen = currentPrompt.length < 100
            ? currentPrompt.length
            : 100;
        debugPrint('Prompt: ${currentPrompt.substring(0, previewLen)}...');

        final uri = Uri.parse(
          '$_baseUrl/$modelName:generateContent',
        ).replace(queryParameters: {'key': _apiKey});

        debugPrint('Request URI: $uri');

        final response = await http.post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'contents': [
              {
                'parts': [
                  {'text': currentPrompt},
                ],
              },
            ],
            'generationConfig': {
              'temperature': 0.7,
              'topK': 40,
              'topP': 0.95,
              'maxOutputTokens': _maxOutputTokens,
            },
          }),
        );

        debugPrint('Response Status Code: ${response.statusCode}');
        debugPrint('Response Body: ${response.body}');

        if (response.statusCode != 200) {
          debugPrint('ERROR: HTTP ${response.statusCode}');
          return null;
        }

        final data = json.decode(response.body);
        debugPrint('Parsed Data: $data');

        final candidates = data is Map ? data['candidates'] : null;
        if (candidates is! List || candidates.isEmpty) {
          debugPrint('ERROR: No candidates in response');
          return null;
        }

        final first = candidates.first;
        if (first is! Map) {
          debugPrint('ERROR: Invalid candidate');
          return null;
        }

        final content = first['content'];
        final parts = content is Map ? content['parts'] : null;
        String text = '';
        if (parts is List) {
          text = parts
              .whereType<Map>()
              .map((p) => p['text'])
              .whereType<String>()
              .join('');
        }

        final finishReason = first['finishReason'];
        buffer.write(text);
        debugPrint('Gemini Response Text: $text');
        debugPrint('Finish Reason: $finishReason');

        if (finishReason != 'MAX_TOKENS') {
          break;
        }

        final accumulated = buffer.toString();
        final tailLen = accumulated.length < 500 ? accumulated.length : 500;
        final tail = accumulated.substring(accumulated.length - tailLen);
        currentPrompt =
            'Bir önceki burç yorumunu kaldığın yerden devam ettir. Tekrar etme. Son kısım:\n$tail\nDevam:';
      }

      final result = buffer.toString().trim();
      return result.isEmpty ? null : result;
    } catch (e) {
      debugPrint('=== GEMINI API ERROR ===');
      debugPrint('Error: $e');
      debugPrint('Error Type: ${e.runtimeType}');
      if (e is Error) {
        debugPrint('Error Stack: ${e.stackTrace}');
      }
      debugPrint('=== ERROR END ===');
      return null;
    }
  }

  Future<String?> _getModelName() async {
    if (_resolvedModelName != null) {
      return _resolvedModelName;
    }

    final uri = Uri.parse(
      '$_baseUrl/models',
    ).replace(queryParameters: {'key': _apiKey});

    final response = await http.get(uri);
    debugPrint('ListModels Status Code: ${response.statusCode}');

    if (response.statusCode != 200) {
      debugPrint('ListModels Body: ${response.body}');
      return null;
    }

    final data = json.decode(response.body);
    final models = (data['models'] as List?) ?? const [];

    String? pick;

    bool supportsGenerateContent(Map<String, dynamic> m) {
      final methods = (m['supportedGenerationMethods'] as List?) ?? const [];
      return methods.contains('generateContent');
    }

    int score(String name) {
      final n = name.toLowerCase();
      if (n.contains('flash')) return 3;
      if (n.contains('pro')) return 2;
      if (n.contains('gemini')) return 1;
      return 0;
    }

    int bestScore = -1;
    for (final raw in models) {
      if (raw is! Map) continue;
      final m = Map<String, dynamic>.from(raw);
      final name = m['name'];
      if (name is! String) continue;
      if (!supportsGenerateContent(m)) continue;

      final s = score(name);
      if (s > bestScore) {
        bestScore = s;
        pick = name;
      }
    }

    if (pick == null) {
      debugPrint('ListModels: No model supports generateContent.');
      return null;
    }

    _resolvedModelName = pick;
    debugPrint('Resolved Gemini model: $_resolvedModelName');
    return _resolvedModelName;
  }

  // Günlük prompt oluştur
  String _buildDailyPrompt(ZodiacSign sign) {
    final today = DateTime.now();
    final dateStr = '${today.day}/${today.month}/${today.year}';

    return '''Bugün $dateStr tarihi için ${sign.name} burcunun günlük yorumunu yap. 
    Kapsamlı, ilham verici ve pozitif bir ton kullan. 
    Türkçe yaz ve astroloji bilgilerine dayanarak yaz.
    
    Aşağıdaki unsurları dahil et:
    - Enerji seviyesi ve günlük ruh hali
    - İlişkiler ve kariyer için tavsiyeler
    - Finansal konularda dikkat edilmesi gerekenler
    - Sağlık ve duygusal denge önerileri
    - Günün şanslı sayısı ve rengi
    - Uyumlu burçlarla olan etkileşim
    
    Yaklaşık 150-200 kelime arasında olmalı. 
    Samimi, destekleyici ve motivasyon dolu bir dil kullan.''';
  }

  // Haftalık prompt oluştur
  String _buildWeeklyPrompt(ZodiacSign sign) {
    final today = DateTime.now();
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    final weekStr =
        '${weekStart.day}/${weekStart.month} - ${weekEnd.day}/${weekEnd.month}';

    return '''$weekStr tarihleri arasındaki hafta için ${sign.name} burcunun haftalık yorumunu yap.
    Bu haftanın genel enerjisini, fırsatlarını ve zorluklarını analiz et.
    
    Aşağıdaki konulara odaklan:
    - Haftanın genel teması ve enerjisi
    - Kariyer ve iş hayatı gelişmeleri
    - İlişkilerde yaşanabilecek değişimler
    - Finansal beklentiler ve yatırım tavsiyeleri
    - Sağlık ve wellness önerileri
    - Önemli günler ve tutulmaması gerekenler
    - Haftanın şanslı günleri
    
    Haftalık bakış açısı sun, yaklaşık 200-300 kelime.
    Umut verici, gerçekçi ve pratik tavsiyeler içer.
    Türkçe yaz ve astrolojik prensiplere uygun olsun.''';
  }

  // Örnek günlük yorumlar (API çalışmazsa kullanılır)
}
