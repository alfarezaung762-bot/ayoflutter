// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scheduled_habit_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ScheduledHabitModelAdapter extends TypeAdapter<ScheduledHabitModel> {
  @override
  final int typeId = 1;

  @override
  ScheduledHabitModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ScheduledHabitModel(
      title: fields[0] as String,
      note: fields[1] as String,
      date: fields[2] as DateTime,
      time: fields[3] as String,
      priority: fields[5] as int,
      isDone: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ScheduledHabitModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.note)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.time)
      ..writeByte(4)
      ..write(obj.isDone)
      ..writeByte(5)
      ..write(obj.priority);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScheduledHabitModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
