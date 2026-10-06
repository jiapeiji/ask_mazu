// lib/data/repositories/user_repository.dart
// 用户报家门信息仓储
//
// V1.2 (v5):update() 删 city 参数。

import 'package:hive/hive.dart';

import '../models/user_profile.dart';
import '../../core/constants/app_constants.dart';

class UserRepository {
  Box<UserProfile>? _box;

  Future<Box<UserProfile>> _ensureBox() async {
    _box ??= await Hive.openBox<UserProfile>(AppConstants.userBox);
    return _box!;
  }

  static const String userKey = 'current_user';

  /// 清缓存的 box 引用(账号删除后 Hive 磁盘文件已删,内存里 _box 指向失效引用)
  /// 不 close,让 Hive 内部 GC,下次 _ensureBox 会重新 open
  void clearCache() {
    _box = null;
  }

  Future<UserProfile?> get() async {
    final box = await _ensureBox();
    return box.get(userKey);
  }

  Future<void> save(UserProfile profile) async {
    final box = await _ensureBox();
    await box.put(userKey, profile);
  }

  Future<void> update({String? name}) async {
    final current = await get();
    if (current == null) return;
    await save(current.copyWith(name: name));
  }

  Future<void> clear() async {
    final box = await _ensureBox();
    await box.delete(userKey);
  }

  /// 是否已完成报家门
  Future<bool> hasOnboarded() async {
    return (await get()) != null;
  }
}
