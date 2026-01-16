import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/package.dart';

class IyzicoService {
  static const String _baseUrl = 'https://sandbox-api.iyzico.com/v2';
  // Iyzico Sandbox Test Anahtarları
  static const String _apiKey = 'sandbox-YOUR_API_KEY'; // Sandbox anahtarı
  static const String _secretKey = 'sandbox-YOUR_SECRET_KEY'; // Sandbox secret

  // Ödeme başlat
  Future<Map<String, dynamic>> createPayment({
    required String userId,
    required String userEmail,
    required String userName,
    required Package package,
    required String callbackUrl,
  }) async {
    try {
      final paymentData = {
        'locale': 'tr',
        'conversationId': 'payment_${DateTime.now().millisecondsSinceEpoch}',
        'price': (package.price * 100).toInt(), // Kuruş cinsinden
        'paidPrice': (package.price * 100).toInt(),
        'currency': 'TRY',
        'basketId':
            'basket_${package.id}_${DateTime.now().millisecondsSinceEpoch}',
        'paymentGroup': 'PRODUCT',
        'callbackUrl': callbackUrl,
        'enabledInstallments': [1, 2, 3, 6, 9], // Taksit seçenekleri
        'buyer': {
          'id': userId,
          'name': userName.split(' ').first,
          'surname': userName.split(' ').length > 1
              ? userName.split(' ').last
              : '',
          'email': userEmail,
          'gsmNumber': '+905555555555', // Opsiyonel
          'identityNumber': '12345678901', // Opsiyonel
          'registrationAddress': 'N/A',
          'ip': '85.34.78.112', // Kullanıcı IP'si
          'city': 'Istanbul',
          'country': 'Turkey',
          'zipCode': '34000',
        },
        'shippingAddress': {
          'contactName': userName,
          'city': 'Istanbul',
          'country': 'Turkey',
          'address': 'N/A',
          'zipCode': '34000',
        },
        'billingAddress': {
          'contactName': userName,
          'city': 'Istanbul',
          'country': 'Turkey',
          'address': 'N/A',
          'zipCode': '34000',
        },
        'basketItems': [
          {
            'id': package.id,
            'name': package.name,
            'category': 'DIGITAL_GOODS',
            'price': (package.price * 100).toInt(),
            'itemType': 'VIRTUAL',
          },
        ],
      };

      final response = await http.post(
        Uri.parse(
          '$_baseUrl/payment/iyzipos/checkoutform/initialize/auth/ecom',
        ),
        headers: {
          'Authorization': _getAuthorization(),
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(paymentData),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 'success') {
          return {
            'success': true,
            'paymentPageUrl': data['checkoutFormContent'],
            'token': data['token'],
          };
        } else {
          return {
            'success': false,
            'error': data['errorMessage'] ?? 'Ödeme başlatılamadı',
          };
        }
      } else {
        return {
          'success': false,
          'error': 'Iyzico API hatası: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Ödeme işlemi hatası: $e'};
    }
  }

  // Ödeme durumunu kontrol et
  Future<Map<String, dynamic>> checkPaymentStatus(String token) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/payment/iyzipos/checkoutform/auth/ecom/detail?token=$token',
        ),
        headers: {
          'Authorization': _getAuthorization(),
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return {
          'success': true,
          'status': data['paymentStatus'],
          'paidPrice': data['paidPrice'],
          'currency': data['currency'],
          'paymentId': data['paymentId'],
        };
      } else {
        return {'success': false, 'error': 'Ödeme durumu kontrol edilemedi'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Ödeme durumu kontrol hatası: $e'};
    }
  }

  // Authorization header oluştur
  String _getAuthorization() {
    // Iyzico API key ve secret key ile Basic Auth
    final credentials = '$_apiKey:$_secretKey';
    final encodedCredentials = base64Encode(utf8.encode(credentials));
    return 'Basic $encodedCredentials';
  }

  // Test modu kontrolü
  bool get isTestMode => _apiKey.startsWith('sandbox_');

  // Desteklenen taksit seçenekleri
  List<int> get supportedInstallments => [1, 2, 3, 6, 9];

  // Komisyon oranı (genellikle %2-3 arası)
  double get commissionRate => 0.025; // %2.5

  // Komisyon hesapla
  double calculateCommission(double amount) {
    return amount * commissionRate;
  }

  // Net tutar (komisyon düşüldükten sonra)
  double calculateNetAmount(double amount) {
    return amount - calculateCommission(amount);
  }
}
