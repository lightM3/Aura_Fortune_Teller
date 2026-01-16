# Aura Fal - GitHub Repository Setup Guide

## 🔐 Paylaşmamanız Gereken Hassas Bilgiler

### ❌ ASLA PAYLAŞMAYIN (Güvenlik Riski!)
- **Firebase Config Dosyaları:**
  - `google-services.json` (Android)
  - `GoogleService-Info.plist` (iOS)
- **API Anahtarları:**
  - Iyzico API keys (production/sandbox)
  - Firebase API keys
- **Database URL'leri:**
  - Firestore database URL
  - Firebase Storage URL

### ✅ Güvenli Alternatifler
```bash
# Environment variables kullanın
export IYZICO_API_KEY="your-api-key"
export IYZICO_SECRET_KEY="your-secret-key"

# Veya .env dosyası (gitignore'da olmalı)
IYZICO_API_KEY=sandbox-your-api-key
IYZICO_SECRET_KEY=sandbox-your-secret-key
```

## 📁 .gitignore Dosyası

```gitignore
# Firebase
google-services.json
GoogleService-Info.plist

# Environment variables
.env
.env.local
.env.production

# API Keys
api_keys.dart
config/secrets.dart

# Flutter
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
.packages
.pub-cache/
.pub-cache/
build/

# IDE
.vscode/
.idea/
*.iml

# OS
.DS_Store
Thumbs.db
```

## 🚀 GitHub'a Yükleme Adımları

### 1. Repository Oluşturma
```bash
# GitHub'da yeni repo oluştur: "aura-fal"
git init
git add .
git commit -m "Initial commit: Aura Fal App"
git branch -M main
git remote add origin https://github.com/kullaniciadi/aura-fal.git
git push -u origin main
```

### 2. Hassas Bilgileri Temizleme
```bash
# Firebase config dosyalarını sil
rm -f android/app/google-services.json
rm -f ios/Runner/GoogleService-Info.plist

# API key dosyalarını sil
rm -f lib/services/api_keys.dart
```

### 3. Yükleme Sonrası Yapılandırma
```bash
# Yeni geliştiriciler için kurulum rehberi
echo "Firebase Console'dan yeni config dosyaları alın"
echo "Iyzico sandbox hesabı oluşturun"
echo "API key'leri güvenli bir şekilde ekleyin"
```

## 📋 Repository Checklist

### ✅ Yapılması Gerekenler
- [ ] README.md güncellendi
- [ ] LICENSE dosyası eklendi
- [ ] .gitignore oluşturuldu
- [ ] Hassas bilgiler çıkarıldı
- [ ] Screenshots klasörü eklendi
- [ ] Tags ve releases hazırlandı

### ⚠️ Güvenlik Kontrolleri
- [ ] API key'ler kontrol edildi
- [ ] Firebase config dosyaları silindi
- [ ] .gitignore çalışıyor
- [ ] Environment variables belgelendi

## 🎯 Repository İçeriği

### 📁 Klasör Yapısı
```
aura-fal/
├── lib/                    # Ana kod
├── android/                # Android kodu
├── ios/                    # iOS kodu
├── web/                    # Web kodu
├── assets/                 # Resimler ve ikonlar
├── screenshots/            # Ekran görüntüleri
├── docs/                   # Dokümantasyon
├── README.md              # Proje açıklaması
├── LICENSE                # Lisans
├── .gitignore            # Göz ardı edilecek dosyalar
└── pubspec.yaml          # Bağımlılıklar
```

### 📝 README.md İçeriği
- ✅ Proje açıklaması
- ✅ Özellik listesi
- ✅ Kurulum adımları
- ✅ Yapılandırma rehberi
- ✅ Build komutları
- ✅ Katkı rehberi
- ✅ Lisans bilgisi

### 🔒 Güvenlik Bilgisi
Tüm hassas bilgiler **environment variables** veya **config dosyaları** ile yönetilmelidir. Asla doğrudan kod içine yazılmamalıdır.

## 🌟 Profesyonel Repository İpuçları

### 📸 Screenshots Ekleme
```bash
mkdir screenshots
# Ekran görüntüleri buraya eklenecek
# - home.png
# - fortune.png  
# - admin.png
# - payment.png
```

### 🏷️ Tags ve Releases
```bash
# Version tag oluştur
git tag -a v1.0.0 -m "First release"
git push origin v1.0.0

# GitHub'da release oluştur
# Title: Aura Fal v1.0.0
# Description: İlk resmi sürüm
# Assets: APK dosyaları
```

### 📊 README Badges
```markdown
![Flutter](https://img.shields.io/badge/Flutter-3.19+-blue)
![Firebase](https://img.shields.io/badge/Firebase-Cloud-orange)
![License](https://img.shields.io/badge/License-MIT-green)
```

## 🚨 ÖNEMLİ UYARILAR

1. **ASLA** gerçek API key'leri GitHub'a yüklemeyin
2. **HER ZAMAN** sandbox ortamında test edin
3. **MUTLAKA** production credentials'ı ayrı tutun
4. **DİKKATLİ** .gitignore dosyasını kontrol edin

---

**🔮 Aura Fal - Güvenli ve Profesyonel GitHub Repository**
