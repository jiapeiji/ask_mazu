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

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gal/gal.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/result_templates.dart';
import '../../data/models/fortune_sign.dart';
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
  String _buildShareText() {
    final resultLabel = switch (widget.result) {
      ThrowResultType.saint => '圣杯',
      ThrowResultType.laugh => '笑杯',
      ThrowResultType.yin => '阴杯',
    };
    final lines = <String>[];
    lines.add('🙏 妈祖所示 · $resultLabel');
    lines.add('');
    lines.add(widget.message);
    lines.add('');
    lines.add('—— 来自「问妈祖 Ask Mazu」');
    return lines.join('\n');
  }

  Future<void> _onChannelTap(String channel) async {
    if (_isProcessing) return;
    setState(() {
      _isProcessing = true;
      _processingChannel = channel;
    });

    try {
      final bytes = await ShareService.capture(_boundaryKey);
      if (bytes == null) throw '生成图片失败，请重试';

      switch (channel) {
        case 'wechat':
          await _shareToWechat(bytes);
          break;
        case 'moments':
          await _shareToMoments(bytes);
          break;
        case 'copy':
          await _copyText();
          break;
        case 'save':
          await _saveImage(bytes);
          break;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('操作失败: $e')),
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
  Future<void> _shareToWechat(Uint8List bytes) async {
    await Share.shareXFiles(
      [
        XFile.fromData(
          bytes,
          name: 'ask_mazu_${DateTime.now().millisecondsSinceEpoch}.png',
          mimeType: 'image/png',
        ),
      ],
      text: _buildShareText(),
      subject: '妈祖所示',
    );
  }

  /// 朋友圈（同上，提示选朋友圈）
  Future<void> _shareToMoments(Uint8List bytes) async {
    final text = '${_buildShareText()}\n（请在分享面板选"朋友圈"）';
    await Share.shareXFiles(
      [
        XFile.fromData(
          bytes,
          name: 'ask_mazu_${DateTime.now().millisecondsSinceEpoch}.png',
          mimeType: 'image/png',
        ),
      ],
      text: text,
    );
  }

  /// 复制文案到剪贴板
  Future<void> _copyText() async {
    await Clipboard.setData(ClipboardData(text: _buildShareText()));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('文案已复制到剪贴板'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  /// 保存图片到相册
  Future<void> _saveImage(Uint8List bytes) async {
    // gal 2.x 需要请求权限（iOS 14+ / Android 13+）
    final hasAccess = await Gal.hasAccess(toAlbum: true);
    if (!hasAccess) {
      final granted = await Gal.requestAccess(toAlbum: true);
      if (!granted) {
        throw '没有相册权限，请到设置中开启';
      }
    }
    await Gal.putImageBytes(bytes, album: 'AskMazu');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('已保存到相册"AskMazu"文件夹'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                const Text(
                  '分享妈祖所示',
                  style: TextStyle(
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
                      color: Colors.black.withOpacity(0.15),
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
                  label: '微信',
                  channel: 'wechat',
                  isLoading: _isProcessing && _processingChannel == 'wechat',
                  onTap: _onChannelTap,
                ),
                _ChannelButton(
                  icon: Icons.camera_alt_outlined,
                  label: '朋友圈',
                  channel: 'moments',
                  isLoading: _isProcessing && _processingChannel == 'moments',
                  onTap: _onChannelTap,
                ),
                _ChannelButton(
                  icon: Icons.content_copy_outlined,
                  label: '复制',
                  channel: 'copy',
                  isLoading: _isProcessing && _processingChannel == 'copy',
                  onTap: _onChannelTap,
                ),
                _ChannelButton(
                  icon: Icons.image_outlined,
                  label: '存图',
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
                color: AppColors.mazuRed.withOpacity(0.1),
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
            Text(
              label,
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
