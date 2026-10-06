// lib/features/settings/settings_page.dart
// 设置页
//
// V1.2 (v5) 改动:
//   - 删除「订阅」section
//   - 删除 debug section(mock subscription)
//   - 报家门 dialog 删 city 输入,只保留昵称
//   - 删除账号流程里不再 invalidate subscriptionStateProvider / clearSubscription

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';

import '../../core/constants/app_constants.dart';
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
                context: context, ref: ref,
                code: 'zh_CN', label: '简体中文',
                groupValue: settings.localeCode,
              ),
              _buildLanguageTile(
                context: context, ref: ref,
                code: 'zh_TW', label: '繁體中文',
                groupValue: settings.localeCode,
              ),
              _buildLanguageTile(
                context: context, ref: ref,
                code: 'en', label: 'English',
                groupValue: settings.localeCode,
              ),
            ],
          ),
          // 音效震动
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
                secondary: const Icon(Icons.surround_sound, color: AppColors.mazuRed),
                title: Text(l.settingsSoundAmbientTitle),
                subtitle: Text(l.settingsSoundAmbientActive, style: const TextStyle(fontSize: 12)),
                value: settings.ambientEnabled,
                onChanged: (v) => notifier.setAmbientEnabled(v),
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
          // 签文库 + 历史(V1.2 改名「记录」)
          _buildSection(
            context: context,
            title: l.settingsSectionView,
            children: [
              ListTile(
                leading: const Icon(Icons.history, color: AppColors.mazuRed),
                title: Text(l.settingsViewHistory),
                trailing: const Icon(Icons.chevron_right, color: AppColors.gray),
                onTap: () => context.push('/records'),
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
                subtitle: const Text('v1.2 · 2026-10'),
                trailing: const Icon(Icons.chevron_right, color: AppColors.gray),
                onTap: () => AboutDialogs.showAboutApp(context),
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
  /// 清 3 个 Hive box(用户、记录、设置),完成后清内存 provider state,跳回 onboarding
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
                          // 1. 先关弹窗(等动画完成再操作 Navigator)
                          if (ctx.mounted) Navigator.pop(ctx);
                          // 2. 等 350ms 让 pop 动画走完(Navigator 释放锁)
                          await Future.delayed(const Duration(milliseconds: 350));
                          try {
                            // 3. 清 3 个 Hive box(磁盘文件)
                            await Hive.deleteBoxFromDisk(AppConstants.userBox);
                            await Hive.deleteBoxFromDisk(AppConstants.recordBox);
                            await Hive.deleteBoxFromDisk(AppConstants.settingsBox);
                            // 4. 清各 Repository 缓存的 box 引用
                            ref.read(userRepositoryProvider).clearCache();
                            ref.read(recordRepositoryProvider).clearCache();
                            ref.read(settingsRepositoryProvider).clearCache();
                            // 5. 重置 Riverpod 内存 state
                            ref.invalidate(currentUserProvider);
                            ref.invalidate(recordsProvider);
                            ref.invalidate(settingsProvider);
                            // 6. 停掉可能还在播的所有音效
                            await ref.read(soundServiceProvider).stopAllOneShot();
                            await ref.read(soundServiceProvider).stopAmbient();
                            // 7. SnackBar 提示
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(l.settingsDeleteDone)),
                              );
                            }
                            // 8. 跳回 onboarding(router redirect 会因为 user_box 为空进 onboarding)
                            if (context.mounted) context.go('/onboarding');
                          } catch (e) {
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
