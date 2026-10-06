// lib/features/home/home_page.dart
// 反思 tab(原 home_page, V1.2 重构)
//
// V1.2 (v5) 改动:
//   - 删 6 个问事类目(daily/career/love/family/health/wealth 网格)
//   - 加今日反思 prompt(早/午/晚/深夜 4 套轮换,基于 DateTime.hour)
//   - 加 5 个心情选择器(必选 1:☺平和/☹低落/😶迷茫/😌充实/😠烦躁)
//   - 改投杯按钮文案 → 「掷杯筊 · 问妈祖」
//   - 加状态判断:今日已记录 → 显示 B 状态卡(仅读,不可重掷)
//
// 资产(复用):
//   - bg@2x.png(顶部背景)
//   - icon-菜单@2x.png(右上角设置)
//   - 输入框bg / 按钮bg / 标题装饰 / icon-输入
//   - mazu-figure@2x.png (顶部装饰,可选)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/lunar_calendar.dart';
import '../../core/utils/reflection_prompts.dart';
import '../../core/utils/result_templates.dart';
import '../../data/models/fortune_sign.dart';
import '../../data/models/question_record.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/providers.dart';
import '../throw/throw_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  // V1.2 (v5):不再有 _selectedCategory(类目删了),只用 _customQuestion 作思考文本
  final TextEditingController _customController = TextEditingController();
  String _customQuestion = '';
  bool _buttonPressed = false;

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  Future<void> _onThrow() async {
    // V1.2 (v5) 取消订阅拦截:直接进投掷
    // 临时仍传 SignCategory.daily 占位(V1 的 sign_repository 仍按类目筛);
    // 后续 W2 改 sign_repository 为"每日 1 支 + 6 时辰变种"时移除 category 字段
    final question = _customQuestion.isNotEmpty
        ? _customQuestion
        : '';

    if (mounted) {
      Navigator.of(context).push(
        PageRouteBuilder(
          opaque: true,
          transitionDuration: const Duration(milliseconds: 250),
          reverseTransitionDuration: const Duration(milliseconds: 250),
          pageBuilder: (context, animation, secondaryAnimation) => ThrowPage(
            category: SignCategory.daily,
            question: question,
            isCustom: question.isNotEmpty,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
              child: child,
            );
          },
        ),
      );
    }
  }

  /// 是否今日已记录(用于切换 A/B 状态)
  bool _hasTodayRecord(List<QuestionRecord>? records) {
    if (records == null || records.isEmpty) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    return records.any((r) => r.timestamp.isAfter(today) && r.timestamp.isBefore(tomorrow));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final user = ref.watch(currentUserProvider).valueOrNull;
    final recordsAsync = ref.watch(recordsProvider);

    final now = DateTime.now();
    final dateStr = DateFormat('yyyy年M月d日').format(now);
    final lunarStr = LunarCalendar.getLunarDate(now);
    final prompt = ReflectionPrompts.today(now);

    final hasToday = _hasTodayRecord(recordsAsync.valueOrNull);

    return Scaffold(
      backgroundColor: AppColors.riceWhite,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/home/bg@2x.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 90),
                  const SizedBox(height: 40),

                  // 用户名 + "弟子"
                  if (user != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 34),
                      child: Column(
                        children: [
                          Text(
                            '${user.name} ${l.homeDiscipleSuffix}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              color: AppColors.inkBlack,
                              letterSpacing: 0.5,
                              fontFamily: 'ChillJinshuSong',
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 28),

                  // ═══ 状态 A(未记录):prompt + 心情 + 输入 + 投杯 ═══
                  if (!hasToday) ...[
                    _buildPromptBanner(prompt),
                    const SizedBox(height: 14),
                    _buildMoodRow(),
                    const SizedBox(height: 20),
                  ] else ...[
                    // ═══ 状态 B(已记录):今日已记录卡 + 提示 ═══
                    _buildTodayRecordedCard(l),
                    const SizedBox(height: 20),
                  ],

                  // 标题 + 装饰
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Text(
                          l.homeAskTitle,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: AppColors.inkBlack,
                            fontFamily: 'ChillJinshuSong',
                          ),
                        ),
                        Transform.translate(
                          offset: const Offset(-15, -5),
                          child: Image.asset(
                            'assets/images/home/标题装饰@2x.png',
                            height: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // 底部:输入框 + 投杯按钮
                  if (!hasToday)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                      child: Column(
                        children: [
                          _buildCustomInputField(l),
                          const SizedBox(height: 18),
                          _buildThrowButton(l),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // 吸顶顶部栏
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: _buildTopBar(context, dateStr, lunarStr),
            ),
          ),
        ],
      ),
    );
  }

  /// 反思 prompt banner(米黄底,左红边)
  Widget _buildPromptBanner(String prompt) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF3E6E3),
          borderRadius: BorderRadius.circular(8),
          border: const Border(left: BorderSide(color: AppColors.mazuRed, width: 3)),
        ),
        child: Text(
          prompt,
          style: const TextStyle(
            fontSize: 15,
            color: AppColors.inkBlack,
            fontFamily: 'ChillJinshuSong',
            height: 1.55,
          ),
        ),
      ),
    );
  }

  /// 心情选择器(必选 1,V1.2 UI 占位 — 实际选中态留到下轮接 mood 字段)
  Widget _buildMoodRow() {
    final moods = const [
      ('☺', '平和'),
      ('☹', '低落'),
      ('😶', '迷茫'),
      ('😌', '充实'),
      ('😠', '烦躁'),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: moods.map((m) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.lightGray),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(m.$1, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 4),
              Text(
                m.$2,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.inkBlack,
                  fontFamily: 'ChillJinshuSong',
                ),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }

  /// 已记录状态卡
  Widget _buildTodayRecordedCard(AppLocalizations l) {
    final recordsAsync = ref.watch(recordsProvider);
    final records = recordsAsync.valueOrNull ?? [];
    final todayRecord = records.firstWhere(
      (r) => true,  // 占位:取最近一条
      orElse: () => QuestionRecord(
        id: '',
        timestamp: DateTime.now(),
        question: '',
        mood: Mood.confused,
        result: ThrowResultType.saint,
        nameAtTime: '',
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.lightGray),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.check_circle, color: AppColors.mazuRed, size: 16),
                const SizedBox(width: 6),
                Text(
                  '今日 · 已记一次',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.mazuRed,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'ChillJinshuSong',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (todayRecord.question.isNotEmpty)
              Text(
                '「${todayRecord.question}」',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.inkBlack,
                  fontFamily: 'ChillJinshuSong',
                  height: 1.5,
                ),
              ),
            const SizedBox(height: 14),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF7F0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '今日已记录 · 明日再见',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.gray,
                    fontFamily: 'ChillJinshuSong',
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 自定义问题输入框(复用现有切图 + 弹窗)
  Widget _buildCustomInputField(AppLocalizations l) {
    return GestureDetector(
      onTap: _showCustomDialog,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 58,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/home/输入框bg@2x.png'),
            fit: BoxFit.fill,
          ),
        ),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/home/icon-输入@2x.png',
              width: 16,
              height: 16,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                _customQuestion.isNotEmpty ? _customQuestion : l.homeCustomHint,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  color: _customQuestion.isNotEmpty
                      ? AppColors.inkBlack
                      : AppColors.gray,
                  fontFamily: 'ChillJinshuSong',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 投杯按钮(V1.2 改文案)
  Widget _buildThrowButton(AppLocalizations l) {
    return GestureDetector(
      onTap: _onThrow,
      onTapDown: (_) => setState(() => _buttonPressed = true),
      onTapUp: (_) => setState(() => _buttonPressed = false),
      onTapCancel: () => setState(() => _buttonPressed = false),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        height: 69,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              _buttonPressed
                  ? 'assets/images/home/按钮bg-pressed@2x.png'
                  : 'assets/images/home/按钮bg-default@2x.png',
            ),
            fit: BoxFit.fill,
          ),
        ),
        alignment: Alignment.center,
        child: const Text(
          '掷杯筊 · 问妈祖',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 4,
            fontFamily: 'ChillJinshuSong',
          ),
        ),
      ),
    );
  }

  /// 顶部日期栏(吸顶)
  Widget _buildTopBar(BuildContext context, String dateStr, String lunarStr) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.push('/settings'),
            behavior: HitTestBehavior.opaque,
            child: Image.asset(
              'assets/images/home/icon-菜单@2x.png',
              width: 26,
              height: 26,
            ),
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                dateStr,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.inkBlack,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                lunarStr,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.gray,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  //  自定义问题输入弹窗(V1 复用)
  // ════════════════════════════════════════════════════════════
  Future<void> _showCustomDialog() async {
    final l = AppLocalizations.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth * 0.85;
    final dialogHeight = 320.0;
    final inputW = dialogWidth * 0.6;
    final inputH = 50.0;
    final inputLeft = (dialogWidth - inputW) / 2;
    final inputTop = 110.0;
    final counterTop = 170.0;

    _customController.clear();

    await showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocalState) {
            final currentLength = _customController.text.length;
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: EdgeInsets.symmetric(horizontal: (screenWidth - dialogWidth) / 2),
              child: SizedBox(
                width: dialogWidth,
                height: dialogHeight,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.asset(
                        'assets/images/home/自定义问题-弹窗bg@2x.png',
                        fit: BoxFit.fill,
                      ),
                    ),
                    Positioned(
                      top: 29,
                      left: 20,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            l.homeCustomTitle,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AppColors.inkBlack,
                              letterSpacing: 0.3,
                              fontFamily: 'ChillJinshuSong',
                            ),
                          ),
                          Transform.translate(
                            offset: const Offset(-15, -5),
                            child: Image.asset(
                              'assets/images/home/标题装饰@2x.png',
                              height: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: inputLeft,
                      top: inputTop,
                      width: inputW,
                      height: inputH,
                      child: _buildInputField(inputW, inputH, setLocalState, l),
                    ),
                    Positioned(
                      top: counterTop,
                      left: inputLeft,
                      width: inputW,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '$currentLength/30',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.gray,
                            fontFamily: 'ChillJinshuSong',
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 260,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Image.asset(
                          'assets/images/home/自定义问题-分隔线@2x.png',
                          width: 220,
                          height: 40,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 260,
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => Navigator.pop(ctx),
                              behavior: HitTestBehavior.opaque,
                              child: Center(
                                child: Text(
                                  l.commonCancel,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: AppColors.inkBlack,
                                    fontFamily: 'ChillJinshuSong',
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _onCustomSubmit(ctx),
                              behavior: HitTestBehavior.opaque,
                              child: Center(
                                child: Text(
                                  l.commonConfirm,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.mazuRed,
                                    fontFamily: 'ChillJinshuSong',
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInputField(double inputW, double inputH, void Function(void Function()) setLocalState, AppLocalizations l) {
    return Container(
      width: inputW,
      height: inputH,
      decoration: BoxDecoration(
        color: const Color(0xFFFAF5EC),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE8DFCF)),
      ),
      child: TextField(
        controller: _customController,
        maxLength: 30,
        textAlign: TextAlign.center,
        onChanged: (_) => setLocalState(() {}),
        style: const TextStyle(
          color: AppColors.inkBlack,
          fontSize: 14,
          fontFamily: 'ChillJinshuSong',
          height: 1.4,
        ),
        decoration: InputDecoration(
          hintText: l.homeCustomHint,
          hintStyle: const TextStyle(
            color: Color(0xFFB8B0A0),
            fontSize: 14,
            fontFamily: 'ChillJinshuSong',
            height: 1.4,
          ),
          counterText: '',
          border: InputBorder.none,
          contentPadding: const EdgeInsets.fromLTRB(16, 14, 50, 14),
          isCollapsed: true,
          filled: true,
          fillColor: Colors.transparent,
        ),
      ),
    );
  }

  void _onCustomSubmit(BuildContext ctx) {
    final text = _customController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _customQuestion = text;
    });
    Navigator.of(ctx).pop();
  }
}
