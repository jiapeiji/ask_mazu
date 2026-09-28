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

  Future<void> delete(String id) async {
    final box = await _ensureBox();
    await box.delete(id);
  }

  Future<void> clear() async {
    final box = await _ensureBox();
    await box.clear();
  }
}
