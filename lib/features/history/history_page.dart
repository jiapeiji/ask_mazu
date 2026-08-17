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
import '../../providers/providers.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(recordsProvider);
    final signsAsync = ref.watch(signsProvider);
    final isSubscribed = ref.watch(isSubscribedProvider);

    return Scaffold(
      backgroundColor: AppColors.riceWhite,
      appBar: AppBar(
        title: const Text('问 事 记 录'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: recordsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('加载失败: $e')),
        data: (records) {
          if (records.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('🙏', style: TextStyle(fontSize: 48)),
                  SizedBox(height: 16),
                  Text(
                    '暂无问事记录',
                    style: TextStyle(color: AppColors.gray),
                  ),
                ],
              ),
            );
          }

          // 免费版只显示最近 7 天
          final filtered = isSubscribed
              ? records
              : records.where((r) =>
                  r.timestamp.isAfter(DateTime.now().subtract(const Duration(days: 7)))
                ).toList();

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: filtered.length,
            itemBuilder: (context, i) {
              final record = filtered[i];
              final allSigns = signsAsync.valueOrNull ?? [];
              final sign = record.signId != null
                  ? allSigns.where((s) => s.id == record.signId).firstOrNull
                  : null;
              return _buildRecordCard(context, record, sign, isSubscribed);
            },
          );
        },
      ),
    );
  }

  Widget _buildRecordCard(
    BuildContext context,
    QuestionRecord record,
    FortuneSign? sign,
    bool isSubscribed,
  ) {
    final (resultColor, resultLabel) = switch (record.result) {
      ThrowResultType.saint => (AppColors.successGreen, '圣杯'),
      ThrowResultType.laugh => (AppColors.hintYellow, '笑杯'),
      ThrowResultType.yin => (AppColors.warningRed, '阴杯'),
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
                  color: resultColor.withOpacity(0.1),
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
                      ? '${sign.level.label}签 · 第 ${sign.id} 签「${sign.title}」'
                      : '未得签文',
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
                '问：${record.question}',
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
