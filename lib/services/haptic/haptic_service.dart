// lib/services/haptic/haptic_service.dart
// 震动反馈服务（2026-09 接入）
// 调用前查 settings.hapticEnabled 决定是否真震(用户可在设置里关掉)

import 'package:flutter/services.dart';

class HapticService {
  /// 轻触反馈(投掷完成、订阅成功等轻量级反馈)
  Future<void> light() async {
    await HapticFeedback.lightImpact();
  }

  /// 中等反馈(预留)
  Future<void> medium() async {
    await HapticFeedback.mediumImpact();
  }
}
