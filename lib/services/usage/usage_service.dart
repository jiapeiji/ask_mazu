// lib/services/usage/usage_service.dart
// 限次逻辑

import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';

class UsageService {
  Box<String>? _box;
  SharedPreferences? _prefs;

  Future<SharedPreferences> _ensurePrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<Box<String>> _ensureBox() async {
    _box ??= await Hive.openBox<String>(AppConstants.usageBox);
    return _box!;
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }

  /// 今日已用次数
  Future<int> getTodayUsed() async {
    final prefs = await _ensurePrefs();
    return prefs.getInt('usage_$_todayKey') ?? 0;
  }

  /// 今日剩余次数
  /// -1 表示无限（订阅）
  Future<int> getRemaining({required bool isSubscribed}) async {
    if (isSubscribed) return -1;
    final used = await getTodayUsed();
    return (AppConstants.freeDailyLimit - used).clamp(0, AppConstants.freeDailyLimit);
  }

  /// 消耗一次
  Future<bool> consume({required bool isSubscribed}) async {
    if (isSubscribed) return true;
    final prefs = await _ensurePrefs();
    final used = await getTodayUsed();
    if (used >= AppConstants.freeDailyLimit) return false;
    await prefs.setInt('usage_$_todayKey', used + 1);
    return true;
  }

  /// 重置今日次数（仅用于测试）
  Future<void> reset() async {
    final prefs = await _ensurePrefs();
    await prefs.remove('usage_$_todayKey');
  }
}
