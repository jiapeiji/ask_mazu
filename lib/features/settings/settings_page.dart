// lib/features/settings/settings_page.dart
// 设置页

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/providers.dart';
import 'about_dialogs.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    final isSubscribed = ref.watch(isSubscribedProvider);
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.riceWhite,
      appBar: AppBar(
        title: const Text('设 置'),
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
            title: '报 家 门',
            children: [
              ListTile(
                leading: const Icon(Icons.person_outline, color: AppColors.mazuRed),
                title: Text(user?.name ?? '未设置'),
                subtitle: Text(user?.city ?? ''),
                trailing: const Icon(Icons.chevron_right, color: AppColors.gray),
                onTap: () => _showEditProfileDialog(context, ref),
              ),
            ],
          ),
          // 声音
          _buildSection(
            context: context,
            title: '声 音',
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.volume_up, color: AppColors.mazuRed),
                title: const Text('木块落地音'),
                subtitle: const Text('投掷时木块落地的回响', style: TextStyle(fontSize: 12)),
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
                    const Text('庙宇环境音'),
                    if (!isSubscribed) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.goldYellow,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          '订阅',
                          style: TextStyle(fontSize: 10, color: Colors.white),
                        ),
                      ),
                    ],
                  ],
                ),
                subtitle: Text(
                  isSubscribed
                      ? '在结果页循环播放'
                      : '订阅后可用',
                  style: const TextStyle(fontSize: 12),
                ),
                value: isSubscribed ? settings.ambientEnabled : false,
                onChanged: isSubscribed
                    ? (v) => notifier.setAmbientEnabled(v)
                    : null,
              ),
              SwitchListTile(
                secondary: const Icon(Icons.vibration, color: AppColors.mazuRed),
                title: const Text('震动反馈'),
                subtitle: const Text('投掷完成时轻微震动', style: TextStyle(fontSize: 12)),
                value: settings.hapticEnabled,
                onChanged: (v) => notifier.setHapticEnabled(v),
              ),
            ],
          ),
          // 主题
          _buildSection(
            context: context,
            title: '主 题',
            children: [
              RadioListTile<ThemeMode>(
                value: ThemeMode.light,
                groupValue: settings.themeMode,
                onChanged: (m) {
                  if (m != null) notifier.setThemeMode(m);
                },
                title: const Text('妈祖红（默认）'),
                subtitle: const Text('米白底 + 朱红点缀', style: TextStyle(fontSize: 12)),
                secondary: Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: AppColors.mazuRed,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              RadioListTile<ThemeMode>(
                value: ThemeMode.dark,
                groupValue: settings.themeMode,
                onChanged: (m) {
                  if (m != null) notifier.setThemeMode(m);
                },
                title: const Text('玄夜黑'),
                subtitle: const Text('深棕底 + 金色点缀（夜间护眼）', style: TextStyle(fontSize: 12)),
                secondary: Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: AppColors.darkBg,
                    shape: BoxShape.circle,
                    border: Border.fromBorderSide(
                      BorderSide(color: AppColors.goldYellow, width: 1.5),
                    ),
                  ),
                ),
              ),
              RadioListTile<ThemeMode>(
                value: ThemeMode.system,
                groupValue: settings.themeMode,
                onChanged: (m) {
                  if (m != null) notifier.setThemeMode(m);
                },
                title: const Text('跟随系统'),
                secondary: const Icon(Icons.brightness_auto, color: AppColors.gray),
              ),
            ],
          ),
          // 订阅
          _buildSection(
            context: context,
            title: '订 阅',
            children: [
              ListTile(
                leading: Icon(
                  isSubscribed ? Icons.workspace_premium : Icons.workspace_premium_outlined,
                  color: isSubscribed ? AppColors.goldYellow : AppColors.gray,
                ),
                title: Text(isSubscribed ? '已订阅' : '升级无限次数'),
                subtitle: Text(
                  isSubscribed
                      ? '感谢支持！'
                      : '月卡 \$4.99 / 年卡 \$29.99',
                ),
                trailing: isSubscribed ? null : const Icon(Icons.chevron_right),
                onTap: isSubscribed
                    ? null
                    : () => _showSubscriptionDialog(context),
              ),
            ],
          ),
          // 签文库 + 历史
          _buildSection(
            context: context,
            title: '查 看',
            children: [
              ListTile(
                leading: const Icon(Icons.history, color: AppColors.mazuRed),
                title: const Text('问事记录'),
                trailing: const Icon(Icons.chevron_right, color: AppColors.gray),
                onTap: () => context.push('/history'),
              ),
              ListTile(
                leading: const Icon(Icons.menu_book_outlined, color: AppColors.mazuRed),
                title: const Text('妈祖签文库'),
                subtitle: const Text('查看所有 60 支签文', style: TextStyle(fontSize: 12)),
                trailing: const Icon(Icons.chevron_right, color: AppColors.gray),
                onTap: () => context.push('/signs'),
              ),
            ],
          ),
          // 关于
          _buildSection(
            context: context,
            title: '关 于',
            children: [
              ListTile(
                leading: const Icon(Icons.info_outline, color: AppColors.gray),
                title: const Text('关于妈祖'),
                trailing: const Icon(Icons.chevron_right, color: AppColors.gray),
                onTap: () => AboutDialogs.showAboutMazu(context),
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined, color: AppColors.gray),
                title: const Text('隐私政策'),
                trailing: const Icon(Icons.chevron_right, color: AppColors.gray),
                onTap: () => AboutDialogs.showPrivacyPolicy(context),
              ),
              ListTile(
                leading: const Icon(Icons.description_outlined, color: AppColors.gray),
                title: const Text('用户协议'),
                trailing: const Icon(Icons.chevron_right, color: AppColors.gray),
                onTap: () => AboutDialogs.showTermsOfService(context),
              ),
              ListTile(
                leading: const Icon(Icons.app_settings_alt, color: AppColors.gray),
                title: const Text('关于此 App'),
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
              title: '调 试',
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.bug_report, color: AppColors.warningRed),
                  title: const Text('模拟订阅'),
                  subtitle: const Text('开启后所有订阅功能可用（无限次数 + 完整签文库）'),
                  value: isSubscribed,
                  onChanged: (v) {
                    ref.read(isSubscribedProvider.notifier).state = v;
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.refresh, color: AppColors.gray),
                  title: const Text('重置今日使用次数'),
                  subtitle: const Text('清空今日已投掷次数'),
                  onTap: () async {
                    await ref.read(remainingProvider.notifier).reset();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('已重置今日使用次数')),
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
    final user = ref.read(currentUserProvider).valueOrNull;
    final nameController = TextEditingController(text: user?.name ?? '');
    final cityController = TextEditingController(text: user?.city ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.riceWhite,
        title: const Text('修改报家门'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: '名字'),
              maxLength: 10,
            ),
            TextField(
              controller: cityController,
              decoration: const InputDecoration(labelText: '城市'),
              maxLength: 30,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(currentUserProvider.notifier).update(
                    name: nameController.text.trim(),
                    city: cityController.text.trim(),
                  );
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('保存', style: TextStyle(color: AppColors.mazuRed)),
          ),
        ],
      ),
    );
  }

  void _showSubscriptionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.riceWhite,
        title: const Text('升 级 订 阅'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('· 每日无限次投掷'),
            Text('· 完整 60 支签文'),
            Text('· 历史记录云同步'),
            Text('· 庙宇环境音'),
            Text('· 节日特别签'),
            SizedBox(height: 16),
            Text(
              '月卡 \$4.99\n年卡 \$29.99（首月免费）',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.mazuRed,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '注：V0.1 暂未对接 App Store，订阅功能在 V1 启用。',
              style: TextStyle(fontSize: 12, color: AppColors.gray),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}
