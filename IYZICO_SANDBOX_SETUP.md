# Iyzico Sandbox Kurulumu

## Hızlı Kurulum (5 Dakika)

### 1. Paketleri Kur
```bash
flutter pub get
```

### 2. Iyzico Sandbox Hesabı
1. [Iyzico Sandbox](https://sandbox-iyzico.com/) gidin
2. "Hemen Başla" butonuna tıklayın
3. E-posta ve şifre ile kayıt olun
4. "Yeni Proje Oluştur" deyin
5. Proje bilgilerini doldurun

### 3. API Anahtarlarını Alın
Proje oluşturduktan sonra:
- **API Key:** Proje ayarlarından kopyalayın
- **Secret Key:** Proje ayarlarından kopyalayın

### 4. Anahtarları Güncelleyin
`lib/services/iyzico_webview_service.dart` dosyasında:

```dart
static const String _apiKey = 'sandbox-SİZİN_API_KEY';
static const String _secretKey = 'sandbox-SİZİN_SECRET_KEY';
```

### 5. Test Kartları
**Başarılı Ödeme:**
- Kart No: 4242424242424242
- SKT: 12/24
- CVC: 000
- Kart Sahibi: John Doe

**Başarısız Ödeme:**
- Kart No: 4242424242424241
- SKT: 12/24
- CVC: 000

## Test Akışı

### Adım 1: Test Ödemesi
1. Uygulamayı açın
2. "Test Ödemesi" seçin
3. Paket seçin
4. "Satın Al" deyin
5. ✅ Kredi anında yüklenir

### Adım 2: Iyzico Gerçek Ödeme
1. "Iyzico" seçin
2. Paket seçin
3. "Satın Al" deyin
4. WebView açılır
5. Test kartı bilgilerini girin
6. ✅ Ödeme başarılı olursa kredi yüklenir

## Özellikler

### WebView Özellikleri
- **Tam ekran:** Iyzico ödeme sayfası
- **Güvenli:** SSL sertifikalı
- **Kontrol:** Başarı/başarısız yönlendirme
- **Kapat:** İptal etme seçeneği

### Ödeme Akışı
1. **Form başlatma:** Iyzico API çağrısı
2. **WebView aç:** Ödeme sayfası göster
3. **Kart bilgileri:** Kullanıcı doldurur
4. **Ödeme onayı:** Iyzico işler
5. **Sonuç dön:** Başarı/başarısız

### Güvenlik
- **Sandbox:** Gerçek para çekilmez
- **Test kartları:** Güvenli test
- **SSL:** Şifreli iletişim
- **Token:** Geçici oturum

## Sorun Giderme

### WebView Çalışmazsa
```bash
flutter clean
flutter pub get
flutter run
```

### API Hatası Alırsanız
1. API anahtarlarını kontrol edin
2. Sandbox URL doğru mu?
3. İnternet bağlantısı var mı?

### Ödeme Başarısız Olursa
1. Test kartı doğru mu?
2. SKT geçerli mi?
3. CVC doğru mu?

## Not
- Sandbox ücretsizdir
- Gerçek para çekilmez
- Test amaçlı kullanılır
- Canlıya geçmek için yeni anahtarlar gerekir
