# Firestore Indexes

## Gerekli Indexler

### 1. Son Ödemeler İçin Index
Admin panelindeki "Son Ödemeler" bölümü için bu index oluşturulmalı:

**Koleksiyon:** `payments`
**Alanlar:** 
- `status` (Ascending)
- `createdAt` (Descending)
- `__name__` (Descending)

**Oluşturma Linki:**
https://console.firebase.google.com/v1/r/project/aurafortune-ed3e7/firestore/indexes?create_composite=ClJwcm9qZWN0cy9hdXJhZm9ydHVuZS1lZDNlNy9kYXRhYmFzZXMvKGRlZmF1bHQpL2NvbGxlY3Rpb25Hcm91cHMvcGF5bWVudHMvaW5kZXhlcy9fEAEaCgoGc3RhdHVzEAEaDQoJY3JlYXRlZEF0EAIaDAoIX19uYW1lX18QAg

## Manuel Oluşturma Adımları

1. Firebase Console'u açın
2. Projenizi seçin: `aurafortune-ed3e7`
3. Firestore Database'e gidin
4. Sol menüden "Indexes" seçeneğine tıklayın
5. "Create index" butonuna tıklayın
6. Aşağıdaki ayarları yapın:
   - **Collection ID:** `payments`
   - **Field 1:** `status` (Ascending)
   - **Field 2:** `createdAt` (Descending)
   - **Field 3:** `__name__` (Descending)
7. "Create" butonuna tıklayın

## Diğer Gerekli Indexler

### 2. Kullanıcı Kredi Sıralaması
**Koleksiyon:** `users`
**Alanlar:**
- `creditBalance` (Descending)

### 3. Fal Tarih Sıralaması
**Koleksiyon:** `fortunes`
**Alanlar:**
- `createdAt` (Descending)

## Index Oluşturma Sonrası

Index oluşturulduktan sonra (genellikle 1-2 dakika sürer):
1. Uygulamayı yeniden başlatın
2. Admin panelini kontrol edin
3. "Son Ödemeler" bölümünün çalıştığını doğrulayın

## Not

- Index oluşturma işlemi 1-2 dakika sürebilir
- Index hazır olana kadar sorgu hatası almaya devam edebilirsiniz
- Bu normal bir durumdur, endişelenmeyin
