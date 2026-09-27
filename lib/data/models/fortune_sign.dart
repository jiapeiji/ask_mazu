// lib/data/models/fortune_sign.dart
// 签文数据模型
//
// 字段（title/poem/interpretation/allusion/modernNotes）默认存简体中文（zh_CN）。
// 多语言覆盖放在 `i18n: { zh_TW: {...}, en: {...} }`，缺失字段 fallback 到默认（zh_CN）。

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
  /// 中文等级标签（"上上"/"上中"等），UI 一般会再拼"签"字
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
  general,  // 通用（仅用于签文分类，UI 不显示；custom 模式抽签池）
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
      SignCategory.general => '通用',
    };
  }

  static SignCategory fromString(String s) {
    return SignCategory.values.firstWhere(
      (e) => e.name == s,
      orElse: () => SignCategory.daily,
    );
  }
}

/// 单个 locale 的可选覆盖字段。null 表示沿用默认（zh_CN）。
class SignI18n {
  final String? title;
  final String? poem;
  final String? interpretation;
  final String? allusion;
  final List<String>? modernNotes;

  const SignI18n({
    this.title,
    this.poem,
    this.interpretation,
    this.allusion,
    this.modernNotes,
  });

  factory SignI18n.fromJson(Map<String, dynamic> json) {
    return SignI18n(
      title: json['title'] as String?,
      poem: json['poem'] as String?,
      interpretation: json['interpretation'] as String?,
      allusion: json['allusion'] as String?,
      modernNotes: (json['modernNotes'] as List<dynamic>?)?.cast<String>(),
    );
  }
}

class FortuneSign {
  final int id;
  final FortuneLevel level;
  final String title;        // zh_CN 默认
  final String poem;
  final String interpretation;
  final String allusion;
  final List<SignCategory> categories;
  final List<String> modernNotes;

  /// locale code -> 覆盖字段。例 `{ "zh_TW": {...}, "en": {...} }`
  final Map<String, SignI18n> i18n;

  const FortuneSign({
    required this.id,
    required this.level,
    required this.title,
    required this.poem,
    required this.interpretation,
    required this.allusion,
    required this.categories,
    required this.modernNotes,
    this.i18n = const {},
  });

  factory FortuneSign.fromJson(Map<String, dynamic> json) {
    final i18nMap = (json['i18n'] as Map<String, dynamic>?) ?? {};
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
      i18n: i18nMap.map(
        (k, v) => MapEntry(k, SignI18n.fromJson(v as Map<String, dynamic>)),
      ),
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
        'i18n': i18n,
      };

  // ── 按 locale 取字段（缺失 fallback 到 zh_CN 默认）──────────────────

  /// localeCode 形如 'zh_CN' / 'zh_TW' / 'en'
  String getTitle(String localeCode) =>
      i18n[localeCode]?.title ?? title;

  String getPoem(String localeCode) =>
      i18n[localeCode]?.poem ?? poem;

  String getInterpretation(String localeCode) =>
      i18n[localeCode]?.interpretation ?? interpretation;

  String getAllusion(String localeCode) =>
      i18n[localeCode]?.allusion ?? allusion;

  List<String> getModernNotes(String localeCode) =>
      i18n[localeCode]?.modernNotes ?? modernNotes;
}
