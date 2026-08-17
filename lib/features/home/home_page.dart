// lib/features/home/home_page.dart
// 主界面（投掷入口）—— 100% 按切图设计还原

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/lunar_calendar.dart';
import '../../core/utils/result_templates.dart';
import '../result/result_page.dart';
import '../../data/models/fortune_sign.dart';
import '../../providers/providers.dart';
import '../throw/throw_page.dart';
import '../result/result_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  SignCategory _selectedCategory = SignCategory.daily;
  final TextEditingController _customController = TextEditingController();
  String _customQuestion = '';
  bool _buttonPressed = false; // 投掷按钮按下态

  @override
  void initState() {
    super.initState();
    // 通过 JUMP_RESULT 环境变量选 result 类型：'laugh' / 'yin' / 'true' (saint)
    if (kDebugMode && const String.fromEnvironment('JUMP_RESULT').isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Future.delayed(const Duration(milliseconds: 200), () {
            if (!mounted) return;
            const jumpType = String.fromEnvironment('JUMP_RESULT');
            final ThrowResultType rt = jumpType == 'laugh'
                ? ThrowResultType.laugh
                : jumpType == 'yin'
                    ? ThrowResultType.yin
                    : ThrowResultType.saint;
            final sign = FortuneSign(
              id: 1,
              level: FortuneLevel.mid,
              title: '中签·青云得路',
              poem: '云开月出正当中，\n万里前程自此通。',
              interpretation: '...',
              allusion: '...',
              categories: [SignCategory.daily],
              modernNotes: ['...'],
            );
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => ResultPage(
                result: rt,
                sign: sign,
                category: SignCategory.daily,
                question: '今日运势',
              ),
            ));
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  void _onCategoryTap(SignCategory category) {
    setState(() {
      _selectedCategory = category;
      _customQuestion = '';
    });
  }

  void _onCustomSubmit() {
    final text = _customController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _customQuestion = text;
    });
    Navigator.of(context).pop();
  }

  Future<void> _onThrow() async {
    final isSubscribed = ref.read(isSubscribedProvider);
    final remaining = await ref.read(remainingProvider.notifier).getRemaining(isSubscribed: isSubscribed);
    final current = ref.read(remainingProvider).valueOrNull ?? 0;
    if (!isSubscribed && current <= 0) {
      _showUpgradeDialog();
      return;
    }

    await ref.read(remainingProvider.notifier).consume(isSubscribed: isSubscribed);

    final question = _customQuestion.isNotEmpty
        ? _customQuestion
        : _selectedCategory.label;

    if (mounted) {
      Navigator.of(context).push(
        PageRouteBuilder(
          opaque: true,
          transitionDuration: const Duration(milliseconds: 250),
          reverseTransitionDuration: const Duration(milliseconds: 250),
          pageBuilder: (context, animation, secondaryAnimation) => ThrowPage(
            category: _selectedCategory,
            question: question,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
              child: child,
            );
          },
        ),
      );
    }
  }

  void _showUpgradeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.riceWhite,
        title: const Text('今日次数已用完'),
        content: const Text(
          '免费版每天可投掷 3 次\n订阅无限次数 + 完整签文库',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.push('/settings');
            },
            child: const Text(
              '查看订阅',
              style: TextStyle(color: AppColors.mazuRed),
            ),
          ),
        ],
      ),
    );
  }

  void _showCustomDialog() {
    // 弹窗宽度：屏宽 70%（按 375 一倍屏 = 263，但实际 402 屏按 70% = 280）
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = (screenWidth * 0.7).clamp(260.0, 320.0);
    // 切图原始比例 260:303 = 0.858 (宽/高)，等比缩放
    final dialogHeight = dialogWidth / (260 / 303);

    // 输入框固定尺寸 220×146 logical（"矩形 13"原图 @2x 比例）
    const inputW = 220.0;
    const inputH = 146.0;
    // 输入框水平居中
    final inputLeft = (dialogWidth - inputW) / 2;
    // 标题 top=29 + 标题行高 ~24 + 间距 ~13 = 66
    const inputTop = 66.0;
    // 0/30 计数：紧贴输入框底部（+4pt 间距）
    final counterTop = inputTop + inputH + 4;
    // "组 29"分隔线：距输入框底部 39pt
    final dividerTop = inputTop + inputH + 39;
    // 按钮：分隔线下方（分隔线 40 高 + 10 间距）
    final buttonTop = dividerTop + 50;

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
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
                    // 弹窗底图（米白底+祥云+竹叶）
                    Positioned.fill(
                      child: Image.asset(
                        'assets/images/home/自定义问题-弹窗bg@2x.png',
                        fit: BoxFit.fill,
                      ),
                    ),
                    // 标题"自定义问题"：距弹窗左边 20pt，距顶部 29pt
                    Positioned(
                      top: 29,
                      left: 20,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            '自定义问题  ',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AppColors.inkBlack,
                              letterSpacing: 0.3,
                              fontFamily: 'ChillJinshuSong',
                            ),
                          ),
                          // 圆环装饰：偏移量跟首页"今日欲问何事"那个一致（Offset(-15, -5)）
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
                    // 输入框（220×146 居中，固定 top）
                    Positioned(
                      left: inputLeft,
                      top: inputTop,
                      width: inputW,
                      height: inputH,
                      child: _buildInputField(inputW, inputH, setLocalState),
                      
                    ),
                    // 0/30 字符计数（紧贴输入框底）
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
                    // "组 29"分隔线：距输入框底部 39pt（不旋转不缩放）
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
                    // 取消 / 确定 按钮
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
                              child: const Center(
                                child: Text(
                                  '取消',
                                  style: TextStyle(
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
                              onTap: _onCustomSubmit,
                              behavior: HitTestBehavior.opaque,
                              child: const Center(
                                child: Text(
                                  '确定',
                                  style: TextStyle(
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

  Widget _buildInputField(double width, double height, StateSetter setLocalState) {
    return Stack(
      children: [
        // 输入框背景：切图（"矩形 13"米白色圆角矩形）+ 金色细边框
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              image: const DecorationImage(
                image: AssetImage('assets/images/home/自定义问题-输入框bg@2x.png'),
                fit: BoxFit.fill,
              ),
              border: Border.all(
                color: AppColors.goldYellow.withOpacity(0.6),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        // 渔船占位插画（右下角）
        Positioned(
          right: 12,
          bottom: 8,
          child: Image.asset(
            'assets/images/home/自定义问题-船@2x.png',
            width: 86,
            height: 41,
            fit: BoxFit.contain,
          ),
        ),
        // TextField（浮在最上层）
        Positioned.fill(
          child: TextField(
            controller: _customController,
            maxLength: 30,
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            onChanged: (_) => setLocalState(() {}),
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.inkBlack,
              fontFamily: 'ChillJinshuSong',
              height: 1.4,
            ),
            decoration: const InputDecoration(
              hintText: '请输入您想问的事~',
              hintStyle: TextStyle(
                color: Color(0xFFB8B0A0),  // 淡灰
                fontSize: 14,
                fontFamily: 'ChillJinshuSong',
                height: 1.4,
              ),
              counterText: '',
              border: InputBorder.none,
              contentPadding: EdgeInsets.fromLTRB(16, 14, 50, 14),  // 右边留出船的位置
              isCollapsed: true,
              filled: true,
              fillColor: Colors.transparent, 

            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    final remaining = ref.watch(remainingProvider).valueOrNull ?? 0;
    final isSubscribed = ref.watch(isSubscribedProvider);

    final now = DateTime.now();
    final dateStr = DateFormat('yyyy年M月d日').format(now);
    final lunarStr = LunarCalendar.getLunarDate(now);

    return Scaffold(
      backgroundColor: AppColors.riceWhite,
      body: Stack(
        fit: StackFit.expand, // 让 SafeArea/Column 强制撑满屏宽（默认 loose 会按子节点收缩）
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/home/bg@2x.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 顶部栏：菜单 icon + Spacer + 日期 + 农历
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
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
                ),

                const SizedBox(height: 40),

                // 名字 + 城市（居中）
                if (user != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 34),
                    child: Column(
                      children: [
                        Text(
                          '${user.name} 弟 子',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: AppColors.inkBlack,
                            letterSpacing: 0.5,
                            fontFamily: 'ChillJinshuSong',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 4,
                              height: 4,
                              decoration: const BoxDecoration(
                                color: AppColors.mazuRed,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '现 居 ${user.city}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.gray,
                                letterSpacing: 1,
                                fontFamily: 'ChillJinshuSong',
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 4,
                              height: 4,
                              decoration: const BoxDecoration(
                                color: AppColors.mazuRed,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 40),

                // 标题 + 装饰（圆环在右，与"今日欲问何事"重叠）
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      const Text(
                        '今日欲问何事？',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: AppColors.inkBlack,
                          fontFamily: 'ChillJinshuSong',
                        ),
                      ),
                      // 圆环装饰：与文字重叠（向左偏移 4 像素）
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

                const SizedBox(height: 20),

                // 6 个 category 卡片（3×2）
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 0.95,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    children: [
                      _CategoryCard(
                        category: SignCategory.daily,
                        assetPath: 'assets/images/home/今日运势@2x.png',
                        label: '今日运势',
                        selected: _selectedCategory == SignCategory.daily && _customQuestion.isEmpty,
                        onTap: () => _onCategoryTap(SignCategory.daily),
                      ),
                      _CategoryCard(
                        category: SignCategory.career,
                        assetPath: 'assets/images/home/事业@2x.png',
                        label: '事业',
                        selected: _selectedCategory == SignCategory.career && _customQuestion.isEmpty,
                        onTap: () => _onCategoryTap(SignCategory.career),
                      ),
                      _CategoryCard(
                        category: SignCategory.love,
                        assetPath: 'assets/images/home/感情@2x.png',
                        label: '感情',
                        selected: _selectedCategory == SignCategory.love && _customQuestion.isEmpty,
                        onTap: () => _onCategoryTap(SignCategory.love),
                      ),
                      _CategoryCard(
                        category: SignCategory.family,
                        assetPath: 'assets/images/home/家庭@2x.png',
                        label: '家庭',
                        selected: _selectedCategory == SignCategory.family && _customQuestion.isEmpty,
                        onTap: () => _onCategoryTap(SignCategory.family),
                      ),
                      _CategoryCard(
                        category: SignCategory.health,
                        assetPath: 'assets/images/home/健康@2x.png',
                        label: '健康',
                        selected: _selectedCategory == SignCategory.health && _customQuestion.isEmpty,
                        onTap: () => _onCategoryTap(SignCategory.health),
                      ),
                      _CategoryCard(
                        category: SignCategory.wealth,
                        assetPath: 'assets/images/home/财运@2x.png',
                        label: '财运',
                        selected: _selectedCategory == SignCategory.wealth && _customQuestion.isEmpty,
                        onTap: () => _onCategoryTap(SignCategory.wealth),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40), // 输入框到按钮间距 40px

                // 底部：输入框 + 投掷按钮 + 剩余次数
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: Column(
                    children: [
                      // 1. 自定义问题输入框（切图作背景，4 角花纹自带）
                      GestureDetector(
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
                                  _customQuestion.isNotEmpty ? _customQuestion : '想问点什么？',
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
                      ),
                      const SizedBox(height: 18),
                      // 2. 投掷按钮（宽度和输入框一致，高度按切图原比例 670:128 ≈ 5.23:1 → 362/5.23 ≈ 69 logical）
                      // 默认浅红，按下深红
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 0),
                        child: GestureDetector(
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
                              '投 掷 杯 筊',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 6,
                                fontFamily: 'ChillJinshuSong',
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // 3. 今日剩余 + 升级无限（横排）
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isSubscribed
                                ? '今日无限次'
                                : '今日剩余 $remaining 次',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.gray,
                              fontFamily: 'ChillJinshuSong',
                            ),
                          ),
                          if (!isSubscribed) ...[
                            const Text(' · ', style: TextStyle(color: AppColors.gray)),
                            GestureDetector(
                              onTap: () {
                                if (!isSubscribed) _showUpgradeDialog();
                              },
                              behavior: HitTestBehavior.opaque,
                              child: const Text(
                                '升级无限 →',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.mazuRed,
                                  decoration: TextDecoration.underline,
                                  fontFamily: 'ChillJinshuSong',
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 单个 category 卡片（圆角矩形 + 圆形切图 + 文字 + 金色短下划线）
class _CategoryCard extends StatelessWidget {
  final SignCategory category;
  final String assetPath;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.assetPath,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        // 用切图作卡片背景：未选中用 bg-default，选中用 bg-click（背景加深）
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              selected
                  ? 'assets/images/home/bg-click@2x.png'
                  : 'assets/images/home/bg-default@2x.png',
            ),
            fit: BoxFit.fill,
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 圆形切图
            Image.asset(
              assetPath,
              width: 54,
              height: 54,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 6),
            // 文字
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: selected ? AppColors.mazuRed : AppColors.inkBlack,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                fontFamily: 'ChillJinshuSong',
              ),
            ),
            const SizedBox(height: 4),
            // 装饰线（用切图）
            Image.asset(
              'assets/images/home/图标装饰线@2x.png',
              width: 28,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
}
