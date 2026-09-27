// lib/features/signs/signs_library_page.dart
// 签文库

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/fortune_sign.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/providers.dart';

class SignsLibraryPage extends ConsumerWidget {
  const SignsLibraryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final code = ref.watch(settingsProvider).localeCode;
    final signsAsync = ref.watch(signsProvider);
    final hasUnlimited = ref.watch(hasUnlimitedAccessProvider);

    return Scaffold(
      backgroundColor: AppColors.riceWhite,
      appBar: AppBar(
        title: Text(l.signsTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: signsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l.signsLoadError(e.toString()))),
        data: (allSigns) {
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
                hasUnlimited: hasUnlimited,
                l: l,
                code: code,
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
    required bool hasUnlimited,
    required AppLocalizations l,
    required String code,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 16, 8, 12),
          child: Text(
            '━━━ ${level.label}签 ━━━',
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
            // V1：试用到期后签文库全部锁住（不保留 V0.1 的前 30 支可看）
            final isLocked = !hasUnlimited;
            return _buildSignCard(context, sign, isLocked, code);
          },
        ),
      ],
    );
  }

  Widget _buildSignCard(BuildContext context, FortuneSign sign, bool isLocked, String code) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => _SignDetailPage(sign: sign, localeCode: code),
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
                    color: AppColors.goldYellow.withValues(alpha: 0.15),
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
              '「${sign.getTitle(code)}」',
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
  final String localeCode;
  const _SignDetailPage({required this.sign, required this.localeCode});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.riceWhite,
      appBar: AppBar(
        title: Text(l.signsDetailTitle(sign.id.toString())),
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
                    '「${sign.getTitle(localeCode)}」',
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
                sign.getPoem(localeCode),
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.inkBlack,
                  height: 1.8,
                ),
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 12),
              Text(
                l.signsDetailInterpretation,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.gray,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                sign.getInterpretation(localeCode),
                style: const TextStyle(fontSize: 14, height: 1.6),
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 12),
              Text(
                l.signsDetailAllusion,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.gray,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                sign.getAllusion(localeCode),
                style: const TextStyle(fontSize: 14, height: 1.6),
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 12),
              Text(
                l.signsDetailModern,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.gray,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ...sign.getModernNotes(localeCode).map(
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
