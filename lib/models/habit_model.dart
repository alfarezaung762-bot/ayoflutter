import 'package:hive/hive.dart';

part 'habit_model.g.dart';

@HiveType(typeId: 0)
class HabitModel extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String note;

  @HiveField(2)
  String time; // contoh: "08:00"

  @HiveField(3)
  int priority; // 0 = low, 1 = medium, 2 = high

  @HiveField(4)
  bool isDone; // untuk daily repeat

  @HiveField(5)
  String lastResetDate; // format yyyy-MM-dd

  HabitModel({
    required this.title,
    required this.note,
    required this.time,
    required this.priority,
    this.isDone = false,
    String? lastResetDate,
  }) : lastResetDate =
           lastResetDate ?? DateTime.now().toIso8601String().split('T').first;
}
