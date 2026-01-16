import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { user, oracle, admin }

class UserModel {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final UserRole role;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final DateTime? birthDate;
  final int creditBalance;
  final int totalFortunesSent;
  final int totalFortunesReceived;
  final double averageRating;
  final int ratingCount;

  UserModel({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    required this.role,
    required this.createdAt,
    this.lastLoginAt,
    this.birthDate,
    this.creditBalance = 0,
    this.totalFortunesSent = 0,
    this.totalFortunesReceived = 0,
    this.averageRating = 0.0,
    this.ratingCount = 0,
  });

  // Firestore'dan veri çekerken kullanılacak factory constructor
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      photoUrl: data['photoUrl'],
      role: _parseUserRole(data['role']),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLoginAt: (data['lastLoginAt'] as Timestamp?)?.toDate(),
      birthDate: (data['birthDate'] as Timestamp?)?.toDate(),
      creditBalance: data['creditBalance'] ?? 0,
      totalFortunesSent: data['totalFortunesSent'] ?? 0,
      totalFortunesReceived: data['totalFortunesReceived'] ?? 0,
      averageRating: (data['averageRating'] ?? 0.0).toDouble(),
      ratingCount: data['ratingCount'] ?? 0,
    );
  }

  // Firestore'a veri yazarken kullanılacak method
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'role': _userRoleToString(role),
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt': lastLoginAt != null
          ? Timestamp.fromDate(lastLoginAt!)
          : null,
      'birthDate': birthDate != null ? Timestamp.fromDate(birthDate!) : null,
      'creditBalance': creditBalance,
      'totalFortunesSent': totalFortunesSent,
      'totalFortunesReceived': totalFortunesReceived,
      'averageRating': averageRating,
      'ratingCount': ratingCount,
    };
  }

  // UserRole enum'ını string'e çevir
  static String _userRoleToString(UserRole role) {
    switch (role) {
      case UserRole.user:
        return 'user';
      case UserRole.oracle:
        return 'oracle';
      case UserRole.admin:
        return 'admin';
    }
  }

  // String'i UserRole enum'ına çevir
  static UserRole _parseUserRole(String? role) {
    switch (role) {
      case 'oracle':
        return UserRole.oracle;
      case 'admin':
        return UserRole.admin;
      case 'user':
      default:
        return UserRole.user;
    }
  }

  // JSON serialization için toJson methodu
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'role': _userRoleToString(role),
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'birthDate': birthDate?.toIso8601String(),
      'creditBalance': creditBalance,
      'totalFortunesSent': totalFortunesSent,
      'totalFortunesReceived': totalFortunesReceived,
      'averageRating': averageRating,
      'ratingCount': ratingCount,
    };
  }

  // JSON deserialization için fromJson factory constructor
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      displayName: json['displayName'],
      photoUrl: json['photoUrl'],
      role: _parseUserRole(json['role']),
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'])
          : null,
      birthDate: json['birthDate'] != null
          ? DateTime.parse(json['birthDate'])
          : null,
      creditBalance: json['creditBalance'] ?? 0,
      totalFortunesSent: json['totalFortunesSent'] ?? 0,
      totalFortunesReceived: json['totalFortunesReceived'] ?? 0,
      averageRating: (json['averageRating'] ?? 0.0).toDouble(),
      ratingCount: json['ratingCount'] ?? 0,
    );
  }

  // Kopyalama için copyWith methodu
  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    UserRole? role,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    DateTime? birthDate,
    int? creditBalance,
    int? totalFortunesSent,
    int? totalFortunesReceived,
    double? averageRating,
    int? ratingCount,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      birthDate: birthDate ?? this.birthDate,
      creditBalance: creditBalance ?? this.creditBalance,
      totalFortunesSent: totalFortunesSent ?? this.totalFortunesSent,
      totalFortunesReceived:
          totalFortunesReceived ?? this.totalFortunesReceived,
      averageRating: averageRating ?? this.averageRating,
      ratingCount: ratingCount ?? this.ratingCount,
    );
  }

  // Rol kontrolü için helper methodlar
  bool get isUser => role == UserRole.user;
  bool get isOracle => role == UserRole.oracle;
  bool get isAdmin => role == UserRole.admin;

  @override
  String toString() {
    return 'UserModel{id: $id, email: $email, displayName: $displayName, role: $role}';
  }
}
