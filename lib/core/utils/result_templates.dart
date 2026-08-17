// lib/core/utils/result_templates.dart
// 名字呼出文案模板

import 'dart:math';

enum ThrowResultType { saint, laugh, yin }

class ResultTemplates {
  ResultTemplates._();

  static final _random = Random();

  // 圣杯文案（8 套）
  static const List<String> _saintTemplates = [
    '{name} 弟子，妈祖允你所问，此签为【{signTitle}】。',
    '{name} 居士，慈航显应，所示如签。',
    '{name} 弟子，妈祖慈怀允示。签曰【{signTitle}】，望善体天心。',
    '{name} 居士，慈帆已张，顺风可期。签中所示，请细参详。',
    '{name} 居士，慈母允儿所请。签曰【{signTitle}】，愿你此去顺遂。',
    '{name} 弟子，圣杯一掷已明。签中所示，顺势而进可也。',
    '{name} 弟子，慈帆高挂，顺风正起。签曰【{signTitle}】，当进则进。',
    '{name} 子，妈祖含笑点头，所示如签。心定则事成。',
  ];

  // 笑杯文案（8 套）
  static const List<String> _laughTemplates = [
    '{name} 弟子，问事心要诚，妈祖未允。请闭目静思片刻再请示。',
    '{name} 弟子，妈祖含笑不语。此问尚有未明之处，请细思后重新请示。',
    '{name} 弟子，妈祖含笑。此问或太急、或太泛，请缓一缓再问。',
    '{name} 居士，香火未透，妈祖示以笑杯。静心三息，再来。',
    '{name} 子，问事如磨刀，太急则钝。妈祖笑你急了些，请从容再来。',
    '{name} 弟子，妈祖摇头笑曰：此问时机未到。请择日再请示。',
    '{name} 弟子，妈祖笑而不答，必有缘由。静心自省，答案或在心中。',
    '{name} 居士，妈祖笑杯示以未允。心未定时，再请示亦难应。',
  ];

  // 阴杯文案（8 套）
  static const List<String> _yinTemplates = [
    '{name} 弟子，妈祖示意此事不宜，宜缓行。',
    '{name} 弟子，此事有违天时。妈祖示意退一步，海阔天空。',
    '{name} 居士，心急则不达。妈祖示意缓行，待时来运转。',
    '{name} 居士，妈祖明示此事不妥。强行为之，必有后患。',
    '{name} 弟子，妈祖不允，必有深意。切莫逆天行事，宜守不宜攻。',
    '{name} 弟子，妈祖垂怜，示以阴杯，是为你好。暂避锋芒，谋定后动。',
    '{name} 居士，妈祖摇头示警。眼前路不通，请耐心等候天时。',
    '{name} 子，阴杯示凶，非绝路。妈祖点你：转个弯，路在前方。',
  ];

  /// 根据结果类型获取文案
  static String getMessage({
    required ThrowResultType type,
    required String name,
    String? signTitle,
  }) {
    final templates = switch (type) {
      ThrowResultType.saint => _saintTemplates,
      ThrowResultType.laugh => _laughTemplates,
      ThrowResultType.yin => _yinTemplates,
    };

    final template = templates[_random.nextInt(templates.length)];
    return template
        .replaceAll('{name}', name)
        .replaceAll('{signTitle}', signTitle ?? '');
  }

  /// 重问按钮文案
  static String getRetryButtonText(ThrowResultType type) {
    return switch (type) {
      ThrowResultType.laugh => '重新组织问题',
      ThrowResultType.yin => '改日再问',
      ThrowResultType.saint => '再问一次',
    };
  }
}
