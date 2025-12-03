import 'package:hive/hive.dart';

part 'tutorial_model.g.dart';

@HiveType(typeId: 2) // ID Unik
class TutorialModel extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String description;

  @HiveField(2)
  String videoUrl; // Link YouTube

  TutorialModel({
    required this.title,
    required this.description,
    required this.videoUrl,
  });
}
