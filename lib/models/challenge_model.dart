import 'package:hive/hive.dart';

part 'challenge_model.g.dart';

@HiveType(typeId: 3)
class ChallengeModel extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String description;

  @HiveField(2)
  int durationDays; // Target durasi (7, 14, 30, 90)

  @HiveField(3)
  int colorCode;

  @HiveField(4)
  bool isJoined;

  @HiveField(5)
  int progressDay; // Sudah berapa hari yang "Complete" (Selesai sepenuhnya)

  @HiveField(6)
  List<String> dailyTasks;

  // --- FIELD BARU ---

  @HiveField(7)
  DateTime? startDate; // Kapan user mulai join challenge ini

  @HiveField(8)
  DateTime? lastUpdated; // Untuk mereset checklist jika hari berganti

  @HiveField(9)
  List<bool> todayTaskStatus; // Menyimpan status checklist hari ini

  @HiveField(10)
  String? reminderTime; // Jam alarm (format "HH:mm")

  @HiveField(11)
  int? alarmId; // ID unik untuk mematikan alarm nanti

  ChallengeModel({
    required this.title,
    required this.description,
    required this.durationDays,
    required this.colorCode,
    required this.dailyTasks,
    this.isJoined = false,
    this.progressDay = 0,
    this.startDate,
    this.lastUpdated,
    this.todayTaskStatus = const [], // Default kosong
    this.reminderTime,
    this.alarmId,
  });
}
