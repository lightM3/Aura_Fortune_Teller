class AppConstants {
  // Uygulama bilgileri
  static const String appName = 'Aura';
  static const String appTagline = 'Mistik Fal Deneyimi';

  // Firebase koleksiyon isimleri
  static const String usersCollection = 'users';
  static const String fortunesCollection = 'fortunes';

  // Fal türleri
  static const String coffeeFortune = 'coffee';
  static const String tarotFortune = 'tarot';
  static const String playingCardFortune = 'playing_card';

  // Durumlar
  static const String pendingStatus = 'pending';
  static const String completedStatus = 'completed';

  // Roller
  static const String userRole = 'user';
  static const String oracleRole = 'oracle';

  // Animasyon süreleri
  static const Duration shortAnimationDuration = Duration(milliseconds: 300);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 500);
  static const Duration longAnimationDuration = Duration(milliseconds: 800);

  // UI sabitleri
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 20.0;
  static const double defaultBlur = 10.0;
}
