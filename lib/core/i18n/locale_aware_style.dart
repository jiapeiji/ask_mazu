// lib/core/i18n/locale_aware_style.dart
//
// Locale-aware text style adjustments for 中/繁 vs English.
//
// 中文/繁体 letterSpacing 偏大（书法感、印章感），英文 letterSpacing 几乎
// 不用（> 2 的会显得稀松）。height 同理：英文行高比中文紧凑。
//
// 用法：
// ```dart
// Text(
//   sign.getTitle(localeCode),
//   style: TextStyle(
//     letterSpacing: letterSpacingFor(locale, 3 * scale),
//     height: heightFor(locale, 1.7),
//   ),
// )
// ```

import 'package:flutter/widgets.dart';

/// 根据 locale 返回合适的 letterSpacing。
///
/// 规则：
/// - 中文/繁体：保持原值（设计稿的中文艺术感）
/// - 英文：letterSpacing >= 2.0 的"艺术性"间距归零；小调整（< 2.0）保留 30%
double letterSpacingFor(Locale locale, double zhValue) {
  if (locale.languageCode == 'zh') return zhValue;
  if (zhValue >= 2.0) return 0;
  return zhValue * 0.3;
}

/// 根据 locale 返回合适的 line height。
/// 英文行高比中文紧凑（约 88%）。
double heightFor(Locale locale, double zhValue) {
  if (locale.languageCode == 'zh') return zhValue;
  return zhValue * 0.88;
}
