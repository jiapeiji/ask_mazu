// lib/features/paywall/paywall_page.dart
// 付费墙页面（V1 + IAP 接入）
//
// 触发场景：
//   - home 投掷按钮（trial_expired / subExpired）
//   - home 状态行的「立即订阅」「立即续订」链接
//   - settings 订阅区块（未订阅时点订阅入口）
//
// 状态机：
//   - 启动时订阅 IapService.events
//   - IapProductEvent → 拿到真实价格（"¥6.00" / "$0.99" / "RM4.50"）
//   - IapPurchasedEvent → 写盘 + pop
//   - IapPendingEvent → 按钮变 loading
//   - IapCanceledEvent → 提示已取消
//   - IapErrorEvent → 提示错误
//
// 流程：
//   1. main.dart 启动时调 iapService.init()（注册 stream + 拉 products）
//   2. paywall initState 监听 events stream
//   3. 用户点订阅 → 调 iapService.buyMonthly()（iOS 系统弹窗确认）
//   4. 成功 → IapPurchasedEvent → notifier.updateSubscription 写盘 → pop
//   5. 失败/取消 → 提示 + 保留在 paywall
//
// 价格显示：
//   - 拉取中：占位文案
//   - 拉取成功：product.price（Apple 本地化字符串）
//   - 拉取失败：占位 + retry 按钮

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/subscription_state.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/providers.dart';
import '../../services/subscription/iap_result.dart';
import '../settings/about_dialogs.dart';

class PaywallPage extends ConsumerStatefulWidget {
  const PaywallPage({super.key});

  @override
  ConsumerState<PaywallPage> createState() => _PaywallPageState();
}

class _PaywallPageState extends ConsumerState<PaywallPage> {
  StreamSubscription<IapEvent>? _eventSub;
  String? _displayPrice;
  bool _hasProductError = false;
  bool _isProcessing = false;
  bool _hasPurchased = false; // 防重：成功事件来时只处理一次

  @override
  void initState() {
    super.initState();
    // 防御：已订阅用户点进来（极少见，正常流程不会发生）
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final subState = ref.read(subscriptionStateProvider);
      if (subState.status == SubscriptionStatus.subscribed) {
        context.pop();
        return;
      }
    });

    // 监听 IAP 事件
    final iap = ref.read(iapServiceProvider);
    // 如果产品已经拉到了，立刻用现有价格
    if (iap.currentProducts.isNotEmpty) {
      _displayPrice = iap.currentProducts.first.price;
    }

    _eventSub = iap.events.listen(_onIapEvent);
  }

  @override
  void dispose() {
    _eventSub?.cancel();
    super.dispose();
  }

  void _onIapEvent(IapEvent event) {
    if (!mounted) return;
    final l = AppLocalizations.of(context);

    switch (event) {
      case IapProductEvent():
        setState(() {
          _displayPrice = event.displayPrice;
          _hasProductError = false;
        });
        break;
      case IapPurchasedEvent():
        if (_hasPurchased) return; // 防重
        _hasPurchased = true;
        // 写盘 → state 变 subscribed
        // IapPurchasedEvent 已经在 IapService 内部算好 expiresAt
        // 我们直接调 notifier 写盘
        ref.read(subscriptionStateProvider.notifier).updateSubscription(
              expiresAt: event.expiresAt,
              originalTransactionId: event.transactionId,
            );
        setState(() => _isProcessing = false);
        // 订阅成功震动反馈(settings 开关控制,fire-and-forget 不阻塞 UI)
        if (ref.read(settingsProvider).hapticEnabled) {
          // ignore: discarded_futures
          ref.read(hapticServiceProvider).light();
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l.paywallSubscribeSuccess),
            duration: const Duration(seconds: 2),
          ),
        );
        context.pop();
        break;
      case IapPendingEvent():
        setState(() => _isProcessing = true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l.paywallPendingHint),
            duration: const Duration(seconds: 1),
          ),
        );
        break;
      case IapCanceledEvent():
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l.paywallCanceledHint),
            duration: const Duration(seconds: 1),
          ),
        );
        break;
      case IapErrorEvent():
        // 产品拉取错误时显示在价格区
        // 购买/恢复错误时显示 snackbar
        if (_displayPrice == null) {
          setState(() => _hasProductError = true);
        } else {
          setState(() => _isProcessing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l.paywallErrorGeneric(event.message)),
              duration: const Duration(seconds: 3),
            ),
          );
        }
        break;
    }
  }

  Future<void> _onSubscribe() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    try {
      await ref.read(iapServiceProvider).buyMonthly();
      // 后续结果通过 _onIapEvent 处理
    } catch (e) {
      if (!mounted) return;
      final l = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.paywallErrorPurchase(e.toString()))),
      );
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _onRestore() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    try {
      await ref.read(iapServiceProvider).restore();
      // 后续结果通过 _onIapEvent 处理
      // restore 不会发 canceled / pending 事件，只发 purchased / error
      // 沙盒"没找到"的情况：iOS 不发任何事件，需要给个友好提示
      // 简单方案：3 秒后如果还在 processing，主动 reset + 提示
      Future.delayed(const Duration(seconds: 3), () {
        if (!mounted) return;
        if (_isProcessing && !_hasPurchased) {
          final l = AppLocalizations.of(context);
          setState(() => _isProcessing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l.paywallRestoreEmpty)),
          );
        }
      });
    } catch (e) {
      if (!mounted) return;
      final l = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.paywallErrorRestore(e.toString()))),
      );
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _onRetryLoadProduct() async {
    setState(() => _hasProductError = false);
    await ref.read(iapServiceProvider).reloadProducts();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.riceWhite,
      body: SafeArea(
        child: Column(
          children: [
            // 顶部关闭按钮
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close, color: AppColors.gray),
                onPressed: () => context.pop(),
              ),
            ),

            // 可滚动内容
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 12),

                    // 标题
                    Text(
                      l.paywallTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.inkBlack,
                        letterSpacing: 1,
                        fontFamily: 'ChillJinshuSong',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l.paywallSubtitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.gray,
                        letterSpacing: 0.5,
                        fontFamily: 'ChillJinshuSong',
                      ),
                    ),
                    const SizedBox(height: 32),

                    // 价值主张 3 条
                    _buildFeatureBullet(
                      icon: Icons.all_inclusive,
                      text: l.paywallFeatureUnlimited,
                    ),
                    const SizedBox(height: 14),
                    _buildFeatureBullet(
                      icon: Icons.menu_book_outlined,
                      text: l.paywallFeatureAllSigns,
                    ),
                    const SizedBox(height: 14),
                    _buildFeatureBullet(
                      icon: Icons.spa_outlined,
                      text: l.paywallFeatureAmbient,
                    ),
                    const SizedBox(height: 32),

                    // 价格卡
                    _buildPriceCard(l),

                    const SizedBox(height: 24),

                    // 订阅按钮
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: (_isProcessing || _displayPrice == null)
                            ? null
                            : _onSubscribe,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.mazuRed,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              AppColors.mazuRed.withValues(alpha: 0.5),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isProcessing
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.white),
                                ),
                              )
                            : Text(
                                l.paywallSubscribeBtn,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 4,
                                  fontFamily: 'ChillJinshuSong',
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 恢复购买（灰色小字）
                    TextButton(
                      onPressed: _isProcessing ? null : _onRestore,
                      child: Text(
                        l.paywallRestoreBtn,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.gray,
                          decoration: TextDecoration.underline,
                          fontFamily: 'ChillJinshuSong',
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // 底部：继续即代表同意 [用户协议] · [隐私政策]
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 8, 28, 16),
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    l.paywallTermsPrefix,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.gray,
                      fontFamily: 'ChillJinshuSong',
                    ),
                  ),
                  GestureDetector(
                    onTap: () => AboutDialogs.showTermsOfService(context),
                    behavior: HitTestBehavior.opaque,
                    child: Text(
                      l.paywallTermsLink,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.mazuRed,
                        decoration: TextDecoration.underline,
                        fontFamily: 'ChillJinshuSong',
                      ),
                    ),
                  ),
                  const Text(
                    ' · ',
                    style: TextStyle(fontSize: 11, color: AppColors.gray),
                  ),
                  GestureDetector(
                    onTap: () => AboutDialogs.showPrivacyPolicy(context),
                    behavior: HitTestBehavior.opaque,
                    child: Text(
                      l.paywallPrivacyLink,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.mazuRed,
                        decoration: TextDecoration.underline,
                        fontFamily: 'ChillJinshuSong',
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
  }

  Widget _buildPriceCard(AppLocalizations l) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.mazuRed, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.mazuRed.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题行（含 reload 按钮）
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l.paywallPriceCardTitle,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.mazuRed,
                  letterSpacing: 0.5,
                  fontFamily: 'ChillJinshuSong',
                ),
              ),
              if (_hasProductError)
                TextButton(
                  onPressed: _onRetryLoadProduct,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    l.paywallRetry,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.mazuRed,
                      decoration: TextDecoration.underline,
                      fontFamily: 'ChillJinshuSong',
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),

          // 价格（加载中 / 错误 / 真实）
          if (_displayPrice == null && !_hasProductError)
            Text(
              l.paywallPriceLoading,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: AppColors.gray,
                fontFamily: 'ChillJinshuSong',
              ),
            )
          else if (_hasProductError)
            Text(
              l.paywallPriceError,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: AppColors.gray,
                fontFamily: 'ChillJinshuSong',
              ),
            )
          else
            Text(
              _displayPrice!,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppColors.inkBlack,
                fontFamily: 'ChillJinshuSong',
              ),
            ),
          const SizedBox(height: 6),
          Text(
            l.paywallPriceCardNote,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.gray,
              fontFamily: 'ChillJinshuSong',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureBullet({required IconData icon, required String text}) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.goldYellow.withValues(alpha: 0.18),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 16, color: AppColors.goldYellow),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.inkBlack,
              letterSpacing: 0.3,
              fontFamily: 'ChillJinshuSong',
            ),
          ),
        ),
      ],
    );
  }
}
