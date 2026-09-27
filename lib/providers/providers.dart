// lib/providers/providers.dart
// 全局 Riverpod providers

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/subscription_state.dart';
import '../data/models/user_profile.dart';
import '../data/models/question_record.dart';
import '../data/models/fortune_sign.dart';
import '../data/repositories/sign_repository.dart';
import '../data/repositories/record_repository.dart';
import '../data/repositories/user_repository.dart';
import '../data/repositories/settings_repository.dart';
import '../data/repositories/subscription_repository.dart';
import '../services/subscription/iap_service.dart';
import '../services/subscription/subscription_service.dart';
import '../services/sound/sound_service.dart';
import '../services/haptic/haptic_service.dart';

// ============ Repositories ============

final signRepositoryProvider = Provider<SignRepository>((ref) {
  return SignRepository();
});

final recordRepositoryProvider = Provider<RecordRepository>((ref) {
  return RecordRepository();
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository();
});

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  return SubscriptionRepository();
});

final subscriptionServiceProvider = Provider<SubscriptionService>((ref) {
  return SubscriptionService(ref.read(subscriptionRepositoryProvider));
});

/// IAP 服务（iOS StoreKit / Android Billing 封装）
/// 单例，启动时由 main.dart 调 init() 初始化
final iapServiceProvider = Provider<IapService>((ref) {
  final svc = IapService();
  ref.onDispose(svc.dispose);
  return svc;
});

/// 当前产品价格（从 IAP 拉到的真实本地化价格）
/// null = 还在加载 / 加载失败
final productPriceProvider = StateProvider<ProductPrice?>((ref) {
  return null;
});

/// 价格信息（产品 ID + 本地化价格字符串）
class ProductPrice {
  final String productId;
  final String displayPrice;
  final String title;
  final String description;
  const ProductPrice({
    required this.productId,
    required this.displayPrice,
    required this.title,
    required this.description,
  });
}

final soundServiceProvider = Provider<SoundService>((ref) {
  final svc = SoundService();
  ref.onDispose(svc.dispose);
  return svc;
});

/// 震动反馈服务(2026-09 接入)
final hapticServiceProvider = Provider<HapticService>((ref) {
  return HapticService();
});

// ============ Data ============

/// 签文库（一次性加载）
final signsProvider = FutureProvider<List<FortuneSign>>((ref) async {
  return ref.read(signRepositoryProvider).loadAll();
});

/// 当前用户
final currentUserProvider = StateNotifierProvider<CurrentUserNotifier, AsyncValue<UserProfile?>>((ref) {
  return CurrentUserNotifier(ref.read(userRepositoryProvider));
});

class CurrentUserNotifier extends StateNotifier<AsyncValue<UserProfile?>> {
  final UserRepository _repo;
  /// 初始 user（main.dart 预热 Hive 后从 box 直接读出来，绕过 loading 状态）
  /// null 表示无 user（首次安装），非 null 表示已报家门
  CurrentUserNotifier(this._repo, {UserProfile? initialUser})
      : super(AsyncValue.data(initialUser));

  /// 重新从 Hive 加载（用于 update 后刷新 state；首次启动不需要，主入口已预热）
  Future<void> _load() async {
    try {
      final user = await _repo.get();
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> save(String name, String city) async {
    final profile = UserProfile(
      name: name,
      city: city,
      createdAt: DateTime.now(),
    );
    await _repo.save(profile);
    state = AsyncValue.data(profile);
  }

  Future<void> update({String? name, String? city}) async {
    await _repo.update(name: name, city: city);
    await _load();
  }

  Future<void> clear() async {
    await _repo.clear();
    state = const AsyncValue.data(null);
  }
}

/// 问事记录
final recordsProvider = StateNotifierProvider<RecordsNotifier, AsyncValue<List<QuestionRecord>>>((ref) {
  return RecordsNotifier(ref.read(recordRepositoryProvider));
});

class RecordsNotifier extends StateNotifier<AsyncValue<List<QuestionRecord>>> {
  final RecordRepository _repo;
  RecordsNotifier(this._repo) : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    state = const AsyncValue.loading();
    try {
      final records = await _repo.getAll();
      state = AsyncValue.data(records);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> add(QuestionRecord record) async {
    await _repo.add(record);
    await _load();
  }

  Future<void> delete(String id) async {
    await _repo.delete(id);
    await _load();
  }

  Future<void> clear() async {
    await _repo.clear();
    state = const AsyncValue.data([]);
  }
}

// ============ Subscription（V1 状态机）============

/// 订阅状态（5 态：trialActive / trialLastDay / trialExpired / subscribed / subExpired）
/// main.dart 启动时预热，初始 state 直接是 data（无 loading）
final subscriptionStateProvider =
    StateNotifierProvider<SubscriptionStateNotifier, SubscriptionState>((ref) {
  return SubscriptionStateNotifier(ref.read(subscriptionServiceProvider));
});

class SubscriptionStateNotifier extends StateNotifier<SubscriptionState> {
  final SubscriptionService _service;

  SubscriptionStateNotifier(this._service, {SubscriptionState? initialState})
      : super(initialState ?? SubscriptionState.fresh(DateTime.now()));

  /// 重新拉取（用于 M5 接 IAP 后处理 Receipt 刷新 / 跨设备同步 / 启动核对）
  /// 计算逻辑都在 SubscriptionState model 的 getter 里，这里只是「重新计算并触发 UI 更新」
  Future<void> refresh() async {
    // 模型 getter 已经是基于 DateTime.now() 算的，
    // 重新构造一个 state（值不变）就能让 Riverpod 通知所有监听者
    state = state.copyWith();
  }

  /// M5 接 IAP 后用：订阅成功 / 自动续期
  Future<void> updateSubscription({
    required DateTime expiresAt,
    required String originalTransactionId,
  }) async {
    state = await _service.updateSubscription(
      expiresAt: expiresAt,
      originalTransactionId: originalTransactionId,
    );
  }

  /// 恢复购买
  /// - M2: store 没东西可恢复，返 null
  /// - M3 接 IAP 后：参数由 InAppPurchase.restorePurchases() 返回的 active entitlement 提供
  /// - 返回 null 表示没找到；返回 state 表示已恢复
  Future<SubscriptionState?> tryRestore() async {
    final restored = await _service.restore();
    if (restored != null) {
      state = restored;
    }
    return restored;
  }

  /// M5 用：订阅到期 / 退款
  Future<void> clearSubscription() async {
    state = await _service.clearSubscription();
  }

  /// Debug 用：覆盖 state（settings 页面调试区块 toggle 调它）
  /// - mode == 'unlimited' → 模拟订阅中（未来 30 天到期）
  /// - mode == 'expired'   → 模拟 trial_expired（fresh 状态）
  /// - mode == 'fresh'     → 强制重置 trialStartedAt 为现在
  Future<void> debugSetMode(String mode) async {
    if (!kDebugMode) return;
    final now = DateTime.now();
    switch (mode) {
      case 'unlimited':
        state = SubscriptionState(
          trialStartedAt: state.trialStartedAt,
          subscriptionExpiresAt: now.add(const Duration(days: 30)),
          originalTransactionId: 'debug-mock-${now.millisecondsSinceEpoch}',
        );
        break;
      case 'expired':
        // 把 trialStartedAt 推到 4 天前 → 自动 trial_expired
        state = SubscriptionState(
          trialStartedAt: now.subtract(const Duration(days: 4)),
        );
        break;
      case 'fresh':
        // 重置 trialStartedAt 为现在（用于重置试用）
        state = SubscriptionState.fresh(now);
        break;
    }
  }
}

/// 派生：是否享有 unlimited 权限（投掷 / 完整签文库 / 庙宇环境音）
/// 直接读 state.hasUnlimitedAccess，但这里暴露成独立 provider 方便 UI 用 ref.watch
final hasUnlimitedAccessProvider = Provider<bool>((ref) {
  return ref.watch(subscriptionStateProvider).hasUnlimitedAccess;
});

// ============ Settings (持久化到 Hive) ============

class AppSettings {
  final ThemeMode themeMode;
  final bool soundEnabled;
  final bool ambientEnabled;
  final bool hapticEnabled;
  final bool firstRunDone;
  final String localeCode; // 'zh_CN' / 'zh_TW' / 'en'

  const AppSettings({
    required this.themeMode,
    required this.soundEnabled,
    required this.ambientEnabled,
    required this.hapticEnabled,
    required this.firstRunDone,
    required this.localeCode,
  });

  AppSettings copyWith({
    ThemeMode? themeMode,
    bool? soundEnabled,
    bool? ambientEnabled,
    bool? hapticEnabled,
    bool? firstRunDone,
    String? localeCode,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      ambientEnabled: ambientEnabled ?? this.ambientEnabled,
      hapticEnabled: hapticEnabled ?? this.hapticEnabled,
      firstRunDone: firstRunDone ?? this.firstRunDone,
      localeCode: localeCode ?? this.localeCode,
    );
  }
}

ThemeMode _parseThemeMode(String s) {
  switch (s) {
    case 'dark':
      return ThemeMode.dark;
    case 'system':
      return ThemeMode.system;
    default:
      return ThemeMode.light;
  }
}

String _themeModeToString(ThemeMode m) {
  switch (m) {
    case ThemeMode.dark:
      return 'dark';
    case ThemeMode.system:
      return 'system';
    case ThemeMode.light:
      return 'light';
  }
}

class SettingsNotifier extends StateNotifier<AppSettings> {
  final SettingsRepository _repo;
  final Ref _ref;  // 用来读 soundServiceProvider(2026-09 接入音频)

  SettingsNotifier(this._repo, this._ref) : super(const AppSettings(
          themeMode: ThemeMode.light,
          soundEnabled: true,
          ambientEnabled: false,
          hapticEnabled: true,
          firstRunDone: false,
          localeCode: 'zh_CN',
        )) {
    _load();
  }

  Future<void> _load() async {
    state = AppSettings(
      themeMode: _parseThemeMode(await _repo.getThemeMode()),
      soundEnabled: await _repo.getSoundEnabled(),
      ambientEnabled: await _repo.getAmbientEnabled(),
      hapticEnabled: await _repo.getHapticEnabled(),
      firstRunDone: await _repo.getFirstRunDone(),
      localeCode: await _repo.getLocaleCode(),
    );
  }

  Future<void> setThemeMode(ThemeMode m) async {
    state = state.copyWith(themeMode: m);
    await _repo.setThemeMode(_themeModeToString(m));
  }

  Future<void> setSoundEnabled(bool v) async {
    state = state.copyWith(soundEnabled: v);
    await _repo.setSoundEnabled(v);
  }

  Future<void> setAmbientEnabled(bool v) async {
    state = state.copyWith(ambientEnabled: v);
    await _repo.setAmbientEnabled(v);
    // 同步控制 sound service(2026-09 接入真实音频)
    final svc = _ref.read(soundServiceProvider);
    if (v) {
      await svc.startAmbient();
    } else {
      await svc.stopAmbient();
    }
  }

  Future<void> setHapticEnabled(bool v) async {
    state = state.copyWith(hapticEnabled: v);
    await _repo.setHapticEnabled(v);
  }

  Future<void> markFirstRunDone() async {
    state = state.copyWith(firstRunDone: true);
    await _repo.setFirstRunDone(true);
  }

  Future<void> setLocaleCode(String code) async {
    state = state.copyWith(localeCode: code);
    await _repo.setLocaleCode(code);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier(ref.read(settingsRepositoryProvider), ref);
});
