// lib/features/home/home_page.dart
// 主界面（投掷入口）—— 100% 按切图设计还原

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/lunar_calendar.dart';
import '../../data/models/fortune_sign.dart';
import '../../data/models/subscription_state.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/providers.dart';
import '../throw/throw_page.dart';

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
    // V1 试用到期后不再有"3 次/日"轻量体验
    // 没 unlimited 权限 → 直接弹付费墙，不进投掷
    final hasUnlimited = ref.read(hasUnlimitedAccessProvider);
    if (!hasUnlimited) {
      context.push('/paywall');
      return;
    }

    final question = _customQuestion.isNotEmpty
        ? _customQuestion
        : _selectedCategory.label;
    // 自定义问题模式：抽签走 general 池；category 模式走原 category 池
    final isCustom = _customQuestion.isNotEmpty;

    if (mounted) {
      Navigator.of(context).push(
        PageRouteBuilder(
          opaque: true,
          transitionDuration: const Duration(milliseconds: 250),
          reverseTransitionDuration: const Duration(milliseconds: 250),
          pageBuilder: (context, animation, secondaryAnimation) => ThrowPage(
            category: _selectedCategory,
            question: question,
            isCustom: isCustom,
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

  void _showCustomDialog() {
    final l = AppLocalizations.of(context);

    // 弹窗宽度：屏宽 70%
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = (screenWidth * 0.7).clamp(260.0, 320.0);
    final dialogHeight = dialogWidth / (260 / 303);

    const inputW = 220.0;
    const inputH = 146.0;
    final inputLeft = (dialogWidth - inputW) / 2;
    const inputTop = 66.0;
    const counterTop = inputTop + inputH + 4;

    showDialog(
      context: context,
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
                              onTap: _onCustomSubmit,
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

  Widget _buildInputField(double width, double height, StateSetter setLocalState, AppLocalizations l) {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              image: const DecorationImage(
                image: AssetImage('assets/images/home/自定义问题-输入框bg@2x.png'),
                fit: BoxFit.fill,
              ),
              border: Border.all(
                color: AppColors.goldYellow.withValues(alpha: 0.6),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
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
        Positioned.fill(
          child: TextField(
            controller: _customController,
            autofocus: true,
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
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final user = ref.watch(currentUserProvider).valueOrNull;

    final now = DateTime.now();
    final dateStr = DateFormat('yyyy年M月d日').format(now);
    final lunarStr = LunarCalendar.getLunarDate(now);

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
                  const SizedBox(height: 50),
                  const SizedBox(height: 40),

                  // 名字 + 城市（居中）
                  if (user != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 34),
                      child: Column(
                        children: [
                          Text(
                            '${user.name} ${l.homeDiscipleSuffix}',
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
                                '${l.homeCityPrefix}${user.city}',
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

                  const SizedBox(height: 20),

                  // 6 个 category 卡片
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
                          label: l.homeCatDaily,
                          selected: _selectedCategory == SignCategory.daily && _customQuestion.isEmpty,
                          onTap: () => _onCategoryTap(SignCategory.daily),
                        ),
                        _CategoryCard(
                          category: SignCategory.career,
                          assetPath: 'assets/images/home/事业@2x.png',
                          label: l.homeCatCareer,
                          selected: _selectedCategory == SignCategory.career && _customQuestion.isEmpty,
                          onTap: () => _onCategoryTap(SignCategory.career),
                        ),
                        _CategoryCard(
                          category: SignCategory.love,
                          assetPath: 'assets/images/home/感情@2x.png',
                          label: l.homeCatLove,
                          selected: _selectedCategory == SignCategory.love && _customQuestion.isEmpty,
                          onTap: () => _onCategoryTap(SignCategory.love),
                        ),
                        _CategoryCard(
                          category: SignCategory.family,
                          assetPath: 'assets/images/home/家庭@2x.png',
                          label: l.homeCatFamily,
                          selected: _selectedCategory == SignCategory.family && _customQuestion.isEmpty,
                          onTap: () => _onCategoryTap(SignCategory.family),
                        ),
                        _CategoryCard(
                          category: SignCategory.health,
                          assetPath: 'assets/images/home/健康@2x.png',
                          label: l.homeCatHealth,
                          selected: _selectedCategory == SignCategory.health && _customQuestion.isEmpty,
                          onTap: () => _onCategoryTap(SignCategory.health),
                        ),
                        _CategoryCard(
                          category: SignCategory.wealth,
                          assetPath: 'assets/images/home/财运@2x.png',
                          label: l.homeCatWealth,
                          selected: _selectedCategory == SignCategory.wealth && _customQuestion.isEmpty,
                          onTap: () => _onCategoryTap(SignCategory.wealth),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // 底部：输入框 + 投掷按钮 + 剩余次数
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    child: Column(
                      children: [
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
                        ),
                        const SizedBox(height: 18),
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
                              child: Text(
                                l.homeThrowBtn,
                                style: const TextStyle(
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
                        _buildStatusLine(),
                      ],
                    ),
                  ),
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

  /// 投掷按钮下方的状态行（5 状态对应 5 套文案 + 链接）
  /// 替代 V0.1 的「今日剩余次数 · 升级无限」
  Widget _buildStatusLine() {
    final l = AppLocalizations.of(context);
    final subState = ref.watch(subscriptionStateProvider);

    String text;
    String linkText;
    VoidCallback onLinkTap;
    Color linkColor;

    switch (subState.status) {
      case SubscriptionStatus.trialActive:
        text = l.homeStatusTrialActive(subState.daysRemaining);
        linkText = l.homeStatusLinkSubscribe;
        onLinkTap = () => context.push('/paywall');
        linkColor = AppColors.mazuRed;
        break;
      case SubscriptionStatus.trialLastDay:
        text = l.homeStatusTrialLastDay;
        linkText = l.homeStatusLinkSubscribe;
        onLinkTap = () => context.push('/paywall');
        linkColor = AppColors.mazuRed;
        break;
      case SubscriptionStatus.trialExpired:
        text = l.homeStatusTrialExpired;
        linkText = l.homeStatusLinkSubscribe;
        onLinkTap = () => context.push('/paywall');
        linkColor = AppColors.mazuRed;
        break;
      case SubscriptionStatus.subscribed:
        final renewal = subState.subscriptionRenewalDate;
        final dateStr = renewal == null
            ? ''
            : DateFormat.MMMd(Localizations.localeOf(context).toLanguageTag())
                .format(renewal);
        text = l.homeStatusSubscribed(dateStr);
        linkText = l.homeStatusLinkManage;
        onLinkTap = () => _openManageSubscription();
        linkColor = AppColors.gray;
        break;
      case SubscriptionStatus.subExpired:
        text = l.homeStatusSubExpired;
        linkText = l.homeStatusLinkRenew;
        onLinkTap = () => context.push('/paywall');
        linkColor = AppColors.mazuRed;
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.gray,
                fontFamily: 'ChillJinshuSong',
              ),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '·',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.gray,
              fontFamily: 'ChillJinshuSong',
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onLinkTap,
            behavior: HitTestBehavior.opaque,
            child: Text(
              linkText,
              style: TextStyle(
                fontSize: 13,
                color: linkColor,
                decoration: TextDecoration.underline,
                decorationColor: linkColor,
                fontFamily: 'ChillJinshuSong',
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 已订阅用户点「管理」时跳 App Store 订阅管理页
  /// M5 接 IAP 后：调 InAppPurchase.showSubscriptionsIAPPage()（iOS 弹原生 sheet）
  /// 当前 M1 stub：跳到 settings（暂未接 IAP，settings 是订阅区块入口）
  void _openManageSubscription() {
    context.push('/settings');
  }
}

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
            // 切图缺失时显示占位（防御性，实际展示的卡片都有图）
            Image.asset(
              assetPath,
              width: 54,
              height: 54,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stack) => Container(
                width: 54,
                height: 54,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.goldYellow.withValues(alpha: 0.15),
                ),
                child: const Text(
                  '✦',
                  style: TextStyle(
                    fontSize: 28,
                    color: Color(0xB3C9A449), // goldYellow 70%
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
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
