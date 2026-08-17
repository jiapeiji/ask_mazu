// lib/data/models/question_record.dart
// 问事记录数据模型

import 'fortune_sign.dart';
import '../../core/utils/result_templates.dart';

class QuestionRecord {
  final String id;
  final DateTime timestamp;
  final String question;
  final SignCategory category;
  final ThrowResultType result;
  final int? signId;          // 签文 ID（圣杯/阴杯才有）
  final String nameAtTime;    // 当时的报家门名字

  const QuestionRecord({
    required this.id,
    required this.timestamp,
    required this.question,
    required this.category,
    required this.result,
    this.signId,
    required this.nameAtTime,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'question': question,
        'category': category.name,
        'result': result.name,
        'signId': signId,
        'nameAtTime': nameAtTime,
      };

  factory QuestionRecord.fromJson(Map<String, dynamic> json) {
    return QuestionRecord(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      question: json['question'] as String,
      category: SignCategoryExtension.fromString(json['category'] as String),
      result: ThrowResultType.values.firstWhere(
        (e) => e.name == json['result'],
        orElse: () => ThrowResultType.saint,
      ),
      signId: json['signId'] as int?,
      nameAtTime: json['nameAtTime'] as String,
    );
  }
}
