// lib/features/settings/about_dialogs.dart
// 关于 / 隐私 / 用户协议 / 关于此 App 对话框

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';

class AboutDialogs {
  AboutDialogs._();

  /// 关于妈祖
  static void showAboutMazu(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => _buildScrollableDialog(
        context: ctx,
        title: '关于妈祖',
        content: '''妈祖，原名林默，公元 960 年生于福建莆田湄洲岛。

相传她熟谙水性、洞晓天象，常于惊涛骇浪中救助遇险船隻。雍熙四年（公元 987 年），林默在一次海难中捨身救人，民众感其恩德，于湄洲岛立庙奉祀，尊称为「妈祖」。

妈祖信仰由福建沿海出发，随华人下南洋、过台湾、闯世界，如今遍佈全球三十多个国家与地区，信众超过两亿。海上航行者奉为护航之神，侨居他乡者奉为乡愁之所寄。

在台湾、香港、澳门、东南亚及北美华人聚居处，妈祖宫庙香火绵延。每逢农历三月廿三妈祖圣诞，各地宫庙举办祭典、绕境、吃福等活动，已成华人世界最重要的民俗信仰之一。

本 App 旨在为海外华人提供一个日常的仪式——出门办事、远行决策、心有疑难时，掷杯问一问妈祖，得到一点心安。''',
      ),
    );
  }

  /// 隐私政策
  static void showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => _buildScrollableDialog(
        context: ctx,
        title: '隐私政策',
        content: '''最后更新：2026 年 8 月

【我们收集什么】
• 您输入的「名字」和「城市」——仅用于在结果中称呼您，本地存储，不上传。
• 您投掷的记录（问题、结果、签文）——仅存储在您设备本地，不上传。
• 崩溃日志与基础使用统计——匿名收集，用于改进 App 体验。

【我们不收集什么】
• 不收集您的真实姓名、身份证号、手机号、邮箱、通讯录、位置轨迹。
• 不收集您设备的 IMEI、IDFA、MAC 地址等永久标识符。
• 不向任何第三方出售或共享您的个人数据。

【第三方 SDK】
本 App 不集成广告 SDK、统计分析 SDK 或社交分享 SDK。V1 版本接入 App Store 内购时，仅 Apple 知晓您购买了订阅，应用本身不获取您的 Apple ID。

【您的权利】
• 您的全部数据都存在本机，您可随时在「设置 → 重置全部数据」中清除。
• 卸载 App 等同于删除全部本地数据。
• 如有疑问，请通过设置页的「反馈」联系我们。

【未成年人】
本 App 适合全年龄段使用。未成年人在使用前请由监护人代为阅读本政策。''',
      ),
    );
  }

  /// 用户协议
  static void showTermsOfService(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => _buildScrollableDialog(
        context: ctx,
        title: '用户协议',
        content: '''最后更新：2026 年 8 月

【服务说明】
「问妈祖」是一款基于民间信仰的休闲文化类 App，不属于宗教组织运营，亦不收取功德箱、香油钱等任何形式的宗教捐赠。App 中的签文、诗句、解说来源于公开典籍与民俗传说，仅供文化参考与娱乐。

【使用须知】
• 本 App 内容不构成医疗、法律、金融、投资等专业建议。如有重大决策，请咨询专业人士。
• 签文为概率生成，旨在给您一点心理暗示与仪式感，请勿过度依赖。
• 每日 3 次免费投掷（V0.1 阶段），订阅后无次数限制。
• 请文明提问，遵守当地法律法规与公序良俗。

【知识产权】
• App 中的切图、签文库、文案均为本团队原创或合法授权。
• 您可以分享 App 生成的结果图至微信、朋友圈等社交平台，注明出处即可。
• 未经许可，不得将本 App 内容用于商业用途。

【服务变更与终止】
• 我们保留随时更新功能、调整计费、暂停服务的权利。
• 如有重大变更，会提前在 App 内公告。
• 您可以随时卸载 App 以终止使用。

【免责】
本 App 力求内容准确与文化尊重，但不对内容的绝对准确性作担保。请以开放、平和的心态使用。''',
      ),
    );
  }

  /// 关于此 App
  static void showAboutApp(BuildContext context) {
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
                      color: AppColors.mazuRed.withOpacity(0.3),
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
              _buildInfoRow('版本', 'v${AppConstants.version}'),
              _buildInfoRow('构建时间', '2026-08'),
              _buildInfoRow('平台', 'iOS / Android'),
              const SizedBox(height: 20),
              const Text(
                '用 ❤️ 与 🙏 制作',
                style: TextStyle(fontSize: 12, color: AppColors.gray),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('关闭'),
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
                          const SnackBar(content: Text('已复制全文')),
                        );
                      }
                    },
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text('复制全文'),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('关闭'),
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
