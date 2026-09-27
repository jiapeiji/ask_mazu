// lib/features/onboarding/onboarding_page.dart
// 报家门页（仅首次启动）
//
// 资产：
//   - 背景四张：mountain-main@2x.png（主景，半透明 0.5）/ mountain-1@2x.png（底左山）
//     / mountain-2@2x.png（底右山）/ bamboo@2x.png（左上竹叶）
//   - 顶部妈祖图：mazu-figure@2x.png
//   - 输入框 / 按钮：复用首页切图（输入框bg / 按钮bg-default|pressed）
//   - 输入框左侧 icon：icon-name@2x.png（人形）/ icon-city@2x.png（定位）
//   - 装饰线：ornament-line@2x.png（左右翻转）
//   - 标题后圆形装饰：复用首页 assets/images/home/标题装饰@2x.png
//
// 验证：去掉 Form/validator，提交时手动检查 → SnackBar 报错
//       （原因：Form 默认 error 文字位置跟 hint 错位，且切图输入框内显示红字很丑）

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/providers.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _nameController = TextEditingController();
  final _cityController = TextEditingController();
  bool _buttonPressed = false;

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _submit() async {
    final l = AppLocalizations.of(context);
    final name = _nameController.text.trim();
    final city = _cityController.text.trim();

    if (name.isEmpty) { _showError(l.onbNameErrorEmpty); return; }
    if (name.length < 2) { _showError(l.onbNameErrorShort); return; }
    if (city.isEmpty) { _showError(l.onbCityErrorEmpty); return; }
    if (city.length < 2) { _showError(l.onbCityErrorShort); return; }

    await ref.read(currentUserProvider.notifier).save(name, city);
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.riceWhite,
      body: Stack(
        children: [
          // ═══ 底层：米色 ═══
          const Positioned.fill(
            child: ColoredBox(color: AppColors.riceWhite),
          ),
          // ═══ 主景：山 + 船 + 亭 + 桥（半透明，水平居中靠下）═══
          // 调参：top 控制上下 / width 控制大小 / opacity 控制透明度
          Positioned(
            left: 0,
            right: 0,
            top: 170,
            child: Opacity(
              opacity: 0.4,
              child: Image.asset(
                'assets/images/onboarding/mountain-main@2x.png',
                width: 320,
                fit: BoxFit.contain,
                alignment: Alignment.bottomCenter,
              ),
            ),
          ),
          // ═══ 左上：竹叶 ═══
          Positioned(
            top: 60,
            left: 0,
            child: Image.asset(
              'assets/images/onboarding/bamboo@2x.png',
              width: 100,
            ),
          ),
          // ═══ 底部左：山 1 ═══
          Positioned(
            bottom: 20,
            left: 20,
            child: Image.asset(
              'assets/images/onboarding/mountain-1@2x.png',
              width: 100,
            ),
          ),
          // ═══ 底部右：山 2 ═══
          Positioned(
            bottom: 20,
            right: 20,
            child: Image.asset(
              'assets/images/onboarding/mountain-2@2x.png',
              width: 90,
            ),
          ),
          // ═══ 内容层 ═══
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  // ─── 妈祖图 ───
                  Center(
                    child: Image.asset(
                      'assets/images/onboarding/mazu-figure@2x.png',
                      width: 144,
                      height: 166,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // ─── "妈祖" 红字 ───
                  Text(
                    l.onbMazu,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: AppColors.mazuRed,
                      fontFamily: 'ChillJinshuSong',
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // ─── 装饰线 + tagline ───
                  // 调参：装饰线 width 限制（防止溢出）
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 左：装饰线原图，限宽 60
                      SizedBox(
                        width: 80,
                        child: Image.asset(
                          'assets/images/onboarding/ornament-line@2x.png',
                          height: 14,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // 中：tagline，Flexible 让它能收缩
                      Flexible(
                        child: Text(
                          l.onbTagline,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.inkBlack,
                            letterSpacing: 1,
                            fontFamily: 'ChillJinshuSong',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // 右：装饰线翻转，限宽 60
                      Transform.scale(
                        scaleX: -1,
                        child: SizedBox(
                          width: 80,
                          child: Image.asset(
                            'assets/images/onboarding/ornament-line@2x.png',
                            height: 14,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),
                  // ─── 名字 label + 圆形装饰 ───
                  _LabelWithOrnament(text: l.onbNameLabel),
                  const SizedBox(height: 12),
                  _HomeStyleInputField(
                    controller: _nameController,
                    hint: l.onbNameHint,
                    maxLength: 10,
                    iconAsset: 'assets/images/onboarding/icon-name@2x.png',
                  ),
                  const SizedBox(height: 24),
                  // ─── 城市 label + 圆形装饰 ───
                  _LabelWithOrnament(text: l.onbCityLabel),
                  const SizedBox(height: 12),
                  _HomeStyleInputField(
                    controller: _cityController,
                    hint: l.onbCityHint,
                    maxLength: 30,
                    iconAsset: 'assets/images/onboarding/icon-city@2x.png',
                  ),
                  const SizedBox(height: 40),
                  // ─── 入殿问事按钮 ───
                  _HomeStyleButton(
                    label: l.onbSubmit,
                    pressed: _buttonPressed,
                    onPressed: _submit,
                    onPressChange: (v) => setState(() => _buttonPressed = v),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l.onbFootnote,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.gray,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 标签 + 圆形装饰（参考首页"今日欲问何事"的写法）
class _LabelWithOrnament extends StatelessWidget {
  final String text;
  const _LabelWithOrnament({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          text,
          style: const TextStyle(
            fontSize: 18,
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
    );
  }
}

/// 输入框：复用首页切图（输入框bg + icon），内部 TextFormField
/// 行为：
///   - icon 永远显示
///   - placeholder(hint)：unfocus + 空内容时显示，focus 时淡出（200ms）
class _HomeStyleInputField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLength;
  final String iconAsset;

  const _HomeStyleInputField({
    required this.controller,
    required this.hint,
    required this.maxLength,
    required this.iconAsset,
  });

  @override
  State<_HomeStyleInputField> createState() => _HomeStyleInputFieldState();
}

class _HomeStyleInputFieldState extends State<_HomeStyleInputField> {
  final _focusNode = FocusNode();
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (mounted) {
      setState(() => _hasFocus = _focusNode.hasFocus);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      decoration: const BoxDecoration(
        color: Color(0xFFF7F1EA),  // 内部填充色（米色）
        image: DecorationImage(
          image: AssetImage('assets/images/home/输入框bg@2x.png'),
          fit: BoxFit.fill,
        ),
      ),
      // Center + Row：icon 紧贴文字（10px 间距），整体在输入框内水平居中
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // icon：永远显示
            Image.asset(widget.iconAsset, width: 16, height: 16),
            const SizedBox(width: 10),
            SizedBox(
              width: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // TextField（无 hint）
                  TextFormField(
                    controller: widget.controller,
                    focusNode: _focusNode,
                    maxLength: widget.maxLength,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.inkBlack,
                      fontFamily: 'ChillJinshuSong',
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      isCollapsed: true,
                      contentPadding: EdgeInsets.zero,
                      filled: false,
                    ),
                  ),
                  // 自定义 placeholder：空内容 + unfocus 时显示
                  IgnorePointer(
                    child: ValueListenableBuilder<TextEditingValue>(
                      valueListenable: widget.controller,
                      builder: (context, value, _) {
                        final showHint = value.text.isEmpty && !_hasFocus;
                        return AnimatedOpacity(
                          opacity: showHint ? 1 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: Text(
                            widget.hint,
                            style: const TextStyle(
                              fontSize: 15,
                              color: AppColors.gray,
                              fontFamily: 'ChillJinshuSong',
                            ),
                          ),
                        );
                      },
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

/// 按钮：复用首页切图（按钮bg-default/pressed）
class _HomeStyleButton extends StatelessWidget {
  final String label;
  final bool pressed;
  final VoidCallback onPressed;
  final ValueChanged<bool> onPressChange;

  const _HomeStyleButton({
    required this.label,
    required this.pressed,
    required this.onPressed,
    required this.onPressChange,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      onTapDown: (_) => onPressChange(true),
      onTapUp: (_) => onPressChange(false),
      onTapCancel: () => onPressChange(false),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        height: 69,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              pressed
                  ? 'assets/images/home/按钮bg-pressed@2x.png'
                  : 'assets/images/home/按钮bg-default@2x.png',
            ),
            fit: BoxFit.fill,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 6,
            fontFamily: 'ChillJinshuSong',
          ),
        ),
      ),
    );
  }
}
