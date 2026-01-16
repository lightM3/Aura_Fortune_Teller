import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class PerformanceService {
  static final PerformanceService _instance = PerformanceService._internal();
  factory PerformanceService() => _instance;
  PerformanceService._internal();

  // Cache for frequently accessed data
  final Map<String, dynamic> _memoryCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};

  // Performance metrics
  final Map<String, List<int>> _performanceMetrics = {};

  // Cache duration (5 minutes)
  static const Duration _cacheDuration = Duration(minutes: 5);

  // Memory cache'e veri kaydet
  void cacheData(String key, dynamic data) {
    _memoryCache[key] = data;
    _cacheTimestamps[key] = DateTime.now();

    // Cache boyutunu kontrol et
    _checkCacheSize();
  }

  // Memory cache'den veri getir
  T? getCachedData<T>(String key) {
    final timestamp = _cacheTimestamps[key];
    if (timestamp == null) {
      return null;
    }

    // Cache süresi geçmişse temizle
    if (DateTime.now().difference(timestamp) > _cacheDuration) {
      _memoryCache.remove(key);
      _cacheTimestamps.remove(key);
      return null;
    }

    return _memoryCache[key] as T?;
  }

  // Cache'i temizle
  void clearCache() {
    _memoryCache.clear();
    _cacheTimestamps.clear();
    print('Memory cache cleared');
  }

  // Cache boyutunu kontrol et ve temizle
  void _checkCacheSize() {
    if (_memoryCache.length > 100) {
      // 100 item'dan fazlaysa temizle
      // En eski 50 item'ı temizle
      final sortedEntries = _cacheTimestamps.entries.toList()
        ..sort((a, b) => a.value.compareTo(b.value));

      for (int i = 0; i < 50 && i < sortedEntries.length; i++) {
        final key = sortedEntries[i].key;
        _memoryCache.remove(key);
        _cacheTimestamps.remove(key);
      }

      print('Cache cleaned: removed 50 oldest items');
    }
  }

  // Performans metriği kaydet
  void recordMetric(String operation, int durationMs) {
    if (!_performanceMetrics.containsKey(operation)) {
      _performanceMetrics[operation] = [];
    }

    _performanceMetrics[operation]!.add(durationMs);

    // Son 100 ölçümü tut
    if (_performanceMetrics[operation]!.length > 100) {
      _performanceMetrics[operation]!.removeAt(0);
    }
  }

  // Performans istatistikleri getir
  Map<String, Map<String, double>> getPerformanceStats() {
    final stats = <String, Map<String, double>>{};

    for (final entry in _performanceMetrics.entries) {
      final operation = entry.key;
      final durations = entry.value;

      if (durations.isEmpty) continue;

      durations.sort();

      stats[operation] = {
        'avg': durations.reduce((a, b) => a + b) / durations.length,
        'min': durations.first.toDouble(),
        'max': durations.last.toDouble(),
        'p50': durations[(durations.length * 0.5).floor()].toDouble(),
        'p95': durations[(durations.length * 0.95).floor()].toDouble(),
        'p99': durations[(durations.length * 0.99).floor()].toDouble(),
      };
    }

    return stats;
  }

  // Async işlemi ölç
  Future<T> measureAsyncOperation<T>(
    String operationName,
    Future<T> Function() operation,
  ) async {
    final stopwatch = Stopwatch()..start();

    try {
      final result = await operation();
      stopwatch.stop();

      recordMetric(operationName, stopwatch.elapsedMilliseconds);
      return result;
    } catch (e) {
      stopwatch.stop();
      recordMetric('${operationName}_error', stopwatch.elapsedMilliseconds);
      rethrow;
    }
  }

  // Sync işlemi ölç
  T measureSyncOperation<T>(String operationName, T Function() operation) {
    final stopwatch = Stopwatch()..start();

    try {
      final result = operation();
      stopwatch.stop();

      recordMetric(operationName, stopwatch.elapsedMilliseconds);
      return result;
    } catch (e) {
      stopwatch.stop();
      recordMetric('${operationName}_error', stopwatch.elapsedMilliseconds);
      rethrow;
    }
  }

  // Battery optimizasyonu
  Future<bool> isBatteryOptimized() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastOptimizationCheck = prefs.getString('last_battery_check');
      final now = DateTime.now();

      // Her saat kontrol et
      if (lastOptimizationCheck != null) {
        final lastCheck = DateTime.parse(lastOptimizationCheck);
        if (now.difference(lastCheck).inHours < 1) {
          return prefs.getBool('battery_optimized') ?? false;
        }
      }

      // Basit battery kontrolü
      final isOptimized = await _checkBatteryOptimization();

      await prefs.setString('last_battery_check', now.toIso8601String());
      await prefs.setBool('battery_optimized', isOptimized);

      return isOptimized;
    } catch (e) {
      print('Error checking battery optimization: $e');
      return false;
    }
  }

  Future<bool> _checkBatteryOptimization() async {
    // Basit kontroller
    final cacheSize = _memoryCache.length;
    final metricsCount = _performanceMetrics.length;

    // Cache çok büyükse veya metrikler çoksa optimize et
    if (cacheSize > 50 || metricsCount > 20) {
      await optimizePerformance();
      return true;
    }

    return false;
  }

  // Performans optimizasyonu
  Future<void> optimizePerformance() async {
    // Cache'i temizle
    clearCache();

    // Eski performans metriklerini temizle
    final cutoff = DateTime.now().subtract(const Duration(hours: 1));

    for (final entry in _performanceMetrics.entries) {
      entry.value.removeWhere(
        (duration) =>
            DateTime.now()
                .difference(DateTime.fromMillisecondsSinceEpoch(duration))
                .inHours >
            1,
      );

      if (entry.value.isEmpty) {
        _performanceMetrics.remove(entry.key);
      }
    }

    print('Performance optimization completed');
  }

  // Network optimizasyonu
  Future<bool> isNetworkOptimal() async {
    try {
      final connectivity = await Connectivity().checkConnectivity();

      switch (connectivity) {
        case ConnectivityResult.wifi:
          return true;
        case ConnectivityResult.mobile:
          return false; // Mobile için optimizasyon yapılabilir
        case ConnectivityResult.none:
          return false;
        default:
          return false;
      }
    } catch (e) {
      print('Error checking network: $e');
      return false;
    }
  }

  // Network optimizasyonu önerileri
  List<String> getNetworkOptimizationTips() {
    return [
      'Wi-Fi kullanın (daha hızlı ve daha az pil tüketir)',
      'Uygulamayı arka planda çalıştırmayın',
      'Gereksiz veri indirmelerinden kaçının',
      'Resim kalitesini düşürün',
      'Otomatik senkronizasyonu kapatın',
    ];
  }

  // Memory kullanımını kontrol et
  Map<String, dynamic> getMemoryUsage() {
    return {
      'cache_size': _memoryCache.length,
      'cache_timestamps': _cacheTimestamps.length,
      'performance_metrics': _performanceMetrics.length,
      'estimated_memory_mb': (_memoryCache.length * 0.1).toStringAsFixed(
        2,
      ), // Tahmini
    };
  }

  // Uygulama performans raporu
  Future<Map<String, dynamic>> generatePerformanceReport() async {
    final stats = getPerformanceStats();
    final memoryUsage = getMemoryUsage();
    final batteryOptimized = await isBatteryOptimized();
    final networkOptimal = await isNetworkOptimal();

    return {
      'timestamp': DateTime.now().toIso8601String(),
      'memory_usage': memoryUsage,
      'battery_optimized': batteryOptimized,
      'network_optimal': networkOptimal,
      'performance_stats': stats,
      'recommendations': _getRecommendations(
        stats,
        batteryOptimized,
        networkOptimal,
      ),
    };
  }

  List<String> _getRecommendations(
    Map<String, Map<String, double>> stats,
    bool batteryOptimized,
    bool networkOptimal,
  ) {
    final recommendations = <String>[];

    // Yavaş işlemleri kontrol et
    for (final entry in stats.entries) {
      final operation = entry.key;
      final avgTime = entry.value['avg'] ?? 0;

      if (avgTime > 1000) {
        // 1 saniyeden yavaş
        recommendations.add(
          '$operation işlemi yavaş (${avgTime.toStringAsFixed(0)}ms)',
        );
      }
    }

    if (!batteryOptimized) {
      recommendations.add('Battery optimizasyonu yapın');
    }

    if (!networkOptimal) {
      recommendations.add('Wi-Fi bağlantısı kullanın');
    }

    final cacheSize = _memoryCache.length;
    if (cacheSize > 50) {
      recommendations.add('Cache temizleyin (${cacheSize} items)');
    }

    return recommendations;
  }

  // Widget performansını optimize et
  Widget optimizeWidget({
    required Widget child,
    String? cacheKey,
    Duration? cacheDuration,
  }) {
    if (cacheKey != null) {
      final cachedWidget = getCachedData<Widget>(cacheKey);
      if (cachedWidget != null) {
        return cachedWidget;
      }

      final widget = child;
      cacheData(cacheKey, widget);
      return widget;
    }

    return child;
  }

  // Image optimizasyonu
  String optimizeImageUrl(String url, {int maxWidth = 800, int quality = 80}) {
    // Basit URL optimizasyonu (gerçek uygulamada image service kullanılır)
    if (url.contains('?')) {
      return '$url&maxWidth=$maxWidth&quality=$quality';
    } else {
      return '$url?maxWidth=$maxWidth&quality=$quality';
    }
  }

  // Lazy loading için placeholder
  Widget buildPlaceholder({
    required Widget child,
    Duration delay = const Duration(milliseconds: 100),
  }) {
    return FutureBuilder<void>(
      future: Future.delayed(delay),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return child;
        }
        return Container(
          color: Colors.grey.withOpacity(0.1),
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
            ),
          ),
        );
      },
    );
  }
}
