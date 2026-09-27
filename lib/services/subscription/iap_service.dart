// lib/services/subscription/iap_service.dart
// iOS IAP 封装层（基于 in_app_purchase 3.x + StoreKit 2）
//
// 责任：
//   - init()：注册 purchase stream + 拉产品
//   - buyMonthly()：UI 触发订阅
//   - restore()：UI 触发恢复
//   - 暴露 products Stream 给 UI 拿真实价格
//   - 暴露 events Stream 给 UI 拿购买结果
//
// 验证：
//   - V1 个人项目没服务端，本地校验 + 接受风险
//   - 拿到的 PurchaseDetails.verificationData.localVerificationData 是 base64 receipt
//   - 严格校验需 Apple App Store Server API（V2 上线后）
//
// expiresAt 计算：
//   - iOS PurchaseDetails 不含 expiresDate
//   - V1 简化：transactionDate + 30 天（已知 1 月周期）
//   - 实际生产应从 receipt 解析
//
// 沙盒注意：
//   - 沙盒账号必须在 iPhone 设置登入（不是真 Apple ID）
//   - 沙盒扣 0 元，立刻算订阅
//   - 试 3 天试用：App Store Connect 配了 Introductory Offer 沙盒也支持
//   - 重置沙盒订阅：App Store Connect → Users → Sandbox → Testers → Reset

import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';

import '../../core/constants/app_constants.dart';
import 'iap_result.dart';

class IapService {
  final StreamController<List<ProductDetails>> _productsController =
      StreamController.broadcast();
  final StreamController<IapEvent> _eventsController =
      StreamController.broadcast();

  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;
  List<ProductDetails> _products = [];
  bool _initialized = false;

  /// 真实产品列表（启动 init 后才有值）
  Stream<List<ProductDetails>> get productsStream => _productsController.stream;
  Stream<IapEvent> get events => _eventsController.stream;
  List<ProductDetails> get currentProducts => List.unmodifiable(_products);

  /// 平台是否支持 IAP（iOS / Android true，Web false）
  Future<bool> isAvailable() => InAppPurchase.instance.isAvailable();

  /// 启动时调用：注册 stream + 拉产品
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    // 注册 purchase stream
    _purchaseSub = InAppPurchase.instance.purchaseStream.listen(
      _onPurchaseUpdate,
      onError: (Object e) {
        _eventsController.add(IapErrorEvent('Purchase stream error: $e'));
      },
    );

    // 拉产品
    await _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final response = await InAppPurchase.instance.queryProductDetails({
        AppConstants.monthlyProductId,
      });
      if (response.error != null) {
        _eventsController.add(
          IapErrorEvent('Query product failed: ${response.error!.message}'),
        );
        return;
      }
      if (response.productDetails.isEmpty) {
        _eventsController.add(
          IapErrorEvent(
            'Product not found in App Store: ${AppConstants.monthlyProductId}',
          ),
        );
        return;
      }
      _products = response.productDetails;
      _productsController.add(_products);
      // 顺便发一个 IapProductEvent 让 UI 知道有产品了
      final p = _products.first;
      _eventsController.add(IapProductEvent(
        productId: p.id,
        displayPrice: p.price,
        title: p.title,
        description: p.description,
      ));
    } catch (e) {
      _eventsController.add(IapErrorEvent('Query product exception: $e'));
    }
  }

  /// 拉产品失败时 UI 主动 retry
  Future<void> reloadProducts() => _loadProducts();

  void _onPurchaseUpdate(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      // 异步处理但不 await（listener 是同步的）
      _handlePurchase(purchase);
    }
  }

  Future<void> _handlePurchase(PurchaseDetails purchase) async {
    try {
      switch (purchase.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          _emitVerified(purchase);
          break;
        case PurchaseStatus.pending:
          _eventsController.add(const IapPendingEvent());
          break;
        case PurchaseStatus.canceled:
          _eventsController.add(const IapCanceledEvent());
          break;
        case PurchaseStatus.error:
          _eventsController.add(
            IapErrorEvent(
              purchase.error?.message ?? 'Unknown purchase error',
            ),
          );
          break;
      }
      // 必须 completePurchase，否则下次启动会再触发同一事件
      if (purchase.pendingCompletePurchase) {
        await InAppPurchase.instance.completePurchase(purchase);
      }
    } catch (e) {
      _eventsController.add(IapErrorEvent('Handle purchase exception: $e'));
    }
  }

  void _emitVerified(PurchaseDetails purchase) {
    // V1 简化：假设月度订阅 30 天周期
    // 实际 expiresDate 需要从 receipt 解析（V2 上服务端校验后做）
    final transactionDate = DateTime.tryParse(purchase.transactionDate ?? '') ??
        DateTime.now();
    final expiresAt = transactionDate.add(const Duration(days: 30));

    _eventsController.add(IapPurchasedEvent(
      productId: purchase.productID,
      expiresAt: expiresAt,
      transactionId: purchase.purchaseID ?? 'unknown',
      transactionDate: transactionDate,
    ));
  }

  /// UI 触发购买月度订阅
  /// 成功 / 失败 / 取消通过 events stream 通知
  /// 返回 true 表示购买请求已发出（不代表购买成功）
  Future<bool> buyMonthly() async {
    if (_products.isEmpty) {
      await _loadProducts();
    }
    if (_products.isEmpty) {
      _eventsController.add(
        IapErrorEvent('Product not loaded, please retry'),
      );
      return false;
    }
    final product = _products.firstWhere(
      (p) => p.id == AppConstants.monthlyProductId,
      orElse: () => throw StateError(
        'Product not loaded: ${AppConstants.monthlyProductId}',
      ),
    );
    final param = PurchaseParam(productDetails: product);
    return await InAppPurchase.instance
        .buyNonConsumable(purchaseParam: param);
  }

  /// UI 触发恢复购买
  /// 恢复结果通过 events stream 通知
  ///   - 有活跃订阅 → IapPurchasedEvent
  ///   - 没找到 → 不发事件（restorePurchases 默认行为）
  ///   - 错误 → IapErrorEvent
  Future<void> restore() async {
    try {
      await InAppPurchase.instance.restorePurchases();
    } catch (e) {
      _eventsController.add(IapErrorEvent('Restore exception: $e'));
    }
  }

  void dispose() {
    _purchaseSub?.cancel();
    _productsController.close();
    _eventsController.close();
  }
}
