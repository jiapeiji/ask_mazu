// lib/data/repositories/sign_repository.dart
// 签文仓储：加载 + 匹配

import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';

import '../models/fortune_sign.dart';
import '../../core/utils/result_templates.dart';

class SignRepository {
  List<FortuneSign>? _cache;

  /// 从 assets 加载 60 支签文
  Future<List<FortuneSign>> loadAll() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString('assets/data/signs.json');
    final list = (json.decode(raw) as List<dynamic>)
        .map((e) => FortuneSign.fromJson(e as Map<String, dynamic>))
        .toList();
    _cache = list;
    return list;
  }

  /// 时段划分（4 段 × 6 小时）
  /// - 晨 morning   5:00 - 11:00
  /// - 午 noon     11:00 - 17:00
  /// - 暮 evening  17:00 - 23:00
  /// - 夜 night    23:00 - 05:00
  String _timeSlot(DateTime date) {
    final h = date.hour;
    if (h >= 5 && h < 11) return 'morning';
    if (h >= 11 && h < 17) return 'noon';
    if (h >= 17 && h < 23) return 'evening';
    return 'night';
  }

  /// 圣杯匹配
  /// - 同一时段（4 段/天）同一用户同一类别 → 同一签（时段级一致性）
  /// - 跨时段必换签（一天最多 4 个不同签）
  /// - isCustom = true 时：忽略 category，走 [SignCategory.general] 通用签池
  ///   （用户输入自定义问题时用，签面/解曰宽泛，不绑死求职/感情/财运等场景）
  FortuneSign matchForSaint({
    required SignCategory category,
    required DateTime date,
    required String userId,
    required List<FortuneSign> allSigns,
    bool isCustom = false,
  }) {
    // 1. 筛选该类签文池（custom 模式 → general 池）
    final effectiveCategory = isCustom ? SignCategory.general : category;
    final pool = allSigns.where((s) => s.categories.contains(effectiveCategory)).toList();
    if (pool.isEmpty) {
      return allSigns[Random().nextInt(allSigns.length)];
    }

    // 2. 按等级加权
    final weighted = <FortuneSign>[];
    for (final sign in pool) {
      // 上上 10% / 上中 20% / 中上 30% / 中中 25% / 中下 10% / 下等 5%
      final weight = switch (sign.level) {
        FortuneLevel.upperUpper => 10,
        FortuneLevel.upperMid => 20,
        FortuneLevel.midUpper => 30,
        FortuneLevel.mid => 25,
        FortuneLevel.midLower => 10,
        FortuneLevel.lowerUpper => 3,
        FortuneLevel.lowerMid => 1,
        FortuneLevel.lowerLower => 1,
      };
      for (int i = 0; i < weight; i++) {
        weighted.add(sign);
      }
    }

    // 3. 用日期 + 时段 + 用户ID + 类别作种子
    //    跨时段换签；同一天同时段同用户同类别保持一致
    //    custom 模式用 'custom' 种子串，与 category 模式不互相串
    final dateKey = '${date.year}${date.month}${date.day}';
    final slot = _timeSlot(date);
    final seedKey = isCustom
        ? 'custom'
        : effectiveCategory.name;
    final random = Random('$dateKey$slot$userId$seedKey'.hashCode);

    return weighted[random.nextInt(weighted.length)];
  }

  /// 阴杯强制匹配下等签
  /// - isCustom = true 时：走 [SignCategory.general] 通用池
  FortuneSign matchForYin({
    required SignCategory category,
    required List<FortuneSign> allSigns,
    bool isCustom = false,
  }) {
    // custom 模式 → general 池；其他 → 走原 category 池
    final effectiveCategory = isCustom ? SignCategory.general : category;
    // 优先匹配下等签 + 该类别
    final pool = allSigns
        .where((s) => s.level.isLower && s.categories.contains(effectiveCategory))
        .toList();
    if (pool.isNotEmpty) {
      return pool[Random().nextInt(pool.length)];
    }
    // 兜底：随机下等签
    final fallback = allSigns.where((s) => s.level.isLower).toList();
    if (fallback.isNotEmpty) {
      return fallback[Random().nextInt(fallback.length)];
    }
    return allSigns[Random().nextInt(allSigns.length)];
  }

  /// 按 ID 查找
  FortuneSign? findById(int id, List<FortuneSign> allSigns) {
    try {
      return allSigns.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }

  /// 按 ID 列表查找（用于签文库展示）
  List<FortuneSign> findByIds(List<int> ids, List<FortuneSign> allSigns) {
    return ids
        .map((id) => findById(id, allSigns))
        .whereType<FortuneSign>()
        .toList();
  }
}
