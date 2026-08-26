// lib/providers/providers.dart
// 全局 Riverpod providers

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/sign_repository.dart';
import '../data/repositories/record_repository.dart';
import '../data/repositories/user_repository.dart';
import '../data/repositories/settings_repository.dart';
import '../services/usage/usage_service.dart';
import '../services/sound/sound_service.dart';
import '../data/models/user_profile.dart';
import '../data/models/question_record.dart';
import '../data/models/fortune_sign.dart';

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

final usageServiceProvider = Provider<UsageService>((ref) {
  return UsageService();
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository();
});

final soundServiceProvider = Provider<SoundService>((ref) {
  final svc = SoundService();
  ref.onDispose(svc.dispose);
  return svc;
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

/// 今日剩余次数
final remainingProvider = StateNotifierProvider<RemainingNotifier, AsyncValue<int>>((ref) {
  return RemainingNotifier(ref.read(usageServiceProvider));
});

class RemainingNotifier extends StateNotifier<AsyncValue<int>> {
  final UsageService _service;
  RemainingNotifier(this._service) : super(const AsyncValue.loading()) {
    _load();
  }

  Future<int> getRemaining({bool isSubscribed = false}) async {
    final remaining = await _service.getRemaining(isSubscribed: isSubscribed);
    state = AsyncValue.data(remaining);
    return remaining;
  }

  Future<void> _load({bool isSubscribed = false}) async {
    state = const AsyncValue.loading();
    final remaining = await _service.getRemaining(isSubscribed: isSubscribed);
    state = AsyncValue.data(remaining);
  }

  Future<bool> consume({bool isSubscribed = false}) async {
    final ok = await _service.consume(isSubscribed: isSubscribed);
    if (ok) {
      await _load(isSubscribed: isSubscribed);
    }
    return ok;
  }

  Future<void> reset() async {
    await _service.reset();
    await _load();
  }
}

/// 订阅状态（V1 接 Apple StoreKit，V0.1 先做本地状态）
/// Debug 模式下默认开启，方便开发测试无限次数/完整签文库。
/// Release 模式默认 false。也可以在 settings 页面手动 toggle 覆盖。
final isSubscribedProvider = StateProvider<bool>((ref) {
  if (kDebugMode) return true;
  return false;
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

  SettingsNotifier(this._repo) : super(const AppSettings(
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
    // 同步控制 sound service
    // （实际有资源时，这里调 soundService.startAmbient/stopAmbient）
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
  return SettingsNotifier(ref.read(settingsRepositoryProvider));
});
