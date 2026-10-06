// lib/data/repositories/record_repository.dart
// 问事记录仓储

import 'package:hive/hive.dart';

import '../models/question_record.dart';
import '../../core/constants/app_constants.dart';

class RecordRepository {
  Box<QuestionRecord>? _box;

  /// 清缓存的 box 引用(账号删除后 Hive 磁盘文件已删,内存里 _box 指向失效引用)
  void clearCache() {
    _box = null;
  }

  Future<Box<QuestionRecord>> _ensureBox() async {
    _box ??= await Hive.openBox<QuestionRecord>(AppConstants.recordBox);
    return _box!;
  }

  Future<void> add(QuestionRecord record) async {
    final box = await _ensureBox();
    await box.put(record.id, record);
  }

  Future<List<QuestionRecord>> getAll({int? limit}) async {
    final box = await _ensureBox();
    final records = box.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    if (limit != null) return records.take(limit).toList();
    return records;
  }

  Future<List<QuestionRecord>> getRecent(int days) async {
    final box = await _ensureBox();
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return box.values
        .where((r) => r.timestamp.isAfter(cutoff))
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  /// 计算连续记录天数(V1.2 月历/连续 banner 用)
  /// 从今天往前数:每天只能有 0 或 1 条记录
  /// - 今天有 → 连续计数从 1 开始
  /// - 今天没 → 连续计数从 0(最近一次连续断)
  Future<int> getStreak() async {
    final records = await getAll();
    if (records.isEmpty) return 0;

    // 按天聚合(只取日期,忽略时分秒)
    final dayKeys = <String>{};
    for (final r in records) {
      final t = r.timestamp;
      dayKeys.add('${t.year}-${t.month.toString().padLeft(2, '0')}-${t.day.toString().padLeft(2, '0')}');
    }

    final today = DateTime.now();
    var cursor = DateTime(today.year, today.month, today.day);
    var count = 0;

    // 检查今天
    final todayKey = '${cursor.year}-${cursor.month.toString().padLeft(2, '0')}-${cursor.day.toString().padLeft(2, '0')}';
    if (dayKeys.contains(todayKey)) {
      count = 1;
      cursor = cursor.subtract(const Duration(days: 1));
    } else {
      // 今天没记,但允许"昨天是连续的"
      cursor = cursor.subtract(const Duration(days: 1));
    }

    while (true) {
      final key = '${cursor.year}-${cursor.month.toString().padLeft(2, '0')}-${cursor.day.toString().padLeft(2, '0')}';
      if (dayKeys.contains(key)) {
        count += 1;
        cursor = cursor.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return count;
  }

  /// 给定日期的当日记录(0 或 1 条)
  Future<QuestionRecord?> getByDate(DateTime date) async {
    final records = await getAll();
    final d = DateTime(date.year, date.month, date.day);
    final next = d.add(const Duration(days: 1));
    for (final r in records) {
      if (!r.timestamp.isBefore(d) && r.timestamp.isBefore(next)) {
        return r;
      }
    }
    return null;
  }

  Future<void> delete(String id) async {
    final box = await _ensureBox();
    await box.delete(id);
  }

  Future<void> clear() async {
    final box = await _ensureBox();
    await box.clear();
  }
}
