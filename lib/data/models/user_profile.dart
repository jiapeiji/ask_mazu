// lib/data/models/user_profile.dart
// 用户报家门信息
//
// V1.2 (v5):删除 city 字段(地区)。onboarding 只收昵称,最小首次阻力。

class UserProfile {
  final String name;
  final DateTime createdAt;

  const UserProfile({
    required this.name,
    required this.createdAt,
  });

  UserProfile copyWith({String? name}) {
    return UserProfile(
      name: name ?? this.name,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'createdAt': createdAt.toIso8601String(),
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
