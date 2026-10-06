// lib/core/constants/app_constants.dart
// 全局常量
//
// V1.2 (v5) 改动:
//   - 删除试用期 / 订阅产品 ID / 订阅状态 prefs key
//   - version 改 1.2.0

class AppConstants {
  AppConstants._();

  // App 信息
  static const String appName = '问妈祖';
  static const String appNameEn = 'Ask Mazu';
  static const String appSubtitle = '妈祖文化传承 · 每日反思';
  static const String version = '1.2.0';

  // 物理参数
  static const double throwGravity = 9.8;
  static const double throwInitialSpeedMin = 8.0;
  static const double throwInitialSpeedMax = 12.0;
  static const double throwInitialAngularMin = 4.0;
  static const double throwInitialAngularMax = 8.0;
  static const double throwAnimationDuration = 2.5;

  // Hive box 名
  static const String userBox = 'user_box';
  static const String recordBox = 'record_box';
  static const String settingsBox = 'settings_box';

  // SharedPreferences 键
  static const String prefsAppFirstLaunchedAt = 'app_first_launched_at';
}
