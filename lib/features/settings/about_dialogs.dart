// lib/features/settings/about_dialogs.dart
// 关于 / 隐私 / 用户协议 / 关于此 App 对话框
// （标题用 i18n；正文保留中文——法律/文化长文一期不译）

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../l10n/generated/app_localizations.dart';

class AboutDialogs {
  AboutDialogs._();

  /// 关于妈祖(V1.2)
  static void showAboutMazu(BuildContext context) {
    final l = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => _buildScrollableDialog(
        context: ctx,
        title: l.aboutMazuTitle,
        content: '''妈祖，原名林默，公元 960 年生于福建莆田湄洲岛。

相传她熟谙水性、洞晓天象，常于惊涛骇浪中救助遇险船隻。雍熙四年（公元 987 年），林默在一次海难中捨身救人，民众感其恩德，于湄洲岛立庙奉祀，尊称为「妈祖」。

妈祖信仰由福建沿海出发，随华人下南洋、过台湾、闯世界，如今遍佈全球三十多个国家与地区，信众超过两亿。海上航行者奉为护航之神，侨居他乡者奉为乡愁之所寄。

在台湾、香港、澳门、东南亚及北美华人聚居处，妈祖宫庙香火绵延。每逢农历三月廿三妈祖圣诞，各地宫庙举办祭典、绕境、吃福等活动，已成华人世界最重要的民俗信仰之一。

「问妈祖」App 旨在为海外华人提供一个安静的日常仪式：写下今日的反思，掷杯筊问妈祖，把她的回应当作诗来读，存入日记。仪式是为了让反思更有重量，不是为了算命。''',
      ),
    );
  }

  /// 隐私政策(V1.2)
  static void showPrivacyPolicy(BuildContext context) {
    final l = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => _buildScrollableDialog(
        context: ctx,
        title: l.privacyTitle,
        content: '''最后更新：2026 年 10 月（V1.2）

【关于本 App】
「问妈祖」是一款面向海外华人的文化传承 + 每日反思 App。本 App 完全免费，无内购、无订阅。

【我们收集什么】
• 您输入的「昵称」——仅用于在结果中称呼您，本地存储，不上传。
• 您写下的反思文本（可选）+ 心情选择 + 投杯结果 + 妈祖反馈——仅存储在您设备本地，不上传。
• 崩溃日志与基础使用统计（V1.2 暂未启用）。

【我们不收集什么】
• 不收集您的真实姓名、身份证号、手机号、邮箱、通讯录、位置轨迹。
• 不收集您设备的 IMEI、IDFA、MAC 地址等永久标识符。
• 不向任何第三方出售或共享您的个人数据。
• 不收集任何账号 / 密码 / Apple ID——App 内无账号系统。

【第三方 SDK】
本 App 不集成任何第三方 SDK：无广告、无统计分析、无社交分享、无推送通知、无 AI 服务。

【您的权利】
• 您的全部数据都存在本机，您可随时在「设置 → 删除全部数据」中清除。
• 卸载 App 等同于删除全部本地数据。
• 如有疑问，请通过 GitHub Issues 联系我们。

【未成年人】
本 App 适合全年龄段使用。未成年人在使用前请由监护人代为阅读本政策。''',
      ),
    );
  }

  /// 用户协议(V1.2)
  static void showTermsOfService(BuildContext context) {
    final l = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => _buildScrollableDialog(
        context: ctx,
        title: l.tosTitle,
        content: '''最后更新：2026 年 10 月（V1.2）

【服务说明】
「问妈祖」是一款基于民间信仰的休闲文化类 App，不属于宗教组织运营，亦不收取功德箱、香油钱等任何形式的宗教捐赠。App 中的签文、诗句、解说来源于公开典籍与民俗传说，仅供文化参考与娱乐。

本 App 完全免费，无内购、无订阅。

【使用须知】
• 本 App 内容不构成医疗、法律、金融、投资等专业建议。如有重大决策，请咨询专业人士。
• 签诗为概率生成，旨在给您一点心理暗示与仪式感，请勿过度依赖。
• 每日 1 次正式反思记录（V1.2 限定，不可重复）。
• 请文明使用，遵守当地法律法规与公序良俗。

【知识产权】
• App 中的切图、签文库、文案均为本团队原创或合法授权。
• 您可以分享 App 生成的结果图至微信、朋友圈等社交平台，注明出处即可。
• 未经许可，不得将本 App 内容用于商业用途。

【服务变更与终止】
• 我们保留随时更新功能、暂停服务的权利。
• 如有重大变更，会提前在 App 内公告。
• 您可以随时卸载 App 以终止使用。

【免责】
本 App 力求内容准确与文化尊重，但不对内容的绝对准确性作担保。请以开放、平和的心态使用。''',
      ),
    );
  }

  /// 关于此 App
  static void showAboutApp(BuildContext context) {
    final l = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.riceWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.mazuRed,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.mazuRed.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('🙏', style: TextStyle(fontSize: 44)),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                AppConstants.appName,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.mazuRed,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                AppConstants.appSubtitle,
                style: TextStyle(fontSize: 13, color: AppColors.gray),
              ),
              const SizedBox(height: 24),
              _buildInfoRow(l.aboutAppVersion, 'v${AppConstants.version}'),
              _buildInfoRow(l.aboutAppBuildTime, '2026-10'),
              _buildInfoRow(l.aboutAppPlatform, 'iOS / Android'),
              const SizedBox(height: 20),
              Text(
                l.aboutAppFooter,
                style: const TextStyle(fontSize: 12, color: AppColors.gray),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(l.commonClose),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.gray, fontSize: 13)),
          Text(value, style: const TextStyle(color: AppColors.inkBlack, fontSize: 13)),
        ],
      ),
    );
  }

  /// 通用：可滚动的"标题+正文"对话框
  static Widget _buildScrollableDialog({
    required BuildContext context,
    required String title,
    required String content,
  }) {
    final l = AppLocalizations.of(context);
    return Dialog(
      backgroundColor: AppColors.riceWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 标题栏
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 8, 16),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.lightGray, width: 0.5),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.inkBlack,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.gray, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            // 正文（可滚动）
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: SelectableText(
                  content,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.inkBlack,
                    height: 1.7,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
            ),
            // 底部操作
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.lightGray, width: 0.5),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: content));
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l.aboutCopied)),
                        );
                      }
                    },
                    icon: const Icon(Icons.copy, size: 16),
                    label: Text(l.aboutCopy),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l.commonClose),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
