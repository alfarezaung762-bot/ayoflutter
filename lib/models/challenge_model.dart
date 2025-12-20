import 'package:hive/hive.dart';

part 'challenge_model.g.dart';

@HiveType(typeId: 3)
class ChallengeModel extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String description;

  @HiveField(2)
  int durationDays; // Misal: 7 hari, 30 hari

  @HiveField(3)
  int colorCode; // Kita simpan warna sebagai integer (0xFF...)

  @HiveField(4)
  bool isJoined; // Apakah user sudah join challenge ini?

  @HiveField(5)
  int progressDay; // Hari ke berapa sekarang (Misal: Hari ke-1)

  @HiveField(6)
  List<String> dailyTasks; // Daftar tugas harian (Misal: ["Minum air", "Lari"])

  ChallengeModel({
    required this.title,
    required this.description,
    required this.durationDays,
    required this.colorCode,
    this.isJoined = false,
    this.progressDay = 0,
    required this.dailyTasks,
  });
}
