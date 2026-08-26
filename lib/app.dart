// lib/app.dart
// App 入口

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'l10n/generated/app_localizations.dart';
import 'providers/providers.dart';

/// Maps a stored locale code ('zh_CN' / 'zh_TW' / 'en') to a Flutter [Locale].
Locale localeFromCode(String code) {
  switch (code) {
    case 'zh_TW':
      return const Locale('zh', 'TW');
    case 'en':
      return const Locale('en');
    case 'zh_CN':
    default:
      return const Locale('zh', 'CN');
  }
}

class AskMazuApp extends ConsumerWidget {
  const AskMazuApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final settings = ref.watch(settingsProvider);
    return MaterialApp.router(
      title: '问妈祖',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: settings.themeMode,
      // 跟着用户在设置里选的语言走（'zh_CN' / 'zh_TW' / 'en'）
      locale: localeFromCode(settings.localeCode),
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
