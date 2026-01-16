# Iyzico Sandbox Test Anahtarları

## Sorun
Iyzico ödemesi çalışmıyor çünkü gerçek API anahtarları yerine test anahtarları gerekiyor.

## Çözüm

### 1. Iyzico Sandbox Hesabı Oluşturun
1. [Iyzico Sandbox](https://sandbox-iyzico.com/) sitesine gidin
2. "Hemen Başla" butonuna tıklayın
3. Kayıt olun veya giriş yapın
4. Yeni bir proje oluşturun

### 2. API Anahtarlarını Alın
Proje oluşturduktan sonra:
- **API Key:** Proje ayarlarından alın
- **Secret Key:** Proje ayarlarından alın
- Bu anahtarlar sandbox için geçerlidir

### 3. Anahtarları Güncelleyin
`lib/services/iyzico_service.dart` dosyasında şu satırları güncelleyin:

```dart
static const String _apiKey = 'sandbox-SİZİN_API_KEY';
static const String _secretKey = 'sandbox-SİZİN_SECRET_KEY';
```

### 4. Test Kartları
Sandbox test için şu kartları kullanabilirsiniz:

**Başarılı Ödemeler:**
- Kart No: 4242424242424242
- SKT: 12/24
- CVC: 000
- Kart Sahibi: John Doe

**Başarısız Ödemeler:**
- Kart No: 4242424242424241
- SKT: 12/24
- CVC: 000

### 5. Callback URL
Iyzico callback URL için:
- **Development:** `https://your-app-url.com/payment-callback`
- **Test:** `https://httpbin.org/post` (geçici olarak)

### 6. Test Akışı
1. **Test ödemesi seçin** (hızlı test için)
2. **Iyzico seçin** (gerçek ödeme testi için)
3. **Test kartı ile ödeme yapın**
4. **Ödeme başarılı olmalı**

## Geçici Çözüm
Şu an için **"Test Ödemesi"** seçeneğini kullanarak devam edebilirsiniz. Bu seçenek:
- Hızlı çalışır
- Kredi anında yükler
- Test için ideal

## Not
- Iyzico sandbox ücretsizdir
- Gerçek para çekilmez
- Test amaçlı kullanılır
