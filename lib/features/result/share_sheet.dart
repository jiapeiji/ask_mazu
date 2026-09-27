// lib/features/result/share_sheet.dart
// 自建分享 sheet（多渠道入口）
//
// 渠道：
// - 微信：调起系统分享面板（share_plus），用户在面板选微信
// - 朋友圈：同上，提示"选朋友圈"
// - 复制：Clipboard.setData（仅文字）
// - 保存：gal 插件保存图片到相册
//
// 未来接微信开放平台 AppID 后：
// - "微信"按钮可改为直接调起 fluwx（不弹系统面板）

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gal/gal.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/result_templates.dart';
import '../../data/models/fortune_sign.dart';
import '../../l10n/generated/app_localizations.dart';
import 'share_card.dart';

/// 自建分享 sheet（顶部预览 + 底部 4 渠道按钮）
class ShareChannelSheet extends StatefulWidget {
  final ThrowResultType result;
  final FortuneSign? sign;
  final String message;
  final String question;
  final String name;
  final String city;

  const ShareChannelSheet({
    super.key,
    required this.result,
    required this.sign,
    required this.message,
    required this.question,
    required this.name,
    required this.city,
  });

  /// 在 result_page 调起
  static Future<void> show(BuildContext context, {
    required ThrowResultType result,
    required FortuneSign? sign,
    required String message,
    required String question,
    required String name,
    required String city,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.riceWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => ShareChannelSheet(
        result: result,
        sign: sign,
        message: message,
        question: question,
        name: name,
        city: city,
      ),
    );
  }

  @override
  State<ShareChannelSheet> createState() => _ShareChannelSheetState();
}

class _ShareChannelSheetState extends State<ShareChannelSheet> {
  final GlobalKey _boundaryKey = GlobalKey();
  bool _isProcessing = false;
  String? _processingChannel;

  /// 准备分享文案（与截屏图片配套）
  String _buildShareText(AppLocalizations l) {
    final resultLabel = switch (widget.result) {
      ThrowResultType.saint => l.resultSaint,
      ThrowResultType.laugh => l.resultLaugh,
      ThrowResultType.yin => l.resultYin,
    };
    final lines = <String>[];
    lines.add('${l.shareSignPrefix}$resultLabel');
    lines.add('');
    lines.add(widget.message);
    lines.add('');
    lines.add(l.shareFooter);
    return lines.join('\n');
  }

  Future<void> _onChannelTap(String channel) async {
    if (_isProcessing) return;
    final l = AppLocalizations.of(context);
    setState(() {
      _isProcessing = true;
      _processingChannel = channel;
    });

    try {
      final bytes = await ShareService.capture(_boundaryKey);
      if (bytes == null) throw l.shareImageGenFail;

      switch (channel) {
        case 'wechat':
          await _shareToWechat(l);
          break;
        case 'moments':
          await _shareToMoments(l);
          break;
        case 'copy':
          await _copyText(l);
          break;
        case 'save':
          await _saveImage(l);
          break;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.shareOpFail(e.toString()))),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _processingChannel = null;
        });
      }
    }
  }

  /// 微信（调起系统分享面板，用户选微信）
  Future<void> _shareToWechat(AppLocalizations l) async {
    final bytes = await ShareService.capture(_boundaryKey);
    if (bytes == null) return;
    if (!mounted) return;
    // iOS 强制要求 sharePositionOrigin（即使是 iPhone）
    // 用整个屏幕作为源 view 坐标（iPhone 上弹全屏分享面板，不影响）
    final media = MediaQuery.of(context);
    final origin = Rect.fromLTWH(0, 0, media.size.width, media.size.height);
    await Share.shareXFiles(
      [
        XFile.fromData(
          bytes,
          name: 'ask_mazu_${DateTime.now().millisecondsSinceEpoch}.png',
          mimeType: 'image/png',
        ),
      ],
      text: _buildShareText(l),
      subject: l.shareSubject,
      sharePositionOrigin: origin,
    );
  }

  /// 朋友圈（同上，提示选朋友圈）
  Future<void> _shareToMoments(AppLocalizations l) async {
    final bytes = await ShareService.capture(_boundaryKey);
    if (bytes == null) return;
    if (!mounted) return;
    final text = '${_buildShareText(l)}\n${l.shareMomentsHint}';
    final media = MediaQuery.of(context);
    final origin = Rect.fromLTWH(0, 0, media.size.width, media.size.height);
    await Share.shareXFiles(
      [
        XFile.fromData(
          bytes,
          name: 'ask_mazu_${DateTime.now().millisecondsSinceEpoch}.png',
          mimeType: 'image/png',
        ),
      ],
      text: text,
      sharePositionOrigin: origin,
    );
  }

  /// 复制文案到剪贴板
  Future<void> _copyText(AppLocalizations l) async {
    await Clipboard.setData(ClipboardData(text: _buildShareText(l)));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.shareCopied),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// 保存图片到相册
  Future<void> _saveImage(AppLocalizations l) async {
    final bytes = await ShareService.capture(_boundaryKey);
    if (bytes == null) return;
    // gal 2.x 需要请求权限（iOS 14+ / Android 13+）
    final hasAccess = await Gal.hasAccess(toAlbum: true);
    if (!hasAccess) {
      final granted = await Gal.requestAccess(toAlbum: true);
      if (!granted) {
        throw l.shareAlbumPermFail;
      }
    }
    await Gal.putImageBytes(bytes, album: 'AskMazu');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.shareSavedToAlbum),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final media = MediaQuery.of(context);
    final screenW = media.size.width;
    final screenH = media.size.height - media.viewInsets.bottom;

    // 预览区域：9:16，按屏宽 60% / 屏高 50% 取较小者
    final previewMaxH = screenH * 0.5;
    final previewMaxW = screenW - 32;
    final hByW = previewMaxW * 16 / 9;
    final wByH = previewMaxH * 9 / 16;
    final double previewW, previewH;
    if (hByW <= previewMaxH) {
      previewW = previewMaxW;
      previewH = hByW;
    } else {
      previewW = wByH;
      previewH = previewMaxH;
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 标题
            Row(
              children: [
                Text(
                  l.shareTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.inkBlack,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // 分享卡预览
            Center(
              child: Container(
                width: previewW,
                height: previewH,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: RepaintBoundary(
                    key: _boundaryKey,
                    child: ShareCard(
                      result: widget.result,
                      sign: widget.sign,
                      message: widget.message,
                      question: widget.question,
                      name: widget.name,
                      city: widget.city,
                      date: DateTime.now(),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 渠道按钮区
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ChannelButton(
                  icon: Icons.chat_bubble_outline,
                  label: l.shareWechat,
                  channel: 'wechat',
                  isLoading: _isProcessing && _processingChannel == 'wechat',
                  onTap: _onChannelTap,
                ),
                _ChannelButton(
                  icon: Icons.camera_alt_outlined,
                  label: l.shareMoments,
                  channel: 'moments',
                  isLoading: _isProcessing && _processingChannel == 'moments',
                  onTap: _onChannelTap,
                ),
                _ChannelButton(
                  icon: Icons.content_copy_outlined,
                  label: l.shareCopy,
                  channel: 'copy',
                  isLoading: _isProcessing && _processingChannel == 'copy',
                  onTap: _onChannelTap,
                ),
                _ChannelButton(
                  icon: Icons.image_outlined,
                  label: l.shareSave,
                  channel: 'save',
                  isLoading: _isProcessing && _processingChannel == 'save',
                  onTap: _onChannelTap,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 单个渠道按钮（圆形 icon + 文字）
class _ChannelButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String channel;
  final bool isLoading;
  final Future<void> Function(String) onTap;

  const _ChannelButton({
    required this.icon,
    required this.label,
    required this.channel,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isLoading ? null : () => onTap(channel),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.mazuRed.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(14),
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.mazuRed,
                      ),
                    )
                  : Icon(icon, color: AppColors.mazuRed, size: 28),
            ),
            const SizedBox(height: 8),
            // maxLines:1 + ellipsis + softWrap:false：英文长 label
            // （WeChat/Moments/Save）不会撑爆按钮宽度。
            Text(
              label,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.inkBlack,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
