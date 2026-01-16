import 'package:cloud_firestore/cloud_firestore.dart';

enum FortuneType { coffee, tarot, playingCard }

enum FortuneStatus { pending, completed }

class Fortune {
  final String id;
  final String senderId;
  final String? senderName;
  final FortuneType type;
  final List<String> content; // Fotoğraf linkleri veya seçilen kartlar
  final FortuneStatus status;
  final String? response; // Oracle'ın cevabı
  final String? userNote; // Kullanıcının falcıya notu
  final DateTime? createdAt; // Oluşturulma tarihi

  Fortune({
    required this.id,
    required this.senderId,
    this.senderName,
    required this.type,
    required this.content,
    required this.status,
    this.response,
    this.userNote,
    this.createdAt,
  });

  // JSON'dan veri çekerken kullanılacak factory constructor
  factory Fortune.fromJson(Map<String, dynamic> json) {
    return Fortune(
      id: json['id'] ?? '',
      senderId: json['senderId'] ?? '',
      senderName: json['senderName'],
      type: _parseFortuneType(json['type']),
      content: List<String>.from(json['content'] ?? []),
      status: _parseFortuneStatus(json['status']),
      response: json['response'],
      userNote: json['userNote'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }

  // JSON'a çevirirken kullanılacak method
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'type': _fortuneTypeToString(type),
      'content': content,
      'status': _fortuneStatusToString(status),
      'response': response,
      'userNote': userNote,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  // Firestore'dan veri çekerken kullanılacak factory constructor
  factory Fortune.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Fortune(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'],
      type: _parseFortuneType(data['type']),
      content: List<String>.from(data['content'] ?? []),
      status: _parseFortuneStatus(data['status']),
      response: data['response'],
      userNote: data['userNote'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  // Firestore'a veri yazarken kullanılacak method
  Map<String, dynamic> toFirestore() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'type': _fortuneTypeToString(type),
      'content': content,
      'status': _fortuneStatusToString(status),
      'response': response,
      'userNote': userNote,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // FortuneType enum'ını string'e çevir
  static String _fortuneTypeToString(FortuneType type) {
    switch (type) {
      case FortuneType.coffee:
        return 'coffee';
      case FortuneType.tarot:
        return 'tarot';
      case FortuneType.playingCard:
        return 'playing_card';
    }
  }

  // String'i FortuneType enum'ına çevir
  static FortuneType _parseFortuneType(String? type) {
    switch (type) {
      case 'coffee':
        return FortuneType.coffee;
      case 'tarot':
        return FortuneType.tarot;
      case 'playing_card':
        return FortuneType.playingCard;
      default:
        return FortuneType.coffee;
    }
  }

  // FortuneStatus enum'ını string'e çevir
  static String _fortuneStatusToString(FortuneStatus status) {
    switch (status) {
      case FortuneStatus.pending:
        return 'pending';
      case FortuneStatus.completed:
        return 'completed';
    }
  }

  // String'i FortuneStatus enum'ına çevir
  static FortuneStatus _parseFortuneStatus(String? status) {
    switch (status) {
      case 'pending':
        return FortuneStatus.pending;
      case 'completed':
        return FortuneStatus.completed;
      default:
        return FortuneStatus.pending;
    }
  }

  // Kopyalama için copyWith methodu
  Fortune copyWith({
    String? id,
    String? senderId,
    String? senderName,
    FortuneType? type,
    List<String>? content,
    FortuneStatus? status,
    String? response,
    String? userNote,
    DateTime? createdAt,
  }) {
    return Fortune(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      type: type ?? this.type,
      content: content ?? this.content,
      status: status ?? this.status,
      response: response ?? this.response,
      userNote: userNote ?? this.userNote,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Türkçe isimler için helper methodlar
  String get typeDisplayName {
    switch (type) {
      case FortuneType.coffee:
        return 'Kahve Falı';
      case FortuneType.tarot:
        return 'Tarot';
      case FortuneType.playingCard:
        return 'İskambil Falı';
    }
  }

  String get statusDisplayName {
    switch (status) {
      case FortuneStatus.pending:
        return 'Beklemede';
      case FortuneStatus.completed:
        return 'Tamamlandı';
    }
  }
}
