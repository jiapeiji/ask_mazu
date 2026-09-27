// lib/features/history/history_page.dart
// 问事记录

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/result_templates.dart';
import '../../data/models/question_record.dart';
import '../../data/models/fortune_sign.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/providers.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final code = ref.watch(settingsProvider).localeCode;
    final recordsAsync = ref.watch(recordsProvider);
    final signsAsync = ref.watch(signsProvider);

    return Scaffold(
      backgroundColor: AppColors.riceWhite,
      appBar: AppBar(
        title: Text(l.historyTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: recordsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l.historyLoadError(e.toString()))),
        data: (records) {
          if (records.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🙏', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 16),
                  Text(
                    l.historyEmpty,
                    style: const TextStyle(color: AppColors.gray),
                  ),
                ],
              ),
            );
          }

          // V1：所有用户都能看全部历史记录（自己的投掷记录，V0.1 的"7 天"限制移除）
          final filtered = records;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: filtered.length,
            itemBuilder: (context, i) {
              final record = filtered[i];
              final allSigns = signsAsync.valueOrNull ?? [];
              final sign = record.signId != null
                  ? allSigns.where((s) => s.id == record.signId).firstOrNull
                  : null;
              return _buildRecordCard(context, l, record, sign, code);
            },
          );
        },
      ),
    );
  }

  Widget _buildRecordCard(
    BuildContext context,
    AppLocalizations l,
    QuestionRecord record,
    FortuneSign? sign,
    String code,
  ) {
    final (resultColor, resultLabel) = switch (record.result) {
      ThrowResultType.saint => (AppColors.successGreen, l.historyResultSaint),
      ThrowResultType.laugh => (AppColors.hintYellow, l.historyResultLaugh),
      ThrowResultType.yin => (AppColors.warningRed, l.historyResultYin),
    };

    final timeStr = DateFormat('M月d日 HH:mm').format(record.timestamp);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: resultColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  resultLabel,
                  style: TextStyle(
                    fontSize: 12,
                    color: resultColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  sign != null
                      ? l.historySignTitle(sign.level.label, sign.id.toString(), sign.getTitle(code))
                      : l.historyNoSign,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.inkBlack,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.help_outline, size: 14, color: AppColors.gray),
              const SizedBox(width: 4),
              Text(
                l.historyAsk(record.question),
                style: const TextStyle(fontSize: 13, color: AppColors.gray),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.access_time, size: 14, color: AppColors.gray),
              const SizedBox(width: 4),
              Text(
                timeStr,
                style: const TextStyle(fontSize: 12, color: AppColors.gray),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
