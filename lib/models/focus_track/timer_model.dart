import 'package:hive/hive.dart';

part 'timer_model.g.dart'; // This file will be generated

@HiveType(typeId: 0) // Unique ID for this class
class TimerModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  int totalSeconds;

  @HiveField(3)
  int remainingSeconds;

  @HiveField(4)
  String type;

  @HiveField(5)
  DateTime? createdAt;

  @HiveField(6)
  DateTime? completedAt;

  TimerModel({
    required this.id,
    required this.title,
    required this.totalSeconds,
    required this.remainingSeconds,
    this.type = 'timer',
    this.createdAt,
    this.completedAt,
  });
}