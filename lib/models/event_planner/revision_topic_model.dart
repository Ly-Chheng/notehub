class RevisionTopic {
  final int? id;
  final int eventId;
  final String name;
  final String notes;
  final String priority;
  final String dueDate;
  final bool isCompleted;

  RevisionTopic({
    this.id,
    required this.eventId,
    required this.name,
    required this.notes,
    required this.priority,
    required this.dueDate,
    this.isCompleted = false,
  });

  factory RevisionTopic.fromMap(Map<String, dynamic> map) {
    return RevisionTopic(
      id: map['id'] as int?,
      eventId: map['event_id'] as int,
      name: map['name'] as String,
      notes: map['notes'] as String? ?? '',
      priority: map['priority'] as String? ?? 'Medium',
      dueDate: map['due_date'] as String? ?? '',
      isCompleted: (map['is_completed'] as int? ?? 0) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'event_id': eventId,
      'name': name,
      'notes': notes,
      'priority': priority,
      'due_date': dueDate,
      'is_completed': isCompleted ? 1 : 0,
    };
  }
}
