// lib/main.dart
// 启动入口

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'core/constants/app_constants.dart';
import 'data/models/hive_adapters.dart';
import 'data/models/user_profile.dart';
import 'data/repositories/subscription_repository.dart';
import 'data/repositories/user_repository.dart';
import 'services/subscription/iap_service.dart';
import 'services/subscription/subscription_service.dart';
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

  // 预热 subscription state（首次启动会写入 firstLaunchedAt）
  // 效果：home_page 第一次 build 就能拿到 SubscriptionState（trialActive）
  final subscriptionRepo = SubscriptionRepository();
  final subscriptionService = SubscriptionService(subscriptionRepo);
  final initialSubscriptionState = await subscriptionService.initialize();

  // 初始化 IAP（注册 purchase stream + 拉产品）
  // 不 await init 内部不阻塞启动：queryProduct 失败是常见情况，UI 显示"加载中"就行
  // iOS 沙盒/真机都能跑；Android 同样接口
  final iapService = IapService();
  unawaited(iapService.init());

  runApp(
    ProviderScope(
      overrides: [
        currentUserProvider.overrideWith(
          (ref) => CurrentUserNotifier(
            ref.read(userRepositoryProvider),
            initialUser: initialUser,
          ),
        ),
        subscriptionStateProvider.overrideWith(
          (ref) => SubscriptionStateNotifier(
            ref.read(subscriptionServiceProvider),
            initialState: initialSubscriptionState,
          ),
        ),
        iapServiceProvider.overrideWithValue(iapService),
      ],
      child: const AskMazuApp(),
    ),
  );
}
