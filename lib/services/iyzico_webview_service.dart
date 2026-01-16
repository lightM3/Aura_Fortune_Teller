import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/package.dart';

class IyzicoWebViewService {
  // Iyzico Sandbox Test Anahtarları (geçici)
  static const String _baseUrl = 'https://sandbox-api.iyzico.com/v2';
  static const String _apiKey = 'sandbox-YourApiKey'; // Burası güncellenecek
  static const String _secretKey =
      'sandbox-YourSecretKey'; // Burası güncellenecek

  // Iyzico ödeme sayfasını WebView'de göster
  static Future<bool> showPaymentPage({
    required BuildContext context,
    required String userId,
    required String userEmail,
    required String userName,
    required Package package,
  }) async {
    try {
      // Ödeme formunu başlat
      final paymentResult = await _initializePayment(
        userId: userId,
        userEmail: userEmail,
        userName: userName,
        package: package,
      );

      if (!paymentResult['success']) {
        _showErrorDialog(
          context,
          paymentResult['error'] ?? 'Ödeme başlatılamadı',
        );
        return false;
      }

      // WebView'de ödeme sayfasını göster
      final paymentSuccess = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => IyzicoPaymentWebView(
            paymentPageUrl: paymentResult['paymentPageUrl'],
            token: paymentResult['token'],
          ),
        ),
      );

      return paymentSuccess ?? false;
    } catch (e) {
      _showErrorDialog(context, 'Ödeme sırasında hata oluştu: $e');
      return false;
    }
  }

  // Ödeme formunu başlat
  static Future<Map<String, dynamic>> _initializePayment({
    required String userId,
    required String userEmail,
    required String userName,
    required Package package,
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
        'callbackUrl': 'https://httpbin.org/post', // Test callback
        'enabledInstallments': [1, 2, 3, 6, 9],
        'buyer': {
          'id': userId,
          'name': userName.split(' ').first,
          'surname': userName.split(' ').length > 1
              ? userName.split(' ').last
              : '',
          'email': userEmail,
          'gsmNumber': '+905555555555',
          'identityNumber': '12345678901',
          'registrationAddress': 'N/A',
          'ip': '85.34.78.112',
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
          'error': 'API hatası: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'İstek hatası: $e'};
    }
  }

  // Authorization header oluştur
  static String _getAuthorization() {
    // Iyzico HMAC SHA256 signature
    // Bu kısım Iyzico dökümanına göre güncellenmeli
    return 'IYZWS $_apiKey:$_secretKey';
  }

  // Hata dialog'u göster
  static void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ödeme Hatası'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }
}

// WebView ödeme sayfası
class IyzicoPaymentWebView extends StatefulWidget {
  final String paymentPageUrl;
  final String token;

  const IyzicoPaymentWebView({
    super.key,
    required this.paymentPageUrl,
    required this.token,
  });

  @override
  State<IyzicoPaymentWebView> createState() => _IyzicoPaymentWebViewState();
}

class _IyzicoPaymentWebViewState extends State<IyzicoPaymentWebView> {
  late WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Loading progress
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            // Ödeme başarılı veya başarısız sayfalarını kontrol et
            if (request.url.contains('success') ||
                request.url.contains('payment-success')) {
              Navigator.pop(context, true);
              return NavigationDecision.prevent;
            } else if (request.url.contains('fail') ||
                request.url.contains('payment-fail')) {
              Navigator.pop(context, false);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentPageUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Iyzico Ödeme'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context, false),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
