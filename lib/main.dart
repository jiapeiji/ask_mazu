// lib/main.dart
// 启动入口

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'core/constants/app_constants.dart';
import 'data/models/hive_adapters.dart';
import 'data/models/user_profile.dart';
import 'data/repositories/user_repository.dart';
import 'providers/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化 Hive
  await Hive.initFlutter();
  Hive.registerAdapter(UserProfileAdapter());
  Hive.registerAdapter(QuestionRecordAdapter());

  // 预热 user box + 读 initial user，让 currentUserProvider 启动时直接是 data（不是 loading）
  // 效果：router redirect 第一次跑就能拿到 user，零闪屏进 /onboarding 或 /home
  final userBox = await Hive.openBox<UserProfile>(AppConstants.userBox);
  final initialUser = userBox.get(UserRepository.userKey);

  runApp(
    ProviderScope(
      overrides: [
        currentUserProvider.overrideWith(
          (ref) => CurrentUserNotifier(
            ref.read(userRepositoryProvider),
            initialUser: initialUser,
          ),
        ),
      ],
      child: const AskMazuApp(),
    ),
  );
}
