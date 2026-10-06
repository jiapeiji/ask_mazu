// lib/core/router/app_router.dart
// 路由(V1.2 加 3 tab ShellRoute)
//
// V1.2 (v5) 改动:
//   - /home → /reflect(路径改名)
//   - /history → /records(路径改名)
//   - 加 /mazu(占位页)
//   - 3 个 tab 页包在 ShellRoute(底部 tab bar 由 MainShell 提供)
//   - /throw /result /signs /settings 仍是顶层路由(modal / push 上来的页)
//
// 资产(无新增,复用 router、IML)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/main_shell.dart';
import '../../features/onboarding/onboarding_page.dart';
import '../../features/home/home_page.dart';
import '../../features/throw/throw_page.dart';
import '../../features/result/result_page.dart';
import '../../features/signs/signs_library_page.dart';
import '../../features/records/records_page.dart';
import '../../features/mazu/mazu_placeholder_page.dart';
import '../../features/settings/settings_page.dart';
import '../../data/models/fortune_sign.dart';
import '../../data/models/user_profile.dart';
import '../../core/utils/result_templates.dart';
import '../../providers/providers.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // user 状态变化时让 GoRouter 重新跑 redirect
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
      if (userLoading) return null;
      final isOnboarding = state.matchedLocation == '/onboarding';
      if (user == null && !isOnboarding) return '/onboarding';
      if (user != null && isOnboarding) return '/reflect';
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        redirect: (_, __) => '/reflect',
      ),
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const OnboardingPage(),
      ),

      // ═══ 3 tab ShellRoute(底部 tab 由 MainShell 提供)═══
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/reflect',
            builder: (_, __) => const HomePage(),
          ),
          GoRoute(
            path: '/records',
            builder: (_, __) => const RecordsPage(),
          ),
          GoRoute(
            path: '/mazu',
            builder: (_, __) => const MazuPlaceholderPage(),
          ),
        ],
      ),

      // ═══ 顶层路由(modal / push 上来的页)═══
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
          return NoTransitionPage(
            key: state.pageKey,
            child: ResultPage(
              result: extra['result'] as ThrowResultType,
              sign: extra['sign'] as FortuneSign?,
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
        path: '/settings',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SettingsPage(),
          transitionDuration: const Duration(milliseconds: 350),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(-1, 0),
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