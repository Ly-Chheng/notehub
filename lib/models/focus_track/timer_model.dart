class TimerModel {
  final dynamic id;
  final String title;
  final int totalSeconds;
  int remainingSeconds;
  final String type;
  final DateTime? createdAt;
  final DateTime? completedAt;

  TimerModel({
    required this.id,
    required this.title,
    required this.totalSeconds,
    required this.remainingSeconds,
    this.type = 'timer',
    this.createdAt,
    this.completedAt,
  });

  factory TimerModel.fromMap(dynamic key, Map data) {
    return TimerModel(
      id: key,
      title: data['title'] ?? 'Timer',
      totalSeconds: data['totalSeconds'] ?? 0,
      remainingSeconds: data['remainingSeconds'] ?? 0,
      type: data['type'] ?? 'timer',
      createdAt: data['createdAt'] != null ? DateTime.tryParse(data['createdAt']) : null,
      completedAt: data['completedAt'] != null ? DateTime.tryParse(data['completedAt']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'totalSeconds': totalSeconds,
      'remainingSeconds': remainingSeconds,
      'type': type,
      'createdAt': createdAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  double get progress => totalSeconds > 0 ? remainingSeconds / totalSeconds : 0.0;

  bool get isFinished => remainingSeconds <= 0;
}
