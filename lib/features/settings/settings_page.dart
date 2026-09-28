// lib/features/settings/settings_page.dart
// 设置页

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/subscription_state.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/providers.dart';
import 'about_dialogs.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final user = ref.watch(currentUserProvider).valueOrNull;
    final hasUnlimited = ref.watch(hasUnlimitedAccessProvider);
    final subState = ref.watch(subscriptionStateProvider);
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
                  color: hasUnlimited ? AppColors.mazuRed : AppColors.gray,
                ),
                title: Row(
                  children: [
                    Text(l.settingsSoundAmbientTitle),
                    if (!hasUnlimited) ...[
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
                  hasUnlimited
                      ? l.settingsSoundAmbientActive
                      : l.settingsSoundAmbientLocked,
                  style: const TextStyle(fontSize: 12),
                ),
                value: hasUnlimited ? settings.ambientEnabled : false,
                onChanged: hasUnlimited
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
                  subState.hasUnlimitedAccess
                      ? Icons.workspace_premium
                      : Icons.workspace_premium_outlined,
                  color: subState.hasUnlimitedAccess
                      ? AppColors.goldYellow
                      : AppColors.gray,
                ),
                title: Text(subState.hasUnlimitedAccess
                    ? l.settingsSubActive
                    : l.settingsSubInactive),
                subtitle: Text(
                  subState.hasUnlimitedAccess
                      ? l.settingsSubActiveDesc
                      : l.settingsSubInactiveDesc,
                ),
                trailing: subState.hasUnlimitedAccess
                    ? null
                    : const Icon(Icons.chevron_right),
                onTap: subState.hasUnlimitedAccess
                    ? null
                    : () => context.push('/paywall'),
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
                  value: subState.status == SubscriptionStatus.subscribed,
                  onChanged: (v) async {
                    await ref.read(subscriptionStateProvider.notifier).debugSetMode(
                          v ? 'unlimited' : 'fresh',
                        );
                  },
                ),
              ],
            ),

          // 数据(账号删除 / 清除本地数据,Apple Guideline 5.1.1 强制要求)
          _buildSection(
            context: context,
            title: l.settingsSectionData,
            children: [
              ListTile(
                leading: const Icon(Icons.delete_outline, color: AppColors.warningRed),
                title: Text(
                  l.settingsDeleteAllData,
                  style: const TextStyle(color: AppColors.warningRed),
                ),
                onTap: () => _showDeleteAllDataDialog(context, ref),
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

  /// Apple Guideline 5.1.1:账号删除 / 数据清除
  /// 清 3 个 Hive box(用户、记录、设置) + SharedPreferences 的 subscription state
  /// 完成后清内存中的所有 provider state,跳回 onboarding
  void _showDeleteAllDataDialog(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    bool confirming = false;

    showDialog(
      context: context,
      barrierDismissible: !confirming,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocalState) {
          return AlertDialog(
            backgroundColor: AppColors.riceWhite,
            icon: const Icon(Icons.warning_amber_rounded,
                color: AppColors.warningRed, size: 48),
            title: Text(l.settingsDeleteConfirmTitle),
            content: Text(l.settingsDeleteConfirmBody),
            actions: [
              TextButton(
                onPressed: confirming ? null : () => Navigator.pop(ctx),
                child: Text(l.commonCancel),
              ),
              StatefulBuilder(builder: (ctx, setLocalState) {
                return TextButton(
                  onPressed: confirming
                      ? null
                      : () async {
                          setLocalState(() => confirming = true);
                          try {
                            // 1. 清 3 个 Hive box
                            await Hive.deleteBoxFromDisk(AppConstants.userBox);
                            await Hive.deleteBoxFromDisk(AppConstants.recordBox);
                            await Hive.deleteBoxFromDisk(AppConstants.settingsBox);
                            // 2. 清 SharedPreferences 里的 subscription state + first launch
                            //    (通过 SubscriptionRepository 走正规 API)
                            await ref.read(subscriptionServiceProvider)
                                .clearSubscription();
                            // 3. 卸载 box 缓存(下次打开会重新 open)
                            // Hive box 是惰性打开,这里不需要显式 close
                            // 4. 关闭弹窗
                            if (ctx.mounted) Navigator.pop(ctx);
                            // 5. SnackBar 提示
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(l.settingsDeleteDone)),
                              );
                            }
                            // 6. 跳回 onboarding
                            if (context.mounted) context.go('/onboarding');
                          } catch (e) {
                            // 任何异常恢复按钮
                            setLocalState(() => confirming = false);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            }
                          }
                        },
                  child: Text(
                    l.commonDelete,
                    style: const TextStyle(
                        color: AppColors.warningRed, fontWeight: FontWeight.w700),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
