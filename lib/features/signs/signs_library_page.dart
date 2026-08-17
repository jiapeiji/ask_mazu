// lib/features/signs/signs_library_page.dart
// 签文库

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/fortune_sign.dart';
import '../../providers/providers.dart';

class SignsLibraryPage extends ConsumerWidget {
  const SignsLibraryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signsAsync = ref.watch(signsProvider);
    final isSubscribed = ref.watch(isSubscribedProvider);

    return Scaffold(
      backgroundColor: AppColors.riceWhite,
      appBar: AppBar(
        title: const Text('签 文 库'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: signsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('加载失败: $e')),
        data: (allSigns) {
          // 按等级分组
          final grouped = <FortuneLevel, List<FortuneSign>>{};
          for (final s in allSigns) {
            grouped.putIfAbsent(s.level, () => []).add(s);
          }

          final levelOrder = [
            FortuneLevel.upperUpper,
            FortuneLevel.upperMid,
            FortuneLevel.midUpper,
            FortuneLevel.mid,
            FortuneLevel.midLower,
            FortuneLevel.lowerUpper,
            FortuneLevel.lowerMid,
            FortuneLevel.lowerLower,
          ];

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: levelOrder.length,
            itemBuilder: (context, i) {
              final level = levelOrder[i];
              final signs = grouped[level] ?? [];
              if (signs.isEmpty) return const SizedBox.shrink();

              return _buildLevelSection(
                context: context,
                level: level,
                signs: signs,
                isSubscribed: isSubscribed,
                allSigns: allSigns,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildLevelSection({
    required BuildContext context,
    required FortuneLevel level,
    required List<FortuneSign> signs,
    required bool isSubscribed,
    required List<FortuneSign> allSigns,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 16, 8, 12),
          child: Text(
            '━━━ ${level.label} ━━━',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.mazuRed,
              letterSpacing: 0.2,
            ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.6,
          ),
          itemCount: signs.length,
          itemBuilder: (context, i) {
            final sign = signs[i];
            final isLocked = !isSubscribed && sign.id > AppConstants.freeSignsLimit;
            return _buildSignCard(context, sign, isLocked);
          },
        ),
      ],
    );
  }

  Widget _buildSignCard(BuildContext context, FortuneSign sign, bool isLocked) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => _SignDetailPage(sign: sign),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.lightGray),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.goldYellow.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${sign.id}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.goldYellow,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (isLocked) ...[
                  const Spacer(),
                  const Icon(Icons.lock, size: 14, color: AppColors.gray),
                ],
              ],
            ),
            Text(
              '「${sign.title}」',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isLocked ? AppColors.gray : AppColors.inkBlack,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SignDetailPage extends StatelessWidget {
  final FortuneSign sign;
  const _SignDetailPage({required this.sign});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.riceWhite,
      appBar: AppBar(
        title: Text('第 ${sign.id} 签'),
        backgroundColor: AppColors.riceWhite,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.goldYellow, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.goldYellow,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${sign.level.label}签',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '「${sign.title}」',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.inkBlack,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                sign.poem,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.inkBlack,
                  height: 1.8,
                ),
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 12),
              const Text(
                '解 曰',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.gray,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                sign.interpretation,
                style: const TextStyle(fontSize: 14, height: 1.6),
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 12),
              const Text(
                '典 故',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.gray,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                sign.allusion,
                style: const TextStyle(fontSize: 14, height: 1.6),
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 12),
              const Text(
                '现代解读',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.gray,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ...sign.modernNotes.map(
                (note) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '· $note',
                    style: const TextStyle(fontSize: 14, height: 1.6),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
