// lib/data/repositories/settings_repository.dart
// App 设置持久化（声音、主题、首启引导标记等）

import 'package:hive/hive.dart';

import '../../core/constants/app_constants.dart';

class SettingsRepository {
  Box<dynamic>? _box;

  Future<Box<dynamic>> _ensureBox() async {
    _box ??= await Hive.openBox<dynamic>(AppConstants.settingsBox);
    return _box!;
  }

  // ====== 声音 ======
  static const String _kSoundEnabled = 'sound_enabled';        // 木块落地音
  static const String _kAmbientEnabled = 'ambient_enabled';    // 庙宇环境音
  static const String _kHapticEnabled = 'haptic_enabled';      // 震动反馈（预留）

  // ====== 主题 ======
  static const String _kThemeMode = 'theme_mode';              // 'light' / 'dark' / 'system'

  // ====== 首启 ======
  static const String _kFirstRunDone = 'first_run_done';       // 是否看过首启引导

  // ====== 声音 ======
  Future<bool> getSoundEnabled() async => (await _ensureBox()).get(_kSoundEnabled, defaultValue: true) as bool;
  Future<void> setSoundEnabled(bool v) async => (await _ensureBox()).put(_kSoundEnabled, v);

  Future<bool> getAmbientEnabled() async => (await _ensureBox()).get(_kAmbientEnabled, defaultValue: false) as bool;
  Future<void> setAmbientEnabled(bool v) async => (await _ensureBox()).put(_kAmbientEnabled, v);

  Future<bool> getHapticEnabled() async => (await _ensureBox()).get(_kHapticEnabled, defaultValue: true) as bool;
  Future<void> setHapticEnabled(bool v) async => (await _ensureBox()).put(_kHapticEnabled, v);

  // ====== 主题 ======
  Future<String> getThemeMode() async => (await _ensureBox()).get(_kThemeMode, defaultValue: 'light') as String;
  Future<void> setThemeMode(String v) async => (await _ensureBox()).put(_kThemeMode, v);

  // ====== 首启 ======
  Future<bool> getFirstRunDone() async => (await _ensureBox()).get(_kFirstRunDone, defaultValue: false) as bool;
  Future<void> setFirstRunDone(bool v) async => (await _ensureBox()).put(_kFirstRunDone, v);
}
