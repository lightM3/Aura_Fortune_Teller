# Iyzico Kurulum ve Test

## 1. Iyzico Hesabı Oluşturma
1. [Iyzico](https://iyzico.com/) sitesine kaydol
2. "Test (Sandbox)" hesabı oluştur
3. API Key ve Secret Key al

## 2. Flutter Projesinde Ayarlar
1. `pubspec.yaml`'a ekle:
```yaml
dependencies:
  http: ^1.1.0
  crypto: ^3.0.3
```

2. `iyzico_service.dart`'da güncelle:
```dart
static const String _apiKey = 'SANDBOX_API_KEY';
static const String _secretKey = 'SANDBOX_SECRET_KEY';
```

## 3. Test Kartları
**Başarılı Ödemeler:**
- Kart No: 4355084355084358
- SKT: 12
- CVV: 123
- İsim: John Doe

**Başarısız Ödemeler:**
- Kart No: 4355084355084359
- SKT: 12
- CVV: 123

## 4. Test Adımları
1. `paymentMethod: 'iyzico'` olarak değiştir
2. Uygulamayı test et
3. Iyzico ödeme sayfası açılmalı
4. Test kart bilgilerini gir
5. Ödemeyi tamamla

## 5. Canlı Geçiş
Test başarılı olursa:
1. Iyzico'dan canlı hesap talep et
2. Canlı API anahtarlarını al
3. `iyzico_service.dart`'ı güncelle
4. Callback URL'i canlı domaine ayarla
