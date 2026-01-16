class TarotCard {
  final String name;
  final String imagePath;
  final String description;
  final String meaning;

  TarotCard({
    required this.name,
    required this.imagePath,
    required this.description,
    required this.meaning,
  });
}

class TarotCards {
  static final List<TarotCard> majorArcana = [
    TarotCard(
      name: 'The Fool',
      imagePath: 'assets/tarot/0_fool.png',
      description: 'Başlangıç, masumiyet, serbest ruh',
      meaning: 'Yeni bir başlangıç, macera, bilinmeyene adım atma',
    ),
    TarotCard(
      name: 'The Magician',
      imagePath: 'assets/tarot/1_magician.png',
      description: 'İrade, yetenek, güç',
      meaning: 'Hedeflerinize ulaşmak için gereken tüm araçlara sahipsiniz',
    ),
    TarotCard(
      name: 'The High Priestess',
      imagePath: 'assets/tarot/2_high_priestess.png',
      description: 'Intuisyon, bilinçaltı, gizem',
      meaning: 'İç sesinizi dinleyin, sezgilerinize güvenin',
    ),
    TarotCard(
      name: 'The Empress',
      imagePath: 'assets/tarot/3_empress.png',
      description: 'Yaratıcılık, bereket, doğa',
      meaning: 'Yaratıcı enerji, bereket, yeni projeler',
    ),
    TarotCard(
      name: 'The Emperor',
      imagePath: 'assets/tarot/4_emperor.png',
      description: 'Otorite, yapı, kontrol',
      meaning: 'Liderlik, düzen, sorumluluk',
    ),
    TarotCard(
      name: 'The Hierophant',
      imagePath: 'assets/tarot/5_hierophant.png',
      description: 'Gelenek, öğrenme, inanç',
      meaning: 'Bilgelik, ruhani rehberlik, geleneksel değerler',
    ),
    TarotCard(
      name: 'The Lovers',
      imagePath: 'assets/tarot/6_lovers.png',
      description: 'İlişki, seçim, uyum',
      meaning: 'Aşk, ortaklık, önemli bir karar',
    ),
    TarotCard(
      name: 'The Chariot',
      imagePath: 'assets/tarot/7_chariot.png',
      description: 'Zafer, kontrol, irade',
      meaning: 'Başarı, hedefe doğru ilerleme, öz disiplini',
    ),
    TarotCard(
      name: 'Strength',
      imagePath: 'assets/tarot/8_strength.png',
      description: 'Güç, cesaret, sabır',
      meaning: 'İçsel güç, cesaret, kendine hakimiyet',
    ),
    TarotCard(
      name: 'The Hermit',
      imagePath: 'assets/tarot/9_hermit.png',
      description: 'Yalnızlık, içsel arayış, bilgelik',
      meaning: 'Kendi içine dönme, ruhsal büyüme',
    ),
    TarotCard(
      name: 'Wheel of Fortune',
      imagePath: 'assets/tarot/10_wheel.png',
      description: 'Kader, değişim, şans',
      meaning: 'Hayat döngüsü, beklenmedik değişiklikler',
    ),
    TarotCard(
      name: 'Justice',
      imagePath: 'assets/tarot/11_justice.png',
      description: 'Adalet, denge, hakikat',
      meaning: 'Adil kararlar, sonuçlarla yüzleşme',
    ),
    TarotCard(
      name: 'The Hanged Man',
      imagePath: 'assets/tarot/12_hanged.png',
      description: 'Feda, yeni bakış açısı, teslimiyet',
      meaning: 'Perspektif değişikliği, fedakarlık',
    ),
    TarotCard(
      name: 'Death',
      imagePath: 'assets/tarot/13_death.png',
      description: 'Dönüşüm, sonlanma, yeniden doğuş',
      meaning: 'Eski kapanış, yeni başlangıç, dönüşüm',
    ),
    TarotCard(
      name: 'Temperance',
      imagePath: 'assets/tarot/14_temperance.png',
      description: 'Denge, uyum, sabır',
      meaning: 'Orta yol, denge, iç huzur',
    ),
    TarotCard(
      name: 'The Devil',
      imagePath: 'assets/tarot/15_devil.png',
      description: 'Bağımlılık, kısıtlama, materyalizm',
      meaning: 'Zihinsel kölelik, kötü alışkanlıklar',
    ),
    TarotCard(
      name: 'The Tower',
      imagePath: 'assets/tarot/16_tower.png',
      description: 'Yıkım, değişim, aydınlanma',
      meaning: 'Beklenmedik kriz, gerçeklerin ortaya çıkması',
    ),
    TarotCard(
      name: 'The Star',
      imagePath: 'assets/tarot/17_star.png',
      description: 'Umut, ilham, iyimserlik',
      meaning: 'Ruhsal yenilenme, umut, geleceğe güven',
    ),
    TarotCard(
      name: 'The Moon',
      imagePath: 'assets/tarot/18_moon.png',
      description: 'İllüzyon, korku, bilinçaltı',
      meaning: 'Sezgisel mesajlar, korkularla yüzleşme',
    ),
    TarotCard(
      name: 'The Sun',
      imagePath: 'assets/tarot/19_sun.png',
      description: 'Neşe, başarı, aydınlanma',
      meaning: 'Mutluluk, başarı, netlik',
    ),
    TarotCard(
      name: 'Judgement',
      imagePath: 'assets/tarot/20_judgement.png',
      description: 'Yargılama, yeniden doğuş, affetme',
      meaning: 'İçsel değerlendirme, ruhsal uyanış',
    ),
    TarotCard(
      name: 'The World',
      imagePath: 'assets/tarot/21_world.png',
      description: 'Tamamlanma, başarı, bütünlük',
      meaning: 'Döngünün tamamlanması, başarı, hedefe ulaşma',
    ),
  ];

  static List<TarotCard> getRandomCards(int count) {
    final shuffled = List<TarotCard>.from(majorArcana)..shuffle();
    return shuffled.take(count).toList();
  }
}
