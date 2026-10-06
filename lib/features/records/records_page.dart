// lib/features/records/records_page.dart
// 记录 tab(原 history_page, V1.2 重构为日记流)
//
// V1.2 (v5) 改动:
//   - 重命名 history → records
//   - tab 结构:全部 / 仅思考 / 含妈祖反馈 / 收藏
//   - 日记流按月分组(月份分隔)
//   - 卡片:日期 + 用户思考摘要 + 签文标题 + 妈祖反馈摘要
//
// TODO(下轮补):
//   - 月历视图(getByDate + 月历)
//   - 连续天数计算(getStreak)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/question_record.dart';
import '../../data/models/fortune_sign.dart';
import '../../core/utils/result_templates.dart';
import '../../providers/providers.dart';

class RecordsPage extends ConsumerStatefulWidget {
  const RecordsPage({super.key});

  @override
  ConsumerState<RecordsPage> createState() => _RecordsPageState();
}

class _RecordsPageState extends ConsumerState<RecordsPage> {
  String _filter = 'all'; // 'all' | 'thinking' | 'withMazu' | 'starred'
  int _streak = 0;

  @override
  void initState() {
    super.initState();
    _loadStreak();
  }

  Future<void> _loadStreak() async {
    final repo = ref.read(recordRepositoryProvider);
    final s = await repo.getStreak();
    if (mounted) setState(() => _streak = s);
  }

  @override
  Widget build(BuildContext context) {
    final recordsAsync = ref.watch(recordsProvider);

    return Scaffold(
      backgroundColor: AppColors.riceWhite,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            // 顶部标题
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
              child: Row(
                children: [
                  const Text(
                    '记录',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.inkBlack,
                      fontFamily: 'ChillJinshuSong',
                    ),
                  ),
                  const Spacer(),
                  // 统计
                  recordsAsync.maybeWhen(
                    data: (records) => Text(
                      '共 ${records.length} 条',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.gray,
                        fontFamily: 'ChillJinshuSong',
                      ),
                    ),
                    orElse: () => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
            // 连续天数 banner(轻量视觉)
            if (_streak > 0)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5ECD9),
                    border: Border.all(color: const Color(0xFFD4A24C)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '$_streak',
                        style: const TextStyle(
                          fontFamily: 'ChillJinshuSong',
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.mazuRed,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              '连续记录天数',
                              style: TextStyle(
                                fontFamily: 'ChillJinshuSong',
                                fontSize: 12,
                                color: AppColors.inkBlack,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              '不必每条都长,但保持在场',
                              style: TextStyle(
                                fontFamily: 'ChillJinshuSong',
                                fontSize: 11,
                                color: AppColors.gray,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // 筛选 tab
            _buildFilterTabs(),
            const SizedBox(height: 8),
            // 日记流
            Expanded(
              child: recordsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Text('加载失败: $e', style: const TextStyle(color: AppColors.gray)),
                ),
                data: (records) {
                  final filtered = _applyFilter(records);
                  if (filtered.isEmpty) {
                    return _buildEmptyState();
                  }
                  return _buildList(filtered);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    final tabs = [
      ('all', '全部'),
      ('thinking', '仅思考'),
      ('withMazu', '含妈祖反馈'),
      ('starred', '收藏'),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: tabs.map((t) {
          final selected = t.$1 == _filter;
          return Padding(
            padding: const EdgeInsets.only(right: 14),
            child: GestureDetector(
              onTap: () => setState(() => _filter = t.$1),
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: selected ? AppColors.mazuRed : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  t.$2,
                  style: TextStyle(
                    fontSize: 13,
                    color: selected ? AppColors.mazuRed : AppColors.gray,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    fontFamily: 'ChillJinshuSong',
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 简单筛选(收藏功能 V1.2 暂未实装 — 按 fallback 处理)
  List<QuestionRecord> _applyFilter(List<QuestionRecord> records) {
    switch (_filter) {
      case 'thinking':
        // 仅思考 = 妈祖反馈为空(签文为圣杯才有签文记录)
        return records.where((r) => r.signId == null).toList();
      case 'withMazu':
        return records.where((r) => r.signId != null).toList();
      case 'starred':
        return records; // TODO:实装收藏功能
      case 'all':
      default:
        return records;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.history, size: 56, color: AppColors.gray),
          const SizedBox(height: 14),
          const Text(
            '还没有记录',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.gray,
              fontFamily: 'ChillJinshuSong',
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            '去反思 tab 开始今日记录',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.gray,
              fontFamily: 'ChillJinshuSong',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<QuestionRecord> records) {
    // 按月份分组
    final groups = <String, List<QuestionRecord>>{};
    for (final r in records) {
      final key = '${r.timestamp.year}-${r.timestamp.month.toString().padLeft(2, '0')}';
      groups.putIfAbsent(key, () => []).add(r);
    }
    final sortedKeys = groups.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: sortedKeys.length,
      itemBuilder: (context, gi) {
        final key = sortedKeys[gi];
        final monthRecords = groups[key]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 8, 10),
              child: Text(
                _monthLabel(key),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.mazuRed,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'ChillJinshuSong',
                  letterSpacing: 0.4,
                ),
              ),
            ),
            ...monthRecords.map((r) => _buildRecordCard(r)),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  String _monthLabel(String key) {
    final parts = key.split('-');
    return '${parts[0]} 年 ${int.parse(parts[1])} 月';
  }

  Widget _buildRecordCard(QuestionRecord r) {
    final hasMazu = r.signId != null;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.lightGray),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                _formatDate(r.timestamp),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.gray,
                  fontFamily: 'ChillJinshuSong',
                ),
              ),
              const Spacer(),
              if (hasMazu)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5ECD9),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    '妈祖反馈',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.goldYellow,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'ChillJinshuSong',
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '「${r.question}」',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.inkBlack,
              fontFamily: 'ChillJinshuSong',
              height: 1.5,
            ),
          ),
          if (hasMazu) ...[
            const SizedBox(height: 6),
            const Icon(Icons.arrow_downward, size: 12, color: AppColors.gray),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF7F0),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                '签文已附',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.inkBlack,
                  fontFamily: 'ChillJinshuSong',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    final wd = weekdays[dt.weekday - 1];
    return '${dt.month}月${dt.day}日 · $wd';
  }
}
