// lib/data/models/fortune_sign.dart
// 签文数据模型

enum FortuneLevel {
  upperUpper,   // 上上
  upperMid,     // 上中
  midUpper,     // 中上
  mid,          // 中中
  midLower,     // 中下
  lowerUpper,   // 下上
  lowerMid,     // 下中
  lowerLower,   // 下下
}

extension FortuneLevelExtension on FortuneLevel {
  String get label {
    return switch (this) {
      FortuneLevel.upperUpper => '上上',
      FortuneLevel.upperMid => '上中',
      FortuneLevel.midUpper => '中上',
      FortuneLevel.mid => '中中',
      FortuneLevel.midLower => '中下',
      FortuneLevel.lowerUpper => '下上',
      FortuneLevel.lowerMid => '下中',
      FortuneLevel.lowerLower => '下下',
    };
  }

  bool get isLower {
    return this == FortuneLevel.lowerUpper ||
           this == FortuneLevel.lowerMid ||
           this == FortuneLevel.lowerLower;
  }

  bool get isMid {
    return this == FortuneLevel.mid ||
           this == FortuneLevel.midUpper ||
           this == FortuneLevel.midLower;
  }

  bool get isUpper {
    return this == FortuneLevel.upperUpper ||
           this == FortuneLevel.upperMid;
  }
}

enum SignCategory {
  daily,    // 今日运势
  career,   // 事业
  love,     // 感情
  wealth,   // 财运
  health,   // 健康
  family,   // 家庭
  study,    // 学业
  travel,   // 出行
}

extension SignCategoryExtension on SignCategory {
  String get label {
    return switch (this) {
      SignCategory.daily => '今日运势',
      SignCategory.career => '事业',
      SignCategory.love => '感情',
      SignCategory.wealth => '财运',
      SignCategory.health => '健康',
      SignCategory.family => '家庭',
      SignCategory.study => '学业',
      SignCategory.travel => '出行',
    };
  }

  static SignCategory fromString(String s) {
    return SignCategory.values.firstWhere(
      (e) => e.name == s,
      orElse: () => SignCategory.daily,
    );
  }
}

class FortuneSign {
  final int id;
  final FortuneLevel level;
  final String title;
  final String poem;
  final String interpretation;
  final String allusion;
  final List<SignCategory> categories;
  final List<String> modernNotes;

  const FortuneSign({
    required this.id,
    required this.level,
    required this.title,
    required this.poem,
    required this.interpretation,
    required this.allusion,
    required this.categories,
    required this.modernNotes,
  });

  factory FortuneSign.fromJson(Map<String, dynamic> json) {
    return FortuneSign(
      id: json['id'] as int,
      level: FortuneLevel.values.firstWhere(
        (e) => e.label == json['level'],
        orElse: () => FortuneLevel.mid,
      ),
      title: json['title'] as String,
      poem: json['poem'] as String,
      interpretation: json['interpretation'] as String,
      allusion: json['allusion'] as String,
      categories: (json['categories'] as List<dynamic>)
          .map((e) => SignCategoryExtension.fromString(e as String))
          .toList(),
      modernNotes: List<String>.from(json['modernNotes'] as List<dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'level': level.label,
        'title': title,
        'poem': poem,
        'interpretation': interpretation,
        'allusion': allusion,
        'categories': categories.map((e) => e.name).toList(),
        'modernNotes': modernNotes,
      };
}
