import 'package:hive/hive.dart';

part 'scheduled_habit_model.g.dart';

@HiveType(typeId: 1) // ID harus beda dengan HabitModel
class ScheduledHabitModel extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String note;

  @HiveField(2)
  DateTime date; // INI KUNCINYA: Tanggal spesifik

  @HiveField(3)
  String time; // Jam (misal: 14:00)

  @HiveField(4)
  bool isDone;

  @HiveField(5)
  int priority; // 0=Low, 1=Med, 2=High

  ScheduledHabitModel({
    required this.title,
    required this.note,
    required this.date,
    required this.time,
    required this.priority,
    this.isDone = false,
  });
}
