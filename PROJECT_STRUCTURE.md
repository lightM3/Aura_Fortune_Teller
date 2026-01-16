# Aura - Fal Uygulaması Proje Yapısı

## 📁 Klasör Yapısı

```
lib/
├── models/              # Veri modelleri
│   ├── fortune.dart     # Fortune modeli (id, senderId, type, content, status, response)
│   └── user_model.dart  # Kullanıcı modeli (id, email, role, vb.)
│
├── services/            # Firebase servisleri
│   ├── auth_service.dart    # Kimlik doğrulama servisi
│   └── fortune_service.dart # Fal yönetimi servisi
│
├── screens/             # Uygulama ekranları
│   ├── splash_screen.dart   # Başlangıç ekranı
│   └── auth/
│       └── login_screen.dart # Giriş ekranı
│
├── widgets/             # Yeniden kullanılabilir widget'lar
│   └── glassmorphic_container.dart # Glassmorphism efekti widget'ı
│
├── theme/               # Tema dosyaları
│   └── app_theme.dart   # Deep Purple & Gold tema, Cinzel & Lora fontları
│
└── utils/               # Yardımcı fonksiyonlar
    └── constants.dart   # Sabitler ve konfigürasyonlar
```

## 🎨 Tema Özellikleri

- **Renkler**: Deep Purple ve Gold paleti
- **Fontlar**: 
  - Cinzel (Başlıklar için)
  - Lora (İçerik için)
- **Efektler**: Glassmorphism ve mistik gradientler

## 📦 Kurulu Paketler

- `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`
- `google_fonts`
- `animate_do`
- `glassmorphism`
- `provider` (State management)

## 🔥 Firebase Modeli

### Fortune Collection
```dart
{
  id: String,
  senderId: String,
  type: 'coffee' | 'tarot' | 'playing_card',
  content: List<String>, // Fotoğraf linkleri veya seçilen kartlar
  status: 'pending' | 'completed',
  response: String?, // Oracle'ın cevabı
  createdAt: Timestamp,
  updatedAt: Timestamp
}
```

### Users Collection
```dart
{
  id: String,
  email: String,
  displayName: String?,
  photoUrl: String?,
  role: 'user' | 'oracle',
  createdAt: Timestamp,
  lastLoginAt: Timestamp?
}
```

## 🚀 Sonraki Adımlar

1. Firebase projesini yapılandır
2. Rol yönetimine göre ana sayfa yönlendirmesi ekle
3. User ve Oracle için farklı ekranlar oluştur
4. Fal gönderme ve yanıtlama özelliklerini ekle
