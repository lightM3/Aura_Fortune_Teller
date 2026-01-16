enum ZodiacSign {
  aries('Koç', '♈', 21, 3, 19, 4),
  taurus('Boğa', '♉', 20, 4, 20, 5),
  gemini('İkizler', '♊', 21, 5, 20, 6),
  cancer('Yengeç', '♋', 21, 6, 22, 7),
  leo('Aslan', '♌', 23, 7, 22, 8),
  virgo('Başak', '♍', 23, 8, 22, 9),
  libra('Terazi', '♎', 23, 9, 22, 10),
  scorpio('Akrep', '♏', 23, 10, 21, 11),
  sagittarius('Yay', '♐', 22, 11, 21, 12),
  capricorn('Oğlak', '♑', 22, 12, 19, 1),
  aquarius('Kova', '♒', 20, 1, 18, 2),
  pisces('Balık', '♓', 19, 2, 20, 3);

  const ZodiacSign(
    this.turkishName,
    this.symbol,
    this.day,
    this.month,
    this.endDay,
    this.endMonth,
  );

  final String turkishName;
  final String symbol;
  final int day;
  final int month;
  final int endDay;
  final int endMonth;

  static ZodiacSign getSignFromDate(DateTime date) {
    final day = date.day;
    final month = date.month;

    for (ZodiacSign sign in ZodiacSign.values) {
      if ((month == sign.month && day >= sign.day) ||
          (month == sign.endMonth && day <= sign.endDay)) {
        return sign;
      }
    }

    return ZodiacSign.capricorn; // Default
  }
}

class Horoscope {
  final ZodiacSign sign;
  final String dailyCommentary;
  final String weeklyCommentary;
  final DateTime createdAt;

  Horoscope({
    required this.sign,
    required this.dailyCommentary,
    required this.weeklyCommentary,
    required this.createdAt,
  });

  factory Horoscope.fromJson(Map<String, dynamic> json) {
    return Horoscope(
      sign: ZodiacSign.values.firstWhere(
        (sign) => sign.turkishName == json['sign'],
        orElse: () => ZodiacSign.aries,
      ),
      dailyCommentary: json['daily_commentary'] ?? '',
      weeklyCommentary: json['weekly_commentary'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
