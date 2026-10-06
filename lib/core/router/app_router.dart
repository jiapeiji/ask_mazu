// lib/core/router/app_router.dart
// 路由

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/onboarding/onboarding_page.dart';
import '../../features/home/home_page.dart';
import '../../features/throw/throw_page.dart';
import '../../features/result/result_page.dart';
import '../../features/signs/signs_library_page.dart';
import '../../features/history/history_page.dart';
import '../../features/settings/settings_page.dart';
import '../../data/models/fortune_sign.dart';
import '../../data/models/user_profile.dart';
import '../../core/utils/result_templates.dart';
import '../../providers/providers.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // user 状态变化时让 GoRouter 重新跑 redirect
  // 场景：app 冷启动 → currentUserProvider 还在 loading → redirect 第一次跑时 return null →
  //   user 加载完触发 refresh → redirect 再跑 → 跳 /onboarding
  // 没这个 refresh 的话，loading 时放过路由 + user 加载完 router 不重跑 = 永远卡首页
  final refreshListenable = ValueNotifier<int>(0);
  ref.listen<AsyncValue<UserProfile?>>(
    currentUserProvider,
    (_, __) => refreshListenable.value++,
  );

  return GoRouter(
    initialLocation: '/',
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      final user = ref.read(currentUserProvider).valueOrNull;
      final userLoading = ref.read(currentUserProvider).isLoading;
      if (userLoading) return null;  // 还在加载中先放过，user 加载完 refresh 会再跑
      final isOnboarding = state.matchedLocation == '/onboarding';
      if (user == null && !isOnboarding) return '/onboarding';
      if (user != null && isOnboarding) return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        redirect: (_, __) => '/home',
      ),
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const OnboardingPage(),
      ),
      GoRoute(
        path: '/home',
        builder: (_, __) => const HomePage(),
      ),
      GoRoute(
        path: '/throw',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return ThrowPage(
            category: extra['category'] as SignCategory,
            question: extra['question'] as String,
          );
        },
      ),
      GoRoute(
        path: '/result',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          // 用 NoTransitionPage，push/pop 都不带动画
          // result page 内部自己用 AnimationController 跑 slide out
          return NoTransitionPage(
            key: state.pageKey,
            child: ResultPage(
              result: extra['result'] as ThrowResultType,
              sign: extra['sign'] as FortuneSign?,
              category: extra['category'] as SignCategory,
              question: extra['question'] as String,
            ),
          );
        },
      ),
      GoRoute(
        path: '/signs',
        builder: (_, __) => const SignsLibraryPage(),
      ),
      GoRoute(
        path: '/history',
        builder: (_, __) => const HistoryPage(),
      ),
      GoRoute(
        path: '/settings',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SettingsPage(),
          transitionDuration: const Duration(milliseconds: 350),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(-1, 0),  // 从左往右滑入（按钮在左上）
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
              child: child,
            );
          },
        ),
      ),
    ],
  );
});
