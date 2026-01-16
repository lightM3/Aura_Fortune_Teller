# Aura Fal - Professional Fortune Telling App

<div align="center">
  <img src="https://img.shields.io/badge/Flutter-3.19+-blue.svg" alt="Flutter Version">
  <img src="https://img.shields.io/badge/Dart-3.3+-blue.svg" alt="Dart Version">
  <img src="https://img.shields.io/badge/Firebase-Cloud-orange.svg" alt="Firebase">
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey.svg" alt="Platform">
  <img src="https://img.shields.io/badge/License-MIT-green.svg" alt="License">
</div>

## 📱 Hakkında

Aura Fal, modern ve profesyonel bir fal uygulamasıdır. Kullanıcıların farklı fal türleriyle online fal baktırmalarını sağlayan, kredi tabanlı bir mobil uygulamadır.

## ✨ Özellikler

### 🎯 Kullanıcı Özellikleri
- **🔐 Güvenli Giriş:** Firebase Authentication ile e-posta/şifre
- **💳 Kredi Sistemi:** Paket bazlı kredi satın alma
- **📸 Çoklu Fal Türleri:** Kahve, Tarot, İskambil falı
- **🎨 Modern UI:** Glassmorphic tasarım ve animasyonlar
- **📱 Responsive:** Tüm ekran boyutlarına uyumlu
- **🔔 Bildirimler:** Push bildirim desteği
- **📶 Offline Mod:** Temel özellikler offline çalışır

### 🎯 Admin Özellikleri
- **📊 Dashboard:** Kapsamlı istatistik paneli
- **👥 Kullanıcı Yönetimi:** Kullanıcıları görüntüleme ve düzenleme
- **💰 Ödeme Takibi:** Tüm ödeme kayıtları
- **📈 Raporlama:** Detaylı satış ve kullanım raporları
- **🎛️ Rol Bazlı Erişim:** Güvenli yetkilendirme

### 💳 Ödeme Sistemi
- **🔄 Gerçek Ödeme:** Iyzico entegrasyonu
- **🧪 Test Modu:** Geliştirme için test ödemeleri
- **📦 Paketler:** Esnek kredi paketleri
- **🔒 Güvenli:** SSL ve güvenli ödeme akışı

## 🛠️ Teknolojiler

- **Frontend:** Flutter 3.19+
- **Backend:** Firebase (Firestore, Authentication, Storage, Messaging)
- **Payment:** Iyzico (Türkiye'nin lider ödeme sistemi)
- **State Management:** Provider
- **UI/UX:** Material Design 3, Glassmorphism
- **Notifications:** Firebase Cloud Messaging + Local Notifications
- **Storage:** Firebase Storage + Local Cache

## 📸 Ekran Görüntüleri

<div align="center">
  <img src="screenshots/home.png" alt="Ana Ekran" width="200">
  <img src="screenshots/fortune.png" alt="Fal Ekranı" width="200">
  <img src="screenshots/admin.png" alt="Admin Paneli" width="200">
  <img src="screenshots/payment.png" alt="Ödeme Ekranı" width="200">
</div>

## 🚀 Kurulum

### Gereksinimler
- Flutter SDK 3.19+
- Dart SDK 3.3+
- Android SDK (Android geliştirme için)
- Xcode (iOS geliştirme için)

### Adımlar
```bash
# Repoyu klonla
git clone https://github.com/kullaniciadi/aura-fal.git
cd aura-fal

# Bağımlılıkları yükle
flutter pub get

# Flutter sürümünü kontrol et
flutter doctor

# Çalıştır
flutter run
```

## 🔧 Yapılandırma

### Firebase Ayarları
1. [Firebase Console](https://console.firebase.google.com/) yeni proje oluştur
2. Android/iOS uygulamaları ekle
3. `google-services.json` (Android) ve `GoogleService-Info.plist` (iOS) dosyalarını ekle
4. Firestore, Authentication, Storage, Cloud Messaging'i etkinleştir

### Iyzico Ayarları
1. [Iyzico Sandbox](https://sandbox-iyzico.com/) hesabı oluştur
2. API anahtarlarını al
3. `lib/services/iyzico_webview_service.dart` dosyasında güncelle:
```dart
static const String _apiKey = 'sandbox-YOUR_API_KEY';
static const String _secretKey = 'sandbox-YOUR_SECRET_KEY';
```

## 📱 Build ve Dağıtım

### Android APK
```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release
```

### iOS IPA
```bash
# Debug IPA
flutter build ios --debug

# Release IPA
flutter build ios --release
```

### Web
```bash
flutter build web
```

## 🧪 Test

### Unit Testler
```bash
flutter test
```

### Widget Testler
```bash
flutter test integration_test/
```

## 📁 Proje Yapısı

```
lib/
├── models/           # Veri modelleri
├── screens/          # Ekranlar
│   ├── auth/        # Giriş/Kayıt ekranları
│   ├── home/        # Ana ekranlar
│   ├── fortune/     # Fal ekranları
│   ├── payment/     # Ödeme ekranları
│   ├── profile/     # Profil ekranları
│   └── admin/       # Admin paneli
├── widgets/         # Özel widget'lar
├── services/        # Servis katmanı
├── providers/       # State management
├── theme/          # Tema ve renkler
└── utils/          # Yardımcı fonksiyonlar
```

## 🔐 Güvenlik

- **🔒 Firebase Authentication:** Güvenli kullanıcı kimlik doğrulama
- **🛡️ SSL/TLS:** Tüm veri transferleri şifreli
- **🔑 API Key Security:** Hassas veriler environment variables'da
- **📱 App Security:** Kod obfuskasyonu ve minify

## 🌐 Dil Desteği

- **🇹🇷 Türkçe** (Ana dil)
- **🇬🇧 İngilizce** (Gelecek plan)

## 📄 Lisans

Bu proje [MIT Lisansı](LICENSE) altında dağıtılmaktadır.

## 🤝 Katkıda Bulunma

Katkılarınızı bekliyoruz! Lütfen aşağıdaki adımları izleyin:

1. Repoyu fork'layın
2. Yeni bir branch oluşturun (`git checkout -b feature/AmazingFeature`)
3. Değişikliklerinizi commit'leyin (`git commit -m 'Add some AmazingFeature'`)
4. Branch'e push'layın (`git push origin feature/AmazingFeature`)
5. Bir Pull Request oluşturun

## 📞 İletişim

- **📧 E-posta:** your-email@example.com
- **🐛 Hata Bildirimi:** [Issues](https://github.com/kullaniciadi/aura-fal/issues)
- **💡 Öneri:** [Discussions](https://github.com/kullaniciadi/aura-fal/discussions)

## 🙏 Teşekkürler

- **Flutter Team** - Harika framework için
- **Firebase Team** - Backend altyapısı için
- **Iyzico Team** - Ödeme sistemi için
- **Flutter Community** - Destek ve ilham için

---

<div align="center">
  <strong>Aura Fal - Geleceğin Fal Uygulaması 🔮✨</strong>
</div>
