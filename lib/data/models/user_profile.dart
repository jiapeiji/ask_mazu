// lib/data/models/user_profile.dart
// 用户报家门信息

class UserProfile {
  final String name;
  final String city;
  final DateTime createdAt;

  const UserProfile({
    required this.name,
    required this.city,
    required this.createdAt,
  });

  UserProfile copyWith({String? name, String? city}) {
    return UserProfile(
      name: name ?? this.name,
      city: city ?? this.city,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'city': city,
        'createdAt': createdAt.toIso8601String(),
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] as String,
      city: json['city'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
