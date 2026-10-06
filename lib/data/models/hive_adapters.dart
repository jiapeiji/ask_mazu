// lib/data/models/hive_adapters.dart
// 手动实现的 Hive TypeAdapters
//
// V1.2 (v5) 改动:
//   - UserProfile:city 字段删除
//   - QuestionRecord:暂不动(mood 字段改造留到 W2 与 category 字段一起)

import 'package:hive/hive.dart';

import 'user_profile.dart';
import 'question_record.dart';
import '../../core/utils/result_templates.dart';
import 'fortune_sign.dart';

class UserProfileAdapter extends TypeAdapter<UserProfile> {
  @override
  final int typeId = 0;

  @override
  UserProfile read(BinaryReader reader) {
    final fields = <int, dynamic>{};
    final numOfFields = reader.readByte();
    for (int i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      fields[key] = reader.read();
    }
    return UserProfile(
      name: fields[0] as String,
      createdAt: fields[1] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, UserProfile obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.createdAt);
  }
}

class QuestionRecordAdapter extends TypeAdapter<QuestionRecord> {
  @override
  final int typeId = 1;

  @override
  QuestionRecord read(BinaryReader reader) {
    final fields = <int, dynamic>{};
    final numOfFields = reader.readByte();
    for (int i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      fields[key] = reader.read();
    }
    return QuestionRecord(
      id: fields[0] as String,
      timestamp: fields[1] as DateTime,
      question: fields[2] as String,
      category: SignCategory.values.byName(fields[3] as String),
      result: ThrowResultType.values.byName(fields[4] as String),
      signId: fields[5] as int?,
      nameAtTime: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, QuestionRecord obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.timestamp)
      ..writeByte(2)
      ..write(obj.question)
      ..writeByte(3)
      ..write(obj.category.name)
      ..writeByte(4)
      ..write(obj.result.name)
      ..writeByte(5)
      ..write(obj.signId)
      ..writeByte(6)
      ..write(obj.nameAtTime);
  }
}
