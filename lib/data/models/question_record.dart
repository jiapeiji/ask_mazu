// lib/data/models/question_record.dart
// 反思记录数据模型
//
// V1.2 (v5) 改动:
//   - SignCategory category 字段删除(V1.2 不再按类目筛签)
//   - 加 Mood mood 字段(5 个心情枚举)

import 'fortune_sign.dart';
import '../../core/utils/result_templates.dart';

/// V1.2 心情枚举(用户在反思 tab 必选 1)
enum Mood {
  peaceful('平和', '☺'),
  down('低落', '☹'),
  confused('迷茫', '😶'),
  fulfilled('充实', '😌'),
  frustrated('烦躁', '😠');

  final String label;
  final String emoji;
  const Mood(this.label, this.emoji);

  static Mood fromString(String s) {
    return Mood.values.firstWhere(
      (e) => e.name == s,
      orElse: () => Mood.confused,
    );
  }
}

class QuestionRecord {
  final String id;
  final DateTime timestamp;
  final String question;        // 用户反思文本(可空)
  final Mood mood;              // 心情(必选 1)
  final ThrowResultType result; // 投掷结果(圣/笑/阴)
  final int? signId;            // 签文 ID(圣杯/阴杯才有)
  final String nameAtTime;      // 当时的报家门名字

  const QuestionRecord({
    required this.id,
    required this.timestamp,
    required this.question,
    required this.mood,
    required this.result,
    this.signId,
    required this.nameAtTime,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'question': question,
        'mood': mood.name,
        'result': result.name,
        'signId': signId,
        'nameAtTime': nameAtTime,
      };

  factory QuestionRecord.fromJson(Map<String, dynamic> json) {
    return QuestionRecord(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      question: json['question'] as String,
      mood: Mood.fromString(json['mood'] as String),
      result: ThrowResultType.values.firstWhere(
        (e) => e.name == json['result'],
        orElse: () => ThrowResultType.saint,
      ),
      signId: json['signId'] as int?,
      nameAtTime: json['nameAtTime'] as String,
    );
  }
}
