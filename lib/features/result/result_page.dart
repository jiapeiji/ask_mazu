// lib/features/result/result_page.dart
// 2026-08-14 解析页 v2（按 解析@2x.png UI 图还原）
// 切图: assets/images/result_new/
//
// ═══ 文件结构（行号速查）══════════════════════════════════
//   L54-180:  ResultPage              主入口（Scaffold + Stack + Column）
//   L183-199: _CupImage               ① 签杯图（双月牙，居中）
//   L202-240: _CupNameBadge           ② 杯名徽章（圣/笑/阴，米色描边切图底）
//   L243-265: _OpeningMessage         ③ 开场白（居中两行）
//   L268-306: _InterpretationCard     ④ 解析卡（Stack 三层：底图+内容+木牌）
//   ├─ L309-401: _CardContent             卡片正文（标题+诗句+解曰+现代解读）
//   │  ├─ L404-446: _PoemBlock            诗句块（自动按 7 字一行拆）
//   │  ├─ L449-464: _DividerLine          分割线
//   │  ├─ L467-537: _Section              通用段落（"解曰" 用，✦ 浮外侧）
//   │  └─ L540-621: _ModernNotesSection   现代解读（标题+bullet 列表）
//   └─ L624-674: _SideLevelTag            左侧黄色木牌（"中中"/"下下"竖排）
//   L677-702: _BottomButtons           ⑤ 底部按钮容器
//   ├─ L705-765: _ShareButton              分享（米色，按下变红）
//   └─ L768-818: _RetryButton              改日再问（暗红）
//   L820-849: ResultPageDebug          Debug 预览入口（假数据跑整页）
//
// ═══ 设计稿基准 ════════════════════════════════════════════
//   设计稿宽 750pt。所有 * scale 表达式都会按 (screenW / 750) 自动缩放。
//   例：iPhone 17 Pro 逻辑宽 402pt → scale ≈ 0.536。
//
// ═══ 调参速查 ════════════════════════════════════════════
//   解析卡高度      L147   694 * scale
//   解析卡左右边距  L149   40 * scale
//   顶部让出        L131   1.6 * statusBar
//   解析卡内 padding L287  fromLTRB(150, 28, 28, 28)
//   解析卡底图 fill L280   BoxFit.fill（强制拉伸，改 cover 不拉伸）
//   底部按钮边距    L692   24 * scale

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/result_templates.dart';
import '../../core/i18n/locale_aware_style.dart';
import '../../data/models/fortune_sign.dart';
import '../../data/models/question_record.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/providers.dart';
import 'share_sheet.dart';

// ─── 切图路径 ─────────────────────────────────────────────
abstract class R {
  static const String pageBg           = 'assets/images/result_new/bg@2x.png';
  static const String cupYin           = 'assets/images/result_new/阴杯@2x.png';
  static const String cupLaugh         = 'assets/images/result_new/笑杯@2x.png';
  static const String cupSaint         = 'assets/images/result_new/圣杯@2x.png';
  static const String cupYinBg         = 'assets/images/result_new/阴杯-bg@2x.png';
  static const String cupLaughBg       = 'assets/images/result_new/笑杯-bg@2x.png';
  static const String cupSaintBg       = 'assets/images/result_new/圣杯-bg@2x.png';
  static const String interpBg         = 'assets/images/result_new/解析bg@2x.png';
  static const String interpDivider    = 'assets/images/result_new/解析分割线@2x.png';
  static const String interpHeaderIcon = 'assets/images/result_new/解析分类@2x.png';
  static const String interpSubIcon    = 'assets/images/result_new/解析分类子类@2x.png';
  static const String signCardBg       = 'assets/images/result_new/签文bg@2x.png';
  static const String shareIcon        = 'assets/images/result_new/分享icon@2x.png';
  static const String shareBtn         = 'assets/images/result_new/分享按钮bg@2x.png';
  static const String shareBtnPressed  = 'assets/images/result_new/分享按钮按下@2x.png';
  static const String retryBtn         = 'assets/images/result_new/改日再问按钮@2x.png';
  static const String retryBtnPressed  = 'assets/images/result_new/改日再问按钮按下@2x.png';
  static const String mazuImage        = 'assets/images/result_new/image@2x.png';  // 笑杯结果页展位图（妈祖观音 + 祥云）
}

// 设计稿基准 750宽
const double _kDesignW = 750;

class ResultPage extends ConsumerStatefulWidget {
  final ThrowResultType result;
  final FortuneSign? sign;
  final String question;
  final Mood mood;

  const ResultPage({
    super.key,
    required this.result,
    required this.sign,
    required this.question,
    this.mood = Mood.confused,
  });

  @override
  ConsumerState<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends ConsumerState<ResultPage> {
  bool _saved = false;  // 防止重复保存

  @override
  void initState() {
    super.initState();
    // 揭晓 ding(投掷视频结束后 → result_page 进来 → 响一下)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(soundServiceProvider).playResult();
    });
  }

  /// V1.2:保存 · 写入日记
  /// - add 一条 QuestionRecord
  /// - 跳回首页
  /// - SnackBar 提示
  Future<void> _onSave() async {
    if (_saved) return;
    _saved = true;

    final user = ref.read(currentUserProvider).valueOrNull;
    final name = user?.name ?? '弟子';

    final record = QuestionRecord(
      id: const Uuid().v4(),
      timestamp: DateTime.now(),
      question: widget.question,
      mood: widget.mood,
      result: widget.result,
      signId: widget.sign?.id,
      nameAtTime: name,
    );

    await ref.read(recordsProvider.notifier).add(record);

    if (!mounted) return;
    // 回到首页
    Navigator.of(context).popUntil((route) => route.isFirst);
    // SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('已记一次 · 今日记录'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    final sign = widget.sign;
    final question = widget.question;

    final l = AppLocalizations.of(context);
    final code = ref.watch(settingsProvider).localeCode;

    final cupAsset = switch (result) {
      ThrowResultType.saint => R.cupSaint,
      ThrowResultType.laugh => R.cupLaugh,
      ThrowResultType.yin   => R.cupYin,
    };
    final cupNameBadgeAsset = switch (result) {
      ThrowResultType.saint => R.cupSaintBg,
      ThrowResultType.laugh => R.cupLaughBg,
      ThrowResultType.yin   => R.cupYinBg,
    };
    final cupName = switch (result) {
      ThrowResultType.saint => l.resultSaint,
      ThrowResultType.laugh => l.resultLaugh,
      ThrowResultType.yin   => l.resultYin,
    };
    final user    = ref.watch(currentUserProvider).valueOrNull;
    final name    = user?.name ?? '弟子';
    final message = ResultTemplates.getMessage(
      l: l,
      type: result, name: name, signTitle: sign?.getTitle(code),
    );
    final screenW = MediaQuery.of(context).size.width;
    final scale   = screenW / _kDesignW;

    final statusBar = MediaQuery.of(context).padding.top;

    return Scaffold(
      // 不用 transparent：transparent 时 Scaffold 不会画底色，Stack 收缩
      // 露出屏幕原生背景（黑色）。改用米白色兜底，Stack 也会用 StackFit.expand
      // 撑满整屏（避免底部出现黑条）。
      backgroundColor: AppColors.riceWhite,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ═══ [层 1] 全幅背景（米白底 + 右上墨竹 + 妈祖印章）═══
          Positioned.fill(
            child: Image.asset(R.pageBg, fit: BoxFit.cover),
          ),

          // ═══ [层 3] 主内容（Column 顺序：状态栏 → ①签杯 → ②徽章 → ③开场白 → ④解析卡 → ⑤按钮）═══
          // 包 SingleChildScrollView：小屏幕时整个页面可上下滚动，修复 bottom overflowed
          // 嵌套关系：外层（页面滚动）→ 解析卡内层（卡内容滚动），两层独立
          SafeArea(
            top: false,
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),  // 大屏 max=0 不能滚，小屏 max>0 可滚
              child: Column(
                children: [
                  SizedBox(height: 1.8 * statusBar), // 顶部让出（状态栏 + 一点点 buffer，让签杯图不贴顶）

                // ① 签杯图
                _CupImage(cupAsset: cupAsset, scale: scale),
                SizedBox(height: 30 * scale),

                // ② 杯名徽章
                _CupNameBadge(
                  name: cupName,
                  badgeAsset: cupNameBadgeAsset,
                  scale: scale,
                ),
                SizedBox(height: 30 * scale),

                // ③ 开场白（妈祖签语）
                _OpeningMessage(message: message, scale: scale),
                SizedBox(height: 16 * scale),

                // ③-b 所问（小字居中灰）
                // V1.2 (v5):只显示用户输入的思考文本(不再有 category 模式)
                _QuestionChip(
                  question: question,
                  scale: scale,
                ),
                SizedBox(height: 24 * scale),

                // ④ 笑杯 → 展位图（妈祖观音 + 祥云）；圣杯/阴杯 → 解析卡
                if (result == ThrowResultType.laugh)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24 * scale),  // 展位图到屏幕边的距离
                    child: Image.asset(
                      R.mazuImage,                                        // 妈祖观音 + 祥云展位图
                      fit: BoxFit.contain,                                 // 保持原图比例（750x680 ≈ 1.1:1）
                    ),
                  )
                else
                  SizedBox(
                    height : 694*scale,    // ← 调这里改卡高
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40 * scale),  // ← 调这里改卡到屏幕边的距离
                      child: _InterpretationCard(sign: sign, scale: scale, localeCode: code),
                    ),
                  ),

                SizedBox(height: 60 * scale),

                // ⑤ 底部按钮（分享 + 保存 · 写入日记）
                _BottomButtons(
                  scale: scale,
                  onShare: () => ShareChannelSheet.show(
                    context,
                    result: result, sign: sign,
                    message: message, question: question,
                    name: name, city: '',
                  ),
                  onSave: () => _onSave(),
                ),
                SizedBox(height: 20 * scale),
                ],
              ),
            ),
          ),

          // ═══ [层 2] 返回按钮（浮在左上角，z-order 最高）═══
          // 必须放在 [层 3] 主内容之后，Stack children 的 paint 顺序保证不被覆盖
          Positioned(
            top: 0,
            left: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Color(0xFF35241B)),
                  iconSize: 28,
                  splashRadius: 22,
                  onPressed: () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── 自定义 physics：智能边界回弹 ──────────────────────────────────
// 行为：
//   - 滚到顶 + overscroll → 回弹到 minScrollExtent（去掉 overscroll，回到初始位置）
//   - 滚到底 + overscroll → 回弹到 maxScrollExtent - viewport*0.2（让最下一行在渐变层上面）
//   - 中间位置 → 停住（不回弹）
class _SmartBouncePhysics extends BouncingScrollPhysics {
  const _SmartBouncePhysics();

  @override
  _SmartBouncePhysics applyTo(ScrollPhysics? ancestor) {
    return _SmartBouncePhysics();
  }

  @override
  Simulation? createBallisticSimulation(ScrollMetrics position, double velocity) {
    // 滚到顶 + overscroll（手指向下拖超出顶部）：回弹到 minScrollExtent（初始位置 = 最顶）
    if (position.pixels < position.minScrollExtent) {
      return ScrollSpringSimulation(
        spring,
        position.pixels,
        position.minScrollExtent,
        velocity,
        tolerance: tolerance,
      );
    }

    // 滚到底 + overscroll（手指向上拖超出底部）：回弹到 maxScrollExtent（去掉 overscroll）
    // 最下一行 = viewport 100% = 渐变 100% = 完全淡出（设计意图）
    if (position.pixels > position.maxScrollExtent) {
      return ScrollSpringSimulation(
        spring,
        position.pixels,
        position.maxScrollExtent,
        velocity,
        tolerance: tolerance,
      );
    }

    // 中间位置：停住（不回弹）
    return null;
  }
}

// ─── 自定义 Clipper：水平不裁（让 ✦ 浮出去）+ 垂直裁到 viewport ────────
// 解决 "SingleChildScrollView 内容 overscroll 时显示在 viewport 之外" 的 bug
// 标准 ClipRect 会裁掉 ✦ 浮出去（Positioned left:-30）；这里只裁垂直
class _ViewportVerticalClipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) {
    // 水平方向给 -1000 / size.width+1000 = 让 ✦ 浮出去不被裁
    // 垂直方向 0 / size.height = 严格裁剪到 viewport 范围
    return Rect.fromLTRB(-1000, 0, size.width + 1000, size.height);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) => false;
}

// ─── ① 签杯图（双月牙，居中）──────────────────────────────
class _CupImage extends StatelessWidget {
  final String cupAsset;
  final double scale;
  const _CupImage({required this.cupAsset, required this.scale});

  @override
  Widget build(BuildContext context) {
    // 签杯图按 232:180 比例展示（设计稿原始比例）
    final w = 230 * scale;
    final h = w * (180 / 232);
    return SizedBox(
      width: w,
      height: h,
      child: Image.asset(cupAsset, fit: BoxFit.contain),
    );
  }
}

// ─── ② 杯名徽章（切图底 + 红色字）──────────────────────────
class _CupNameBadge extends StatelessWidget {
  final String name;
  final String badgeAsset;
  final double scale;
  const _CupNameBadge({
    required this.name,
    required this.badgeAsset,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    // 切图 200:72 = 2.78 比例，按 200x72 设计稿尺寸显示
    final w = 200 * scale;
    final h = w * (72 / 200);
    return SizedBox(
      width: w,
      height: h,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 切图底（圣杯-bg / 笑杯-bg / 阴杯-bg）—— 切图本身印着"圣杯"中文
          Image.asset(badgeAsset, fit: BoxFit.fill),
          Center(
            child: Text(
              name,
              style: TextStyle(
                fontSize: 36 * scale,
                fontWeight: FontWeight.w700,
                color: AppColors.mazuRed,
                fontFamily: 'ChillJinshuSong',
                // 任务 2：英文 letterSpacing 艺术性 >= 2.0 归零
                letterSpacing: letterSpacingFor(locale, 5 * scale),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── ③ 开场白（居中两行，灰色文字）───────────────────────
class _OpeningMessage extends StatelessWidget {
  final String message;
  final double scale;
  const _OpeningMessage({required this.message, required this.scale});

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 120 * scale),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 28 * scale,
          // 任务 4：英文行高比中文紧凑
          height: heightFor(locale, 1.7),
          color: Color(0xFF35241B),
          fontFamily: 'ChillJinshuSong',
          // 任务 2：英文 letterSpacing < 2 保留 30%
          letterSpacing: letterSpacingFor(locale, 1.5 * scale),
        ),
      ),
    );
  }
}

// ─── ③-b 所问 chip（小字居中,V1.2 只显示输入文本）──
class _QuestionChip extends StatelessWidget {
  final String question;
  final double scale;
  const _QuestionChip({
    required this.question,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final body = question.isEmpty ? '—' : question;
    final text = '—  所  问  —   $body';
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 80 * scale),
      child: Text(
        text,
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 22 * scale,
          color: const Color(0x9935241B),  // 半透明深棕，与开场白主体协调但不抢风头
          fontFamily: 'ChillJinshuSong',
          letterSpacing: letterSpacingFor(locale, 1 * scale),
          height: heightFor(locale, 1.4),
        ),
      ),
    );
  }
}

// ─── ④ 解析卡（米黄背景+红描边）──────────────────────────
class _InterpretationCard extends StatelessWidget {
  final FortuneSign? sign;
  final double scale;
  final String localeCode;
  const _InterpretationCard({required this.sign, required this.scale, required this.localeCode});

  @override
  Widget build(BuildContext context) {
    final sign0 = sign;
    return Stack(
      children: [
        // ═══ [层 A] 卡片底图（米黄背景+红描边切图，BoxFit.fill 强制填满）═══
        // 改 fill→cover 可不拉伸，但需同步改外层 SizedBox 高度
        Positioned.fill(
          child: Image.asset(R.interpBg, fit: BoxFit.fill),
        ),

        // ═══ [层 B] 滚动内容（viewport 不对称：顶部 8% 留白 + 底部 5% 留白）═══
        // 左侧 170 让出木牌
        // 顶部 padding = 8% 卡高（卡底图装饰区） → 正文从距离卡顶 8% 处开始
        // 底部 padding = 5% 卡高（卡底图装饰区） → 正文到距离卡底 5% 处截止
        // 渐变效果：ShaderMask 在 viewport 底部 20% 区域淡出到透明
        // 滑动边界：BouncingScrollPhysics（iOS 橡皮筋，overscroll 时最下一行能滑出渐变区）
        //   + 外层 ClipRect 限制渲染到卡范围（overscroll 内容不会画到卡外）
        // clipBehavior: Clip.none 保留 → ✦ 仍能水平浮到外侧
        Positioned.fill(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final cardH = constraints.maxHeight;                       // 卡总高
              final paddingTop = cardH * 0.08;                           // 顶部 8% 留白
              final paddingBottom = cardH * 0.05;                        // 底部 5% 留白
              return Padding(
                padding: EdgeInsets.fromLTRB(170 * scale, paddingTop, 28 * scale, paddingBottom),
                child: ClipRect(                                        // 强制垂直裁剪到 viewport 范围
                  clipper: _ViewportVerticalClipper(),                  // 自定义：水平不裁（让 ✦ 浮出去），垂直裁剪
                  child: ShaderMask(                                    // ShaderMask 渐变蒙版
                    // 渐变蒙版：viewport 底部 20% 区域淡出到透明（顶部不渐变）
                    blendMode: BlendMode.dstIn,                         // 用内容 alpha 裁剪
                  shaderCallback: (rect) {
                    return const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black,                                   // 0%   顶完全不透明
                        Colors.black,                                   // 80%  仍不透明
                        Colors.transparent,                             // 100% 底完全透明（保持原设计）
                      ],
                      stops: [0.0, 0.80, 1.0],
                    ).createShader(rect);
                  },
                  child: SingleChildScrollView(
                    physics: const _SmartBouncePhysics(),            // 智能边界回弹：滚到顶→回最顶 / 滚到底→回 viewport 80% / 中间→停住
                    clipBehavior: Clip.none,                            // ✦ 仍能水平浮出（不被 ShaderMask 裁）
                    child: sign0 == null
                        ? const SizedBox.shrink()
                        : _CardContent(sign: sign0, scale: scale, localeCode: localeCode),
                  ),
                  ),
                ),
              );
            },
          ),
        ),

        // ═══ [层 C] 左侧黄色木牌签条（绝对定位，覆盖在内容之上）═══
        Positioned(
          top: 0 * scale,
          left: 60 * scale,  // 木牌距离卡左边的偏移
          child: _SideLevelTag(level: sign?.level, scale: scale),
        ),
      ],
    );
  }
}

// 卡片正文
class _CardContent extends StatelessWidget {
  final FortuneSign sign;
  final double scale;
  final String localeCode;
  const _CardContent({required this.sign, required this.scale, required this.localeCode});

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ─── 标题行：左侧"第 N 签" + 右侧"| 静待天时 |"（带红竖线）───
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '第 ${sign.id} 签',
              style: TextStyle(
                fontSize: 24 * scale,
                color: Color(0x9935241B),
                fontFamily: 'ChillJinshuSong',
              ),
            ),
            const Spacer(),
            // Flexible + FittedBox：英文长 title（如 "A Rooster's Flight of
            // Ten Thousand Miles"）会自动缩小保持完整，不溢出卡片。
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _verticalBar(scale),
                    SizedBox(width: 10 * scale),
                    Text(
                      sign.getTitle(localeCode),
                      maxLines: 1,
                      softWrap: false,
                      style: TextStyle(
                        fontSize: 32 * scale,
                        fontWeight: FontWeight.w700,
                        color: AppColors.mazuRed,
                        fontFamily: 'ChillJinshuSong',
                        // 任务 2：英文艺术性 letterSpacing 归零
                        letterSpacing: letterSpacingFor(locale, 3 * scale),
                      ),
                    ),
                    SizedBox(width: 10 * scale),
                    _verticalBar(scale),
                  ],
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 30 * scale),

        // ─── 诗句（两行，_PoemBlock 自动按 7 字一行拆）───
        _PoemBlock(poem: sign.getPoem(localeCode), scale: scale),

        SizedBox(height: 22 * scale),

        // ─── 分割线 1 ───
        _DividerLine(scale: scale),

        SizedBox(height: 18 * scale),

        // ─── "解 曰" 段落（图标浮外侧，与正文同 X）───
        _Section(
          iconAsset: R.interpHeaderIcon,
          title: '解  曰',
          titleColor: AppColors.inkBlack,
          titleSize: 28 * scale,
          titleWeight: FontWeight.w700,
          body: sign.getInterpretation(localeCode),
          bodySize: 24 * scale,
          bodyColor: AppColors.inkBlack,
          scale: scale,
        ),

        SizedBox(height: 16 * scale),

        // ─── 分割线 2 ───
        _DividerLine(scale: scale),

        SizedBox(height: 16 * scale),

        // ─── "现代解读" 段落（标题 + bullet 列表，bullet icon 浮外侧）───
        _ModernNotesSection(
          notes: sign.getModernNotes(localeCode),
          scale: scale,
        ),
      ],
    );
  }

  // 标题行左右两侧的短红竖线（"| 静待天时 |" 两侧的 |）
  Widget _verticalBar(double s) => Container(
        width: 2.5 * s,
        height: 18 * s,
        color: AppColors.mazuRed,
      );
}

// 诗句块（两行，等宽字体感）
class _PoemBlock extends StatelessWidget {
  final String poem;
  final double scale;
  const _PoemBlock({required this.poem, required this.scale});

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final lines = _splitPoem(poem);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < lines.length; i++) ...[
          Text(
            lines[i],
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: 24 * scale,
              // 任务 4：英文行高比中文紧凑
              height: heightFor(locale, 1.6),
              color: AppColors.inkBlack,
              fontFamily: 'ChillJinshuSong',
              // 任务 2：英文 letterSpacing 艺术性 >= 2 归零
              letterSpacing: letterSpacingFor(locale, 3 * scale),
            ),
          ),
          if (i != lines.length - 1) SizedBox(height: 2 * scale),
        ],
      ],
    );
  }

  // 诗句分割：先按 \n 拆，再按每 16 字一行
  List<String> _splitPoem(String raw) {
    if (raw.contains('\n')) {
      return raw.split('\n').where((s) => s.trim().isNotEmpty).toList();
    }
    // 自动按 16 字一行
    final cleaned = raw.replaceAll(RegExp(r'\s+'), '');
    final out = <String>[];
    for (int i = 0; i < cleaned.length; i += 16) {
      out.add(cleaned.substring(i, i + 16 > cleaned.length ? cleaned.length : i + 16));
    }
    return out;
  }
}

// 分割线（撑满 CardContent 宽度 + 用 Transform 往左浮出去对齐木牌位置）
class _DividerLine extends StatelessWidget {
  final double scale;
  const _DividerLine({required this.scale});

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      // ← 改这里调左偏量（负数 = 往左浮出去）
      //  -90 * scale  → 线左端对齐"中中"木牌左边缘
      //  -150 * scale → 线左端对齐解析卡左边（紧贴卡边）
      //  -180 * scale → 线左端浮出木牌
      offset: Offset(-90 * scale, 0),
      child: SizedBox(
        width: 700 * scale,           // 改这个数字调长度
        height: 2 * scale,             // 改这个数字调粗细
        child: Image.asset(R.interpDivider, fit: BoxFit.fill),
      ),
    );
  }
}

// 段落组件（解曰 / 现代解读 都用）
class _Section extends StatelessWidget {
  final String iconAsset;
  final String title;
  final Color titleColor;
  final double titleSize;
  final FontWeight titleWeight;
  final String body;
  final double bodySize;
  final Color bodyColor;
  final double scale;

  const _Section({
    required this.iconAsset,
    required this.title,
    required this.titleColor,
    required this.titleSize,
    required this.titleWeight,
    required this.body,
    required this.bodySize,
    required this.bodyColor,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    // 用 Stack + Positioned：✦ 浮到外侧更左，标题和正文都在 Column 起点（完美同 X）
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // 标题 + 正文：都在 CardContent 起点（同 X）
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16 * scale),
            Text(
              title,
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: titleWeight,
                color: titleColor,
                fontFamily: 'ChillJinshuSong',
                // 任务 2：英文 letterSpacing < 2 保留 30%
                letterSpacing: letterSpacingFor(locale, 0.6 * scale),
              ),
            ),
            SizedBox(height: 16 * scale),
            Text(
              body,
              style: TextStyle(
                fontSize: bodySize,
                // 任务 4：英文行高比中文紧凑
                height: heightFor(locale, 1.7),
                color: bodyColor,
                fontFamily: 'ChillJinshuSong',
                letterSpacing: letterSpacingFor(locale, 0.6 * scale),
              ),
            ),
          ],
        ),
        // ✦ 浮到外侧更左（独立突出）
        Positioned(
          left: -30 * scale,
          top: 28 * scale,
          child: Image.asset(
            iconAsset,
            width: 22 * scale,
            height: 22 * scale,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }
}

// 现代解读（带子项列表）
class _ModernNotesSection extends StatelessWidget {
  final List<String> notes;
  final double scale;
  const _ModernNotesSection({required this.notes, required this.scale});

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    // 结构与 _Section 完全一致：Stack + Column(标题 + SizedBox + 内容) + Positioned ✦
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // 标题 + bullet 列表：都在 CardContent 起点（同 X）
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题前间距（与 _Section 一致）
            SizedBox(height: 16 * scale),
            // 标题"现代解读"（字号/字距与 _Section 解曰一致）
            Text(
              '现代解读',
              style: TextStyle(
                fontSize: 28 * scale,
                fontWeight: FontWeight.w700,
                color: Color(0xFF35241B),
                fontFamily: 'ChillJinshuSong',
                letterSpacing: letterSpacingFor(locale, 0.6 * scale),
              ),
            ),
            // 标题后间距（与 _Section 一致）
            SizedBox(height: 16 * scale),
            // bullet 列表：text 起点 = 0（跟"现代解读" 同 X）
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final n in notes)
                  Padding(
                    padding: EdgeInsets.only(bottom: 12 * scale),  // bullet 间间距
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // bullet icon：在文字左边，跟"现代解读"标题文字同起点（X=0）
                        Padding(  
                          padding: EdgeInsets.only(top: 15 * scale),
                          child: Image.asset(
                            R.interpSubIcon,
                            width: 8 * scale,
                            height: 8 * scale,
                            fit: BoxFit.contain,
                          ),
                        ),
                        SizedBox(width: 8 * scale),               // icon 和文字间距
                        Expanded(
                          child: Text(
                            n,
                            style: TextStyle(
                              fontSize: 24 * scale,
                              height: 1.2,
                              color: AppColors.inkBlack,
                              fontFamily: 'ChillJinshuSong',
                              letterSpacing: 0.6 * scale,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
        // ✦ 标题 icon 浮到外侧（与 _Section 完全一致）
        Positioned(
          left: -30 * scale,
          top: 28 * scale,                                      // 跳过 SizedBox(16) + 标题行
          child: Image.asset(
            R.interpHeaderIcon,
            width: 22 * scale,                                  // ← 与 _Section ✦ 同尺寸
            height: 22 * scale,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }
}

// ④-c 左侧黄色长条等级吊牌（"中中"/"下下" 等竖排字）
class _SideLevelTag extends StatelessWidget {
  final FortuneLevel? level;
  final double scale;
  const _SideLevelTag({required this.level, required this.scale});

  @override
  Widget build(BuildContext context) {
    final label = level == null ? '签' : '${level!.label}签';
    // 木牌 52:166 比例，按设计稿高 200 显示 → 宽 = 200/166*52 = 62.6
    final h = 200 * scale;
    final w = h * (52 / 166);
    return SizedBox(
      width: w,
      height: h,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 木牌底图（带绳+孔+木纹）
          Image.asset(R.signCardBg, fit: BoxFit.fill),
          // 等级文字（竖排在木牌中央，每个字独立 Padding 形成"中中"两字垂直居中）
          Center(
            child: Padding(
              // 顶部让出绳子+圆孔
              padding: EdgeInsets.only(top: 60 * scale, bottom: 10 * scale),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final ch in label.split(''))
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 4 * scale),
                      child: Text(
                        ch,
                        style: TextStyle(
                          fontSize: 20 * scale,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFFFFFFF),
                          fontFamily: 'ChillJinshuSong',
                          height: 1.1,
                          letterSpacing: 1 * scale,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── ⑤ 底部按钮（分享 + 保存 · 写入日记）────────────────────
class _BottomButtons extends StatelessWidget {
  final double scale;
  final VoidCallback onShare;
  final VoidCallback onSave;
  const _BottomButtons({
    required this.scale,
    required this.onShare,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 36 * scale),
      child: Row(
        children: [
          Expanded(child: _ShareButton(scale: scale, onPressed: onShare)),
          SizedBox(width: 24 * scale),
          Expanded(child: _SaveButton(scale: scale, onPressed: onSave)),
        ],
      ),
    );
  }
}

// ⑤-a 分享按钮（米色云纹切图 + 分享 icon + 黑字，按下整体变红）
class _ShareButton extends StatefulWidget {
  final double scale;
  final VoidCallback onPressed;
  const _ShareButton({required this.scale, required this.onPressed});

  @override
  State<_ShareButton> createState() => _ShareButtonState();
}

class _ShareButtonState extends State<_ShareButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapUp:   (_) { setState(() => _down = false); widget.onPressed(); },
      onTapCancel: () => setState(() => _down = false),
      behavior: HitTestBehavior.opaque,
      child: AspectRatio(
        aspectRatio: 318 / 96, // 切图原始比例
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 切图背景（按下/默认）
            Image.asset(
              _down ? R.shareBtnPressed : R.shareBtn,
              fit: BoxFit.fill,
            ),
            // 内容
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    R.shareIcon,
                    width: 36 * widget.scale,
                    height: 36 * widget.scale,
                    fit: BoxFit.contain,
                    color: _down ? AppColors.mazuRed : null,
                  ),
                  SizedBox(width: 10 * widget.scale),
                  Text(
                    l.resultShareBtn,
                    style: TextStyle(
                      fontSize: 32 * widget.scale,
                      fontWeight: FontWeight.w600,
                      color: _down ? AppColors.mazuRed : AppColors.inkBlack,
                      fontFamily: 'ChillJinshuSong',
                      letterSpacing: 3 * widget.scale,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ⑤-b 保存按钮（暗红云纹切图 + 米色字，按下变浅）
class _SaveButton extends StatefulWidget {
  final double scale;
  final VoidCallback onPressed;
  const _SaveButton({
    required this.scale,
    required this.onPressed,
  });

  @override
  State<_SaveButton> createState() => _SaveButtonState();
}

class _SaveButtonState extends State<_SaveButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapUp:   (_) { setState(() => _down = false); widget.onPressed(); },
      onTapCancel: () => setState(() => _down = false),
      behavior: HitTestBehavior.opaque,
      child: AspectRatio(
        aspectRatio: 318 / 96,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              _down ? R.retryBtnPressed : R.retryBtn,
              fit: BoxFit.fill,
            ),
            Center(
              child: Text(
                '保存 · 写入日记',
                style: TextStyle(
                  fontSize: 30 * widget.scale,
                  fontWeight: FontWeight.w600,
                  color: AppColors.riceWhite,
                  fontFamily: 'ChillJinshuSong',
                  letterSpacing: letterSpacingFor(locale, 2 * widget.scale),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── DEBUG ────────────────────────────────────────────────
class ResultPageDebug extends StatelessWidget {
  const ResultPageDebug({super.key});

  static const _sampleSign = FortuneSign(
    id: 59,
    level: FortuneLevel.lowerLower,
    title: '静待天时',
    poem: '雷雨交加暂掩门，闭门端坐待天明。\n时来运转风云变，否极泰来万象新。',
    interpretation: '主当前运势极低，不宜妄动。宜静守，待时来运转，自有转机。',
    allusion: '出自《易经》否卦九五：其亡其亡，系于苞桑。',
    categories: [SignCategory.daily],
    modernNotes: [
      '求职：暂时找不到工作，等经济周期',
      '创业：当前市场环境差，再等等',
      '投资：现金为王，不要抄底',
      '感情：缘分未到，先提升自己'
      '感情：缘分未到，先提升自己'
      '感情：缘分未到，先提升自己'
      '感情：缘分未到，先提升自己',
    ],
  );

  @override
  Widget build(BuildContext context) {
    return const ResultPage(
      result: ThrowResultType.yin,
      sign: _sampleSign,
      question: '我想换个工作，时机合适吗？',
      mood: Mood.confused,
    );
  }
}
