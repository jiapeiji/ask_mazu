// lib/features/result/share_card.dart
// 分享卡（动态生成 + 截屏分享）
//
// 设计：妈祖红底 + 米白主卡 + 金线边框 + 衬线体中文
// 自适应：所有尺寸按父布局比例计算（支持任意 9:16 容器）
// 截屏：动态算 pixelRatio 保证输出 1080×1920 像素 PNG

import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/result_templates.dart';
import '../../data/models/fortune_sign.dart';

/// 分享卡本体（9:16，自适应父布局）
///
/// 所有尺寸用「父布局 maxWidth/maxHeight × 比例」算，
/// 所以放到任何 9:16 容器里都能完整显示。
class ShareCard extends StatelessWidget {
  final ThrowResultType result;
  final FortuneSign? sign;
  final String message;
  final String question;
  final String name;
  final String city;
  final DateTime date;

  const ShareCard({
    super.key,
    required this.result,
    required this.sign,
    required this.message,
    required this.question,
    required this.name,
    required this.city,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        final resultLabel = switch (result) {
          ThrowResultType.saint => '圣  杯',
          ThrowResultType.laugh => '笑  杯',
          ThrowResultType.yin => '阴  杯',
        };

        final resultColor = switch (result) {
          ThrowResultType.saint => AppColors.successGreen,
          ThrowResultType.laugh => AppColors.hintYellow,
          ThrowResultType.yin => AppColors.warningRed,
        };

        final sealChar = switch (result) {
          ThrowResultType.saint => '圣',
          ThrowResultType.laugh => '笑',
          ThrowResultType.yin => '阴',
        };

        return SizedBox(
          width: w,
          height: h,
          child: Container(
            color: AppColors.mazuRed,
            child: Stack(
              children: [
                // 米白主卡
                Positioned(
                  left: w * 0.074, // 80/1080
                  right: w * 0.074,
                  top: h * 0.0625, // 120/1920
                  bottom: h * 0.094, // 180/1920
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.riceWhite,
                      borderRadius: BorderRadius.circular(w * 0.037), // 40/1080
                      border: Border.all(
                        color: AppColors.goldYellow,
                        width: math.max(2, w * 0.0055), // 6/1080
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: w * 0.059, // 64/1080
                      vertical: h * 0.042, // 80/1920
                    ),
                    child: Column(
                      children: [
                        // 顶部 banner：圆形红章 + 结果文字
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: w * 0.102, // 110/1080
                              height: w * 0.102,
                              decoration: BoxDecoration(
                                color: AppColors.mazuRed,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.goldYellow,
                                  width: math.max(2, w * 0.0037), // 4/1080
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                sealChar,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: w * 0.052, // 56/1080
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'ChillJinshuSong',
                                ),
                              ),
                            ),
                            SizedBox(width: w * 0.03), // 32/1080
                            Text(
                              resultLabel,
                              style: TextStyle(
                                color: resultColor,
                                fontSize: w * 0.067, // 72/1080
                                fontWeight: FontWeight.w700,
                                fontFamily: 'ChillJinshuSong',
                                letterSpacing: 4,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: h * 0.025), // 48/1920
                        _GoldDivider(),
                        SizedBox(height: h * 0.025),

                        // 用户原文（居中）
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: w * 0.015),
                          child: Text(
                            question,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: w * 0.041, // 44/1080
                              color: AppColors.inkBlack,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'ChillJinshuSong',
                              height: 1.5,
                            ),
                          ),
                        ),

                        SizedBox(height: h * 0.025),
                        _GoldDivider(),
                        SizedBox(height: h * 0.025),

                        // 签文
                        if (sign != null) ...[
                          Text(
                            '第 ${sign!.id} 签 · ${sign!.level.label}签',
                            style: TextStyle(
                              fontSize: w * 0.028, // 30/1080
                              color: AppColors.gray,
                              fontFamily: 'ChillJinshuSong',
                              letterSpacing: 2,
                            ),
                          ),
                          SizedBox(height: h * 0.0125), // 24/1920
                          Text(
                            '「${sign!.title}」',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: w * 0.056, // 60/1080
                              color: AppColors.inkBlack,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'ChillJinshuSong',
                              height: 1.3,
                            ),
                          ),
                          SizedBox(height: h * 0.019), // 36/1920
                          _GoldDivider(width: w * 0.074, hasDiamond: true),
                          SizedBox(height: h * 0.019),
                          Text(
                            sign!.poem,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: w * 0.031, // 34/1080
                              color: AppColors.inkBlack,
                              fontFamily: 'ChillJinshuSong',
                              height: 1.9,
                              letterSpacing: 1.5,
                            ),
                          ),

                          // ─── 解曰 ───
                          SizedBox(height: h * 0.025),
                          _SectionHeader(label: '解  曰', scale: w),
                          SizedBox(height: h * 0.008),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: w * 0.02),
                            child: Text(
                              sign!.interpretation,
                              style: TextStyle(
                                fontSize: w * 0.024, // 26/1080
                                color: AppColors.inkBlack,
                                fontFamily: 'ChillJinshuSong',
                                height: 1.6,
                              ),
                            ),
                          ),

                          // ─── 典故 ───
                          if (sign!.allusion.isNotEmpty) ...[
                            SizedBox(height: h * 0.018),
                            _SectionHeader(label: '典  故', scale: w),
                            SizedBox(height: h * 0.006),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: w * 0.02),
                              child: Text(
                                sign!.allusion,
                                style: TextStyle(
                                  fontSize: w * 0.022, // 24/1080
                                  color: AppColors.gray,
                                  fontFamily: 'ChillJinshuSong',
                                  height: 1.6,
                                ),
                              ),
                            ),
                          ],

                          // ─── 现代解读（取前 3 条）───
                          if (sign!.modernNotes.isNotEmpty) ...[
                            SizedBox(height: h * 0.02),
                            _SectionHeader(label: '现代解读', scale: w),
                            SizedBox(height: h * 0.006),
                            ...sign!.modernNotes.take(3).map((note) => Padding(
                                  padding: EdgeInsets.only(
                                    top: h * 0.005,
                                    left: w * 0.025,
                                    right: w * 0.02,
                                  ),
                                  child: _ModernNoteItem(text: note, scale: w),
                                )),
                          ],
                        ],

                        // 自适应撑开（替代写死 SizedBox）
                        const Spacer(),

                        // 落款
                        Text(
                          '— 弟子${city.isNotEmpty ? ' @ $city' : ''}',
                          style: TextStyle(
                            fontSize: w * 0.024, // 26/1080
                            color: AppColors.gray,
                            fontFamily: 'ChillJinshuSong',
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        SizedBox(height: h * 0.004), // 8/1920
                        Text(
                          '${date.year}.${date.month}.${date.day}',
                          style: TextStyle(
                            fontSize: w * 0.02, // 22/1080
                            color: AppColors.gray,
                            fontFamily: 'ChillJinshuSong',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 海报脚标
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: h * 0.03, // 60/1920
                  child: Center(
                    child: Text(
                      '来自「问妈祖 Ask Mazu」',
                      style: TextStyle(
                        color: AppColors.riceWhite,
                        fontSize: w * 0.022, // 24/1080
                        fontFamily: 'ChillJinshuSong',
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// 解析段标题（✦ + 文字，参考 result_page _Section 风格）
class _SectionHeader extends StatelessWidget {
  final String label;
  final double scale;
  const _SectionHeader({required this.label, required this.scale});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '✦',
          style: TextStyle(
            color: AppColors.mazuRed,
            fontSize: scale * 0.03, // 32/1080
            height: 1,
          ),
        ),
        SizedBox(width: scale * 0.012),
        Text(
          label,
          style: TextStyle(
            fontSize: scale * 0.028, // 30/1080
            color: AppColors.mazuRed,
            fontWeight: FontWeight.w700,
            fontFamily: 'ChillJinshuSong',
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}

/// 现代解读单条（• + 文字）
class _ModernNoteItem extends StatelessWidget {
  final String text;
  final double scale;
  const _ModernNoteItem({required this.text, required this.scale});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '•',
          style: TextStyle(
            fontSize: scale * 0.024, // 26/1080
            color: AppColors.mazuRed,
            fontFamily: 'ChillJinshuSong',
            height: 1.6,
          ),
        ),
        SizedBox(width: scale * 0.012),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: scale * 0.024, // 26/1080
              color: AppColors.inkBlack,
              fontFamily: 'ChillJinshuSong',
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }
}
class _GoldDivider extends StatelessWidget {
  final double? width;
  final bool hasDiamond;
  const _GoldDivider({this.width, this.hasDiamond = false});

  @override
  Widget build(BuildContext context) {
    if (!hasDiamond) {
      return SizedBox(
        width: width ?? double.infinity,
        child: Container(
          height: 1,
          color: AppColors.goldYellow,
        ),
      );
    }
    final w = width ?? double.infinity;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: w * 0.5,
          child: Container(height: 1, color: AppColors.goldYellow),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: w * 0.075),
          child: Transform.rotate(
            angle: 0.785398,
            child: Container(
              width: 10,
              height: 10,
              color: AppColors.goldYellow,
            ),
          ),
        ),
        SizedBox(
          width: w * 0.5,
          child: Container(height: 1, color: AppColors.goldYellow),
        ),
      ],
    );
  }
}

/// 截屏 RepaintBoundary → PNG bytes → 系统分享
class ShareService {
  /// 输出目标尺寸（朋友圈分享最优）
  static const double _targetW = 1080;
  static const double _targetH = 1920;

  /// 截屏 RepaintBoundary，返回 PNG bytes（输出 1080×1920 像素）
  static Future<Uint8List?> capture(GlobalKey boundaryKey) async {
    final ctx = boundaryKey.currentContext;
    if (ctx == null) return null;
    final boundary = ctx.findRenderObject();
    if (boundary is! RenderRepaintBoundary) return null;

    // 动态算 pixelRatio：保证输出 1080×1920
    final size = boundary.size;
    if (size.width <= 0 || size.height <= 0) return null;
    final pixelRatio = math.max(
      _targetW / size.width,
      _targetH / size.height,
    );

    final image = await boundary.toImage(pixelRatio: pixelRatio);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    if (byteData == null) return null;
    return byteData.buffer.asUint8List();
  }

  /// 截屏并调起系统分享面板
  static Future<void> captureAndShare({
    required GlobalKey boundaryKey,
    required ThrowResultType result,
  }) async {
    final bytes = await capture(boundaryKey);
    if (bytes == null) return;

    final resultLabel = switch (result) {
      ThrowResultType.saint => '圣杯',
      ThrowResultType.laugh => '笑杯',
      ThrowResultType.yin => '阴杯',
    };

    await Share.shareXFiles(
      [
        XFile.fromData(
          bytes,
          name: 'ask_mazu_${DateTime.now().millisecondsSinceEpoch}.png',
          mimeType: 'image/png',
        ),
      ],
      text: '🙏 妈祖所示 · $resultLabel',
    );
  }
}

/// 分享卡预览 + 分享按钮（bottom sheet）
class ShareCardSheet extends StatefulWidget {
  final ThrowResultType result;
  final FortuneSign? sign;
  final String message;
  final String question;
  final String name;
  final String city;

  const ShareCardSheet({
    super.key,
    required this.result,
    required this.sign,
    required this.message,
    required this.question,
    required this.name,
    required this.city,
  });

  @override
  State<ShareCardSheet> createState() => _ShareCardSheetState();
}

class _ShareCardSheetState extends State<ShareCardSheet> {
  final GlobalKey _boundaryKey = GlobalKey();
  bool _isCapturing = false;

  Future<void> _onShare() async {
    if (_isCapturing) return;
    setState(() => _isCapturing = true);

    try {
      await ShareService.captureAndShare(
        boundaryKey: _boundaryKey,
        result: widget.result,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('分享失败: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final screenW = media.size.width;
    final screenH = media.size.height - media.viewInsets.bottom;

    // 预览区域最大高度（留出标题 + 按钮的空间）
    final previewMaxH = screenH * 0.6;
    // 预览区域最大宽度
    final previewMaxW = screenW - 32; // 留 padding

    // 按 9:16 算实际显示尺寸：取按宽算的高 vs 按高算的宽 的较小者
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

            // 分享卡预览（完整显示 9:16）
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

            // 底部按钮
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: const Text('取消'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _isCapturing ? null : _onShare,
                    icon: _isCapturing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.share, size: 18),
                    label: Text(_isCapturing ? '生成中...' : '分享到微信'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.mazuRed,
                      minimumSize: const Size.fromHeight(48),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
