// lib/features/mazu/mazu_placeholder_page.dart
// 妈祖 tab 占位页(V1.2 不实装,留个入口)
//
// V1.2 安排:
//   - 妈祖文化内容(6 章)推迟到 V2 或更后
//   - 此页只显示「即将上线」占位
//
// 资产:无(纯文字 + CSS 渐变)

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class MazuPlaceholderPage extends StatelessWidget {
  const MazuPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF3E6E3),
            AppColors.riceWhite,
          ],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: AppColors.mazuRed.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.temple_hindu_outlined,
                    size: 44,
                    color: AppColors.mazuRed,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  '妈祖文化',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.inkBlack,
                    fontFamily: 'ChillJinshuSong',
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '章节阅读 · 即将上线',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.mazuRed,
                    fontFamily: 'ChillJinshuSong',
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'V1.2 上线后,我们会陆续放出:\n\n· 壹 · 妈祖生平\n· 贰 · 海上守护\n· 叁 · 信仰分布\n· 肆 · 经典故事\n· 伍 · 节庆由来\n· 陆 · 诗词文献',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.gray,
                    fontFamily: 'ChillJinshuSong',
                    height: 1.7,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}