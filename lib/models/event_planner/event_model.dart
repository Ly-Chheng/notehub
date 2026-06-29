class EventModel {
  final int? id;
  final String title;
  final String date; // YYYY-MM-DD
  final String time; // HH:MM
  final String location;
  final String reminderTime;
  final bool isCompleted;
  final String? icon;
  final int? color;
  final String? reminderDate; // YYYY-MM-DD
  final String? reminderTimer; // HH:MM

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

  // Helper to calculate remaining days
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

class RevisionTopic {
  final int? id;
  final int examId;
  final String name;
  final String notes;
  final String priority;
  final String dueDate;

  RevisionTopic({
    this.id,
    required this.examId,
    required this.name,
    required this.notes,
    required this.priority,
    required this.dueDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'exam_id': examId,
      'name': name,
      'notes': notes,
      'priority': priority,
      'due_date': dueDate,
    };
  }

  factory RevisionTopic.fromMap(Map<String, dynamic> map) {
    return RevisionTopic(
      id: map['id'],
      examId: map['exam_id'],
      name: map['name'],
      notes: map['notes'] ?? '',
      priority: map['priority'] ?? 'Medium',
      dueDate: map['due_date'] ?? '',
    );
  }
}

class RevisionSubtopic {
  final int? id;
  final int topicId;
  final String name;
  final bool isCompleted;

  RevisionSubtopic({
    this.id,
    required this.topicId,
    required this.name,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'topic_id': topicId,
      'name': name,
      'is_completed': isCompleted ? 1 : 0,
    };
  }

  factory RevisionSubtopic.fromMap(Map<String, dynamic> map) {
    return RevisionSubtopic(
      id: map['id'],
      topicId: map['topic_id'],
      name: map['name'],
      isCompleted: map['is_completed'] == 1,
    );
  }
}
