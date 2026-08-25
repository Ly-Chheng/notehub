class EventModel {
  final int? id;
  final String title;
  final String date;
  final String time;
  final String location;
  final String reminderTime;
  final bool isCompleted;
  final String? icon;
  final int? color;
  final String? reminderDate;
  final String? reminderTimer;

  EventModel({
    this.id,
    required this.title,
    required this.date,
    required this.time,
    required this.location,
    required this.reminderTime,
    this.isCompleted = false,
    this.icon,
    this.color,
    this.reminderDate,
    this.reminderTimer,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'date': date,
      'time': time,
      'location': location,
      'reminder_time': reminderTime,
      'is_completed': isCompleted ? 1 : 0,
      'icon': icon,
      'color': color,
      'reminder_date': reminderDate,
      'reminder_timer': reminderTimer,
    };
  }

  factory EventModel.fromMap(Map<String, dynamic> map) {
    return EventModel(
      id: map['id'],
      title: map['title'] ?? '',
      date: map['date'] ?? '',
      time: map['time'] ?? '',
      location: map['location'] ?? '',
      reminderTime: map['reminder_time'] ?? '',
      isCompleted: map['is_completed'] == 1,
      icon: map['icon'],
      color: map['color'],
      reminderDate: map['reminder_date'],
      reminderTimer: map['reminder_timer'],
    );
  }

  int get daysLeft {
    try {
      final examDate = DateTime.parse(date);
      final now = DateTime.now();
      final difference = examDate.difference(DateTime(now.year, now.month, now.day)).inDays;
      return difference < 0 ? 0 : difference;
    } catch (_) {
      return 0;
    }
  }
}
