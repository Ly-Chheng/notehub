import 'package:hive/hive.dart';

part 'timer_model.g.dart';

@HiveType(typeId: 0)
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
  DateTime createdAt;

  @HiveField(5)
  DateTime? completedAt;

  @HiveField(6)
  String type;

  TimerModel({
    required this.id,
    required this.title,
    required this.totalSeconds,
    required this.remainingSeconds,
    required this.createdAt,
    this.completedAt,
    this.type = 'timer',
  });

  bool get isFinished => remainingSeconds <= 0;
}