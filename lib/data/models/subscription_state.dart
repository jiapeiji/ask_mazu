// lib/data/models/subscription_state.dart
// 订阅状态（含试用起算 + 订阅到期时间）
//
// 设计：纯数据 + 派生计算（不依赖任何 service / provider / 异步）
// UI 直接 `state.status` / `state.daysRemaining` / `state.hasUnlimitedAccess` 读
// 持久化：JSON 字符串（SharedPreferences），见 SubscriptionRepository

import '../../core/constants/app_constants.dart';

/// 订阅状态枚举（5 态）
enum SubscriptionStatus {
  /// 试用期内（剩 ≥ 2 天）
  trialActive,

  /// 试用最后 1 天
  trialLastDay,

  /// 试用到期（未订阅）
  trialExpired,

  /// 订阅中
  subscribed,

  /// 订阅到期
  subExpired,
}

class SubscriptionState {
  /// 试用起算时间（= app 首次启动时间，永久不变）
  final DateTime trialStartedAt;

  /// 订阅到期时间（null = 从未订阅过）
  final DateTime? subscriptionExpiresAt;

  /// IAP 原始凭证（恢复购买 / 跨设备同步用，M5 接 IAP 时填）
  final String? originalTransactionId;

  const SubscriptionState({
    required this.trialStartedAt,
    this.subscriptionExpiresAt,
    this.originalTransactionId,
  });

  /// 工厂：首次启动时的初始状态
  factory SubscriptionState.fresh(DateTime trialStartedAt) {
    return SubscriptionState(trialStartedAt: trialStartedAt);
  }

  // ============ 派生计算 ============

  /// 当前订阅状态
  SubscriptionStatus get status {
    if (subscriptionExpiresAt != null) {
      return DateTime.now().isBefore(subscriptionExpiresAt!)
          ? SubscriptionStatus.subscribed
          : SubscriptionStatus.subExpired;
    }
    final dr = daysRemaining;
    if (dr >= 2) return SubscriptionStatus.trialActive;
    if (dr == 1) return SubscriptionStatus.trialLastDay;
    return SubscriptionStatus.trialExpired;
  }

  /// 试用剩几天（基于自然日，clamp 0..3）
  int get daysRemaining {
    final now = DateTime.now();
    final trialEnd = _trialEndDate();
    final today = DateTime(now.year, now.month, now.day);
    return trialEnd.difference(today).inDays.clamp(0, 3);
  }

  /// 是否享有 unlimited 权限（投掷 / 完整签文库 / 庙宇环境音）
  bool get hasUnlimitedAccess {
    final s = status;
    return s == SubscriptionStatus.trialActive ||
        s == SubscriptionStatus.trialLastDay ||
        s == SubscriptionStatus.subscribed;
  }

  /// 是否需要付费墙（投掷时直接弹付费墙，不给任何试用降级）
  bool get requiresPaywall {
    return status == SubscriptionStatus.trialExpired ||
        status == SubscriptionStatus.subExpired;
  }

  /// 订阅续期日（仅 subscribed 状态有意义）
  DateTime? get subscriptionRenewalDate => subscriptionExpiresAt;

  // ============ 私有 ============

  /// 试用结束日期（trialStartedAt 的 0:00 + 3 天）
  /// 按自然日算：start=2026-09-08 23:59 → end=2026-09-11 → 剩 3 天
  DateTime _trialEndDate() {
    final start = trialStartedAt;
    return DateTime(start.year, start.month, start.day)
        .add(AppConstants.trialPeriod);
  }

  // ============ 拷贝 ============

  /// clearSubscription=true 时清空 subscriptionExpiresAt + originalTransactionId
  SubscriptionState copyWith({
    DateTime? trialStartedAt,
    DateTime? subscriptionExpiresAt,
    String? originalTransactionId,
    bool clearSubscription = false,
  }) {
    return SubscriptionState(
      trialStartedAt: trialStartedAt ?? this.trialStartedAt,
      subscriptionExpiresAt: clearSubscription
          ? null
          : (subscriptionExpiresAt ?? this.subscriptionExpiresAt),
      originalTransactionId: clearSubscription
          ? null
          : (originalTransactionId ?? this.originalTransactionId),
    );
  }

  // ============ JSON ============

  Map<String, dynamic> toJson() => {
        'trialStartedAt': trialStartedAt.toIso8601String(),
        if (subscriptionExpiresAt != null)
          'subscriptionExpiresAt': subscriptionExpiresAt!.toIso8601String(),
        if (originalTransactionId != null)
          'originalTransactionId': originalTransactionId,
      };

  factory SubscriptionState.fromJson(Map<String, dynamic> json) {
    return SubscriptionState(
      trialStartedAt: DateTime.parse(json['trialStartedAt'] as String),
      subscriptionExpiresAt: json['subscriptionExpiresAt'] != null
          ? DateTime.parse(json['subscriptionExpiresAt'] as String)
          : null,
      originalTransactionId: json['originalTransactionId'] as String?,
    );
  }
}
