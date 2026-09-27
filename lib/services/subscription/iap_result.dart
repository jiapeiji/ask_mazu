// lib/services/subscription/iap_result.dart
// IAP 事件类型（UI 监听 iapService.events 拿到这些）
//
// sealed class 模式：Dart 3 模式匹配，UI switch 时编译器强制处理每个 case
//
// 5 个事件：
//   - IapPurchasedEvent: 订阅成功 / 恢复成功（含 expiresAt / transactionId）
//   - IapPendingEvent: 等待中（用户在系统弹窗确认）
//   - IapCanceledEvent: 用户取消
//   - IapErrorEvent: 错误（带 message）
//   - IapProductEvent: 产品拉取成功（UI 拿真实价格）

sealed class IapEvent {
  const IapEvent();
}

/// 订阅成功 / 恢复成功（写盘入口）
class IapPurchasedEvent extends IapEvent {
  final String productId;
  final DateTime expiresAt;          // 估算的下次扣费时间
  final String transactionId;       // IAP 原始凭证
  final DateTime transactionDate;   // 交易时间

  const IapPurchasedEvent({
    required this.productId,
    required this.expiresAt,
    required this.transactionId,
    required this.transactionDate,
  });
}

/// 等待中（用户看到 iOS 系统弹窗，没确认/取消）
class IapPendingEvent extends IapEvent {
  const IapPendingEvent();
}

/// 用户取消
class IapCanceledEvent extends IapEvent {
  const IapCanceledEvent();
}

/// 错误
class IapErrorEvent extends IapEvent {
  final String message;
  const IapErrorEvent(this.message);
}

/// 产品拉取成功（给 UI 拿真实价格）
class IapProductEvent extends IapEvent {
  final String productId;
  final String displayPrice;        // 本地化的价格字符串（"$0.99" / "¥6.00" / "RM4.50"）
  final String title;               // 产品名（"Mazu Pro 会员"）
  final String description;        // 描述

  const IapProductEvent({
    required this.productId,
    required this.displayPrice,
    required this.title,
    required this.description,
  });
}
