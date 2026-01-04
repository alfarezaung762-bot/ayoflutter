// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'challenge_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChallengeModelAdapter extends TypeAdapter<ChallengeModel> {
  @override
  final int typeId = 3;

  @override
  ChallengeModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChallengeModel(
      title: fields[0] as String,
      description: fields[1] as String,
      durationDays: fields[2] as int,
      colorCode: fields[3] as int,
      dailyTasks: (fields[6] as List).cast<String>(),
      isJoined: fields[4] as bool,
      progressDay: fields[5] as int,
      startDate: fields[7] as DateTime?,
      lastUpdated: fields[8] as DateTime?,
      todayTaskStatus: (fields[9] as List).cast<bool>(),
      reminderTime: fields[10] as String?,
      alarmId: fields[11] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, ChallengeModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.durationDays)
      ..writeByte(3)
      ..write(obj.colorCode)
      ..writeByte(4)
      ..write(obj.isJoined)
      ..writeByte(5)
      ..write(obj.progressDay)
      ..writeByte(6)
      ..write(obj.dailyTasks)
      ..writeByte(7)
      ..write(obj.startDate)
      ..writeByte(8)
      ..write(obj.lastUpdated)
      ..writeByte(9)
      ..write(obj.todayTaskStatus)
      ..writeByte(10)
      ..write(obj.reminderTime)
      ..writeByte(11)
      ..write(obj.alarmId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChallengeModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
