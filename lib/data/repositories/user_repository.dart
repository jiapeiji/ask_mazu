// lib/data/repositories/user_repository.dart
// 用户报家门信息仓储

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

  Future<UserProfile?> get() async {
    final box = await _ensureBox();
    return box.get(userKey);
  }

  Future<void> save(UserProfile profile) async {
    final box = await _ensureBox();
    await box.put(userKey, profile);
  }

  Future<void> update({String? name, String? city}) async {
    final current = await get();
    if (current == null) return;
    await save(current.copyWith(name: name, city: city));
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
