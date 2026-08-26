// lib/features/settings/settings_page.dart
// 设置页

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/providers.dart';
import 'about_dialogs.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final user = ref.watch(currentUserProvider).valueOrNull;
    final isSubscribed = ref.watch(isSubscribedProvider);
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.riceWhite,
      appBar: AppBar(
        title: Text(l.settingsTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          // 报家门信息
          _buildSection(
            context: context,
            title: l.settingsSectionProfile,
            children: [
              ListTile(
                leading: const Icon(Icons.person_outline, color: AppColors.mazuRed),
                title: Text(user?.name ?? l.settingsProfileUnset),
                subtitle: Text(user?.city ?? ''),
                trailing: const Icon(Icons.chevron_right, color: AppColors.gray),
                onTap: () => _showEditProfileDialog(context, ref),
              ),
            ],
          ),
          // 语言
          _buildSection(
            context: context,
            title: l.settingsSectionLanguage,
            children: [
              _buildLanguageTile(
                context: context,
                ref: ref,
                code: 'zh_CN',
                label: l.settingsLanguageZhCn,
                groupValue: settings.localeCode,
              ),
              _buildLanguageTile(
                context: context,
                ref: ref,
                code: 'zh_TW',
                label: l.settingsLanguageZhTw,
                groupValue: settings.localeCode,
              ),
              _buildLanguageTile(
                context: context,
                ref: ref,
                code: 'en',
                label: l.settingsLanguageEn,
                groupValue: settings.localeCode,
              ),
            ],
          ),
          // 声音
          _buildSection(
            context: context,
            title: l.settingsSectionSound,
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.volume_up, color: AppColors.mazuRed),
                title: Text(l.settingsSoundBlockTitle),
                subtitle: Text(l.settingsSoundBlockDesc, style: const TextStyle(fontSize: 12)),
                value: settings.soundEnabled,
                onChanged: (v) => notifier.setSoundEnabled(v),
              ),
              SwitchListTile(
                secondary: Icon(
                  Icons.music_note,
                  color: isSubscribed ? AppColors.mazuRed : AppColors.gray,
                ),
                title: Row(
                  children: [
                    Text(l.settingsSoundAmbientTitle),
                    if (!isSubscribed) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.goldYellow,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          l.settingsSoundBadge,
                          style: const TextStyle(fontSize: 10, color: Colors.white),
                        ),
                      ),
                    ],
                  ],
                ),
                subtitle: Text(
                  isSubscribed
                      ? l.settingsSoundAmbientActive
                      : l.settingsSoundAmbientLocked,
                  style: const TextStyle(fontSize: 12),
                ),
                value: isSubscribed ? settings.ambientEnabled : false,
                onChanged: isSubscribed
                    ? (v) => notifier.setAmbientEnabled(v)
                    : null,
              ),
              SwitchListTile(
                secondary: const Icon(Icons.vibration, color: AppColors.mazuRed),
                title: Text(l.settingsSoundHapticTitle),
                subtitle: Text(l.settingsSoundHapticDesc, style: const TextStyle(fontSize: 12)),
                value: settings.hapticEnabled,
                onChanged: (v) => notifier.setHapticEnabled(v),
              ),
            ],
          ),
          // 订阅
          _buildSection(
            context: context,
            title: l.settingsSectionSubscription,
            children: [
              ListTile(
                leading: Icon(
                  isSubscribed ? Icons.workspace_premium : Icons.workspace_premium_outlined,
                  color: isSubscribed ? AppColors.goldYellow : AppColors.gray,
                ),
                title: Text(isSubscribed ? l.settingsSubActive : l.settingsSubInactive),
                subtitle: Text(
                  isSubscribed
                      ? l.settingsSubActiveDesc
                      : l.settingsSubInactiveDesc,
                ),
                trailing: isSubscribed ? null : const Icon(Icons.chevron_right),
                onTap: isSubscribed
                    ? null
                    : () => _showSubscriptionDialog(context, l),
              ),
            ],
          ),
          // 签文库 + 历史
          _buildSection(
            context: context,
            title: l.settingsSectionView,
            children: [
              ListTile(
                leading: const Icon(Icons.history, color: AppColors.mazuRed),
                title: Text(l.settingsViewHistory),
                trailing: const Icon(Icons.chevron_right, color: AppColors.gray),
                onTap: () => context.push('/history'),
              ),
            ],
          ),
          // 关于
          _buildSection(
            context: context,
            title: l.settingsSectionAbout,
            children: [
              ListTile(
                leading: const Icon(Icons.info_outline, color: AppColors.gray),
                title: Text(l.settingsAboutMazu),
                trailing: const Icon(Icons.chevron_right, color: AppColors.gray),
                onTap: () => AboutDialogs.showAboutMazu(context),
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined, color: AppColors.gray),
                title: Text(l.settingsPrivacy),
                trailing: const Icon(Icons.chevron_right, color: AppColors.gray),
                onTap: () => AboutDialogs.showPrivacyPolicy(context),
              ),
              ListTile(
                leading: const Icon(Icons.description_outlined, color: AppColors.gray),
                title: Text(l.settingsTerms),
                trailing: const Icon(Icons.chevron_right, color: AppColors.gray),
                onTap: () => AboutDialogs.showTermsOfService(context),
              ),
              ListTile(
                leading: const Icon(Icons.app_settings_alt, color: AppColors.gray),
                title: Text(l.settingsAboutApp),
                subtitle: const Text('v0.1.0 · 2026-08'),
                trailing: const Icon(Icons.chevron_right, color: AppColors.gray),
                onTap: () => AboutDialogs.showAboutApp(context),
              ),
            ],
          ),
          // 调试开关（仅 debug build 可见，release 自动消失）
          if (kDebugMode)
            _buildSection(
              context: context,
              title: l.settingsSectionDebug,
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.bug_report, color: AppColors.warningRed),
                  title: Text(l.settingsDebugMockSub),
                  subtitle: Text(l.settingsDebugMockSubDesc),
                  value: isSubscribed,
                  onChanged: (v) {
                    ref.read(isSubscribedProvider.notifier).state = v;
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.refresh, color: AppColors.gray),
                  title: Text(l.settingsDebugResetToday),
                  subtitle: Text(l.settingsDebugResetTodayDesc),
                  onTap: () async {
                    await ref.read(remainingProvider.notifier).reset();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l.settingsDebugResetDone)),
                      );
                    }
                  },
                ),
              ],
            ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildLanguageTile({
    required BuildContext context,
    required WidgetRef ref,
    required String code,
    required String label,
    required String groupValue,
  }) {
    final selected = code == groupValue;
    return ListTile(
      leading: Icon(
        Icons.language,
        color: selected ? AppColors.mazuRed : AppColors.gray,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: selected ? AppColors.mazuRed : AppColors.inkBlack,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      trailing: selected
          ? const Icon(Icons.check, color: AppColors.mazuRed)
          : null,
      onTap: () async {
        if (selected) return;
        await ref.read(settingsProvider.notifier).setLocaleCode(code);
        if (context.mounted) {
          final l = AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l.settingsLanguageChanged)),
          );
        }
      },
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.gray,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ),
        ...children,
      ],
    );
  }

  void _showEditProfileDialog(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final user = ref.read(currentUserProvider).valueOrNull;
    final nameController = TextEditingController(text: user?.name ?? '');
    final cityController = TextEditingController(text: user?.city ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.riceWhite,
        title: Text(l.settingsEditProfileTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: l.settingsEditProfileName),
              maxLength: 10,
            ),
            TextField(
              controller: cityController,
              decoration: InputDecoration(labelText: l.settingsEditProfileCity),
              maxLength: 30,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.commonCancel),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(currentUserProvider.notifier).update(
                    name: nameController.text.trim(),
                    city: cityController.text.trim(),
                  );
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(l.commonSave, style: const TextStyle(color: AppColors.mazuRed)),
          ),
        ],
      ),
    );
  }

  void _showSubscriptionDialog(BuildContext context, AppLocalizations l) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.riceWhite,
        title: Text(l.settingsUpgradeTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.settingsUpgradeFeatures),
            const SizedBox(height: 16),
            Text(
              l.settingsUpgradePrice,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.mazuRed,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l.settingsUpgradeNote,
              style: const TextStyle(fontSize: 12, color: AppColors.gray),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.commonClose),
          ),
        ],
      ),
    );
  }
}
