// lib/core/constants/app_constants.dart
// 全局常量

class AppConstants {
  AppConstants._();

  // App 信息
  static const String appName = '问妈祖';
  static const String appNameEn = 'Ask Mazu';
  static const String appSubtitle = '每日一问，妈祖指引';
  static const String version = '0.1.0';

  // 业务常量
  static const int freeDailyLimit = 3;
  static const int freeSignsLimit = 30;

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
  static const String usageBox = 'usage_box';

  // 订阅产品 ID
  static const String monthlyProductId = 'mazu_monthly';
  static const String yearlyProductId = 'mazu_yearly';
}
