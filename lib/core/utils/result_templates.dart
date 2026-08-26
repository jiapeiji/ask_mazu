// lib/core/utils/result_templates.dart
// 妈祖开场白：按当前 locale 选 8 套模板之一（圣/笑/阴杯各 8 套）
//
// 模板来自 ARB（i18n），由 [getMessage] 在调用方传入 AppLocalizations 选取。

import 'dart:math';

import '../../l10n/generated/app_localizations.dart';

enum ThrowResultType { saint, laugh, yin }

class ResultTemplates {
  ResultTemplates._();

  static final _random = Random();

  /// 根据结果类型与当前语言，从 ARB 取 8 套模板之一，替换 {name} / {signTitle}。
  static String getMessage({
    required AppLocalizations l,
    required ThrowResultType type,
    required String name,
    String? signTitle,
  }) {
    // 随机选一个 index，按当前 locale + 类型选模板并替换占位符
    final i = _random.nextInt(8);
    final signTitleArg = signTitle ?? '';
    return switch (type) {
      ThrowResultType.saint => _pickSaint(l, i, name, signTitleArg),
      ThrowResultType.laugh => _pickLaugh(l, i, name),
      ThrowResultType.yin   => _pickYin(l, i, name),
    };
  }

  static String _pickSaint(AppLocalizations l, int i, String name, String signTitle) {
    return switch (i) {
      0 => l.saintTemplate1(name, signTitle),
      1 => l.saintTemplate2(name),
      2 => l.saintTemplate3(name, signTitle),
      3 => l.saintTemplate4(name),
      4 => l.saintTemplate5(name, signTitle),
      5 => l.saintTemplate6(name),
      6 => l.saintTemplate7(name, signTitle),
      _ => l.saintTemplate8(name),
    };
  }

  static String _pickLaugh(AppLocalizations l, int i, String name) {
    return switch (i) {
      0 => l.laughTemplate1(name),
      1 => l.laughTemplate2(name),
      2 => l.laughTemplate3(name),
      3 => l.laughTemplate4(name),
      4 => l.laughTemplate5(name),
      5 => l.laughTemplate6(name),
      6 => l.laughTemplate7(name),
      _ => l.laughTemplate8(name),
    };
  }

  static String _pickYin(AppLocalizations l, int i, String name) {
    return switch (i) {
      0 => l.yinTemplate1(name),
      1 => l.yinTemplate2(name),
      2 => l.yinTemplate3(name),
      3 => l.yinTemplate4(name),
      4 => l.yinTemplate5(name),
      5 => l.yinTemplate6(name),
      6 => l.yinTemplate7(name),
      _ => l.yinTemplate8(name),
    };
  }

  /// 重问按钮文案（保留兼容，新代码用 AppLocalizations.resultRetry*）
  static String getRetryButtonText(ThrowResultType type) {
    return switch (type) {
      ThrowResultType.laugh => '重新组织问题',
      ThrowResultType.yin => '改日再问',
      ThrowResultType.saint => '再问一次',
    };
  }
}
