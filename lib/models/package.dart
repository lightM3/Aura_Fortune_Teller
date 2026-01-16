import 'package:cloud_firestore/cloud_firestore.dart';

enum PackageType { small, medium, large }

class Package {
  final String id;
  final PackageType type;
  final String name;
  final String description;
  final int creditCount;
  final double price;
  final String currency;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Package({
    required this.id,
    required this.type,
    required this.name,
    required this.description,
    required this.creditCount,
    required this.price,
    this.currency = 'TRY',
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  // Firestore'dan veri okurken kullanılacak factory
  factory Package.fromFirestore(String id, Map<String, dynamic> data) {
    return Package(
      id: id,
      type: _stringToPackageType(data['type'] ?? 'small'),
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      creditCount: data['creditCount'] ?? 0,
      price: (data['price'] ?? 0.0).toDouble(),
      currency: data['currency'] ?? 'TRY',
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  // Firestore'a veri yazarken kullanılacak method
  Map<String, dynamic> toFirestore() {
    return {
      'type': _packageTypeToString(type),
      'name': name,
      'description': description,
      'creditCount': creditCount,
      'price': price,
      'currency': currency,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  // PackageType enum'ını string'e çevir
  static String _packageTypeToString(PackageType type) {
    switch (type) {
      case PackageType.small:
        return 'small';
      case PackageType.medium:
        return 'medium';
      case PackageType.large:
        return 'large';
    }
  }

  // String'i PackageType enum'ına çevir
  static PackageType _stringToPackageType(String type) {
    switch (type) {
      case 'small':
        return PackageType.small;
      case 'medium':
        return PackageType.medium;
      case 'large':
        return PackageType.large;
      default:
        return PackageType.small;
    }
  }

  // Kopyalama methodu
  Package copyWith({
    String? id,
    PackageType? type,
    String? name,
    String? description,
    int? creditCount,
    double? price,
    String? currency,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Package(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      description: description ?? this.description,
      creditCount: creditCount ?? this.creditCount,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Fiyatı formatlı göster
  String get formattedPrice {
    return '${price.toStringAsFixed(2)} $currency';
  }

  // Kredi sayısını formatlı göster
  String get formattedCreditCount {
    return '$creditCount Fal';
  }

  // Varsayılan paketler
  static List<Package> getDefaultPackages() {
    final now = DateTime.now();
    return [
      Package(
        id: 'package_small',
        type: PackageType.small,
        name: 'Başlangıç Paketi',
        description: '3 fal hakkı ile fal dünyasına adım atın',
        creditCount: 3,
        price: 100.0,
        createdAt: now,
      ),
      Package(
        id: 'package_medium',
        type: PackageType.medium,
        name: 'Popüler Paket',
        description: '5 fal hakkı ile daha fazla fal gönderin',
        creditCount: 5,
        price: 150.0,
        createdAt: now,
      ),
      Package(
        id: 'package_large',
        type: PackageType.large,
        name: 'Premium Paket',
        description: '10 fal hakkı ile sınırsız fal deneyimi',
        creditCount: 10,
        price: 250.0,
        createdAt: now,
      ),
    ];
  }
}
