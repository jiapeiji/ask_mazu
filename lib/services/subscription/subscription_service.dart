// lib/services/subscription/subscription_service.dart
// 订阅业务层
//
// 职责：
//   - 启动初始化（读 firstLaunchedAt + state）
//   - M5 接 IAP 后用：订阅成功 / 恢复购买 / 订阅到期 / 退款
//
// 不持有 state，state 由 SubscriptionStateNotifier 持有
// service 只负责「按业务意图读写」

import '../../data/models/subscription_state.dart';
import '../../data/repositories/subscription_repository.dart';

class SubscriptionService {
  final SubscriptionRepository _repo;

  SubscriptionService(this._repo);

  /// 启动初始化（必须在 main.dart 早期预热）
  /// - 读 app_first_launched_at（无则写当前时间）
  /// - 读 subscription_state（无则 fresh）
  Future<SubscriptionState> initialize() async {
    final trialStartedAt = await _repo.getOrInitFirstLaunchedAt();
    return await _repo.loadState(trialStartedAt);
  }

  /// M5 接 IAP 后用：订阅成功 / 自动续期
  /// 外部传新 expiresAt + 原始凭证，service 写盘后返回新 state
  Future<SubscriptionState> updateSubscription({
    required DateTime expiresAt,
    required String originalTransactionId,
  }) async {
    final trialStartedAt = await _repo.getOrInitFirstLaunchedAt();
    final state = SubscriptionState(
      trialStartedAt: trialStartedAt,
      subscriptionExpiresAt: expiresAt,
      originalTransactionId: originalTransactionId,
    );
    await _repo.saveState(state);
    return state;
  }

  /// 恢复购买
  /// - M3 接 IAP 后：参数由 InAppPurchase.restorePurchases() 返回的 active entitlement 提供
  /// - 都没有（expiresAt == null）→ 返回 null，UI 提示"未找到可恢复的购买"
  /// - 有 → 调 updateSubscription 写盘，返回新 state
  Future<SubscriptionState?> restore({
    DateTime? expiresAt,
    String? originalTransactionId,
  }) async {
    if (expiresAt == null || originalTransactionId == null) return null;
    return await updateSubscription(
      expiresAt: expiresAt,
      originalTransactionId: originalTransactionId,
    );
  }

  /// M5 用：订阅到期 / 退款（保留 trialStartedAt，只清空订阅字段）
  /// 注意：不会"重开试用"，按设计：到期后用户必须续费，不能重新走试用
  Future<SubscriptionState> clearSubscription() async {
    final trialStartedAt = await _repo.getOrInitFirstLaunchedAt();
    final fresh = SubscriptionState.fresh(trialStartedAt);
    await _repo.saveState(fresh);
    return fresh;
  }
}
