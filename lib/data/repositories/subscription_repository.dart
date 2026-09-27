// lib/data/repositories/subscription_repository.dart
// 订阅状态持久化（SharedPreferences）
//
// 存：
//   - prefsAppFirstLaunchedAt  ISO8601 字符串（永久不变，setIfNull 一次）
//   - prefsSubscriptionState   JSON 字符串（更新频繁）
//
// 选 SharedPreferences 不选 Hive：
//   - 单条数据、键值对、无 list
//   - 跟 V0.1 usage 保持一致风格
//   - 启动预热更轻（不用 openBox 异步）

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../models/subscription_state.dart';

class SubscriptionRepository {
  SharedPreferences? _prefs;

  Future<SharedPreferences> _ensurePrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// 读 / 初始化「首次启动时间」
  /// - 无 → 写当前时间并返回
  /// - 有 → 直接返回
  Future<DateTime> getOrInitFirstLaunchedAt() async {
    final prefs = await _ensurePrefs();
    final existing = prefs.getString(AppConstants.prefsAppFirstLaunchedAt);
    if (existing != null) {
      return DateTime.parse(existing);
    }
    final now = DateTime.now();
    await prefs.setString(
      AppConstants.prefsAppFirstLaunchedAt,
      now.toIso8601String(),
    );
    return now;
  }

  /// 读订阅状态（无 → 返回 fresh，不返 null）
  /// 调用方永远拿到一个可用的 SubscriptionState
  Future<SubscriptionState> loadState(DateTime trialStartedAt) async {
    final prefs = await _ensurePrefs();
    final jsonStr = prefs.getString(AppConstants.prefsSubscriptionState);
    if (jsonStr == null) {
      return SubscriptionState.fresh(trialStartedAt);
    }
    try {
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      return SubscriptionState.fromJson(json);
    } catch (e) {
      // JSON 损坏（理论上不应发生）→ 退回 fresh，不影响用户
      return SubscriptionState.fresh(trialStartedAt);
    }
  }

  /// 写订阅状态
  Future<void> saveState(SubscriptionState state) async {
    final prefs = await _ensurePrefs();
    await prefs.setString(
      AppConstants.prefsSubscriptionState,
      jsonEncode(state.toJson()),
    );
  }

  /// 清空订阅状态（订阅到期 / 退款场景，外部逻辑决定何时调）
  Future<void> clearState() async {
    final prefs = await _ensurePrefs();
    await prefs.remove(AppConstants.prefsSubscriptionState);
  }
}
