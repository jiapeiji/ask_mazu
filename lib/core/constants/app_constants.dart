// lib/core/constants/app_constants.dart
// 全局常量

class AppConstants {
  AppConstants._();

  // App 信息
  static const String appName = '问妈祖';
  static const String appNameEn = 'Ask Mazu';
  static const String appSubtitle = '每日一问，妈祖指引';
  static const String version = '0.1.0';

  // 试用期（首次启动起算，3 个自然日）
  static const Duration trialPeriod = Duration(days: 3);

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

  // 订阅产品 ID（V1 上架前会在 App Store Connect 创建）
  static const String monthlyProductId = 'mazu_monthly';
  static const String yearlyProductId = 'mazu_yearly';

  // SharedPreferences 键
  // 试用起算：app 首次启动时间，存 ISO8601 字符串（永久不变）
  static const String prefsAppFirstLaunchedAt = 'app_first_launched_at';
  // 订阅状态：JSON 字符串（含 subscriptionExpiresAt / originalTransactionId）
  static const String prefsSubscriptionState = 'subscription_state_json';
}
