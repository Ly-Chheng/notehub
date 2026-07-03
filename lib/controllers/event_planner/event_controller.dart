import 'package:project_structure/core/database/database_service.dart';
import 'package:project_structure/models/event_planner/event_model.dart';

class EventPlannerController {
  EventPlannerController();
  final List<Map<String, dynamic>> availableIcons = [
    {'name': 'study', 'image': 'assets/images/study.png'},
    {'name': 'work', 'image': 'assets/images/work.png'},
    {'name': 'todo', 'image': 'assets/images/todo.png'},
    {'name': 'meeting', 'image': 'assets/images/meeting.png'},
  ];

  /// Fetches either upcoming or completed even
  Future<List<EventModel>> fetchEvent({required bool completed}) async {
    try {
      final dbClient = await DatabaseService.db;
      final List<Map<String, dynamic>> maps = await dbClient.query(
        'exams',
        where: 'is_completed = ?',
        whereArgs: [completed ? 1 : 0],
        orderBy: 'date ASC',
      );
      return List.generate(maps.length, (i) => EventModel.fromMap(maps[i]));
    } catch (e) {
      return [];
    }
  }

  /// Adds a new event to the database
  Future<int> createEvent(EventModel exam) async {
    final dbClient = await DatabaseService.db;
    return await dbClient.insert('exams', exam.toMap());
  }

  /// Updates an existing event entry in the database
  Future<int> updateEvent(EventModel exam) async {
    final dbClient = await DatabaseService.db;
    return await dbClient.update(
      'exams',
      exam.toMap(),
      where: 'id = ?',
      whereArgs: [exam.id],
    );
  }

  /// Updates the completion status of an exam
  Future<void> updateEventCompletionStatus(int examId, bool isCompleted) async {
    final dbClient = await DatabaseService.db;
    await dbClient.update(
      'exams',
      {'is_completed': isCompleted ? 1 : 0},
      where: 'id = ?',
      whereArgs: [examId],
    );
  }

  /// Gets all parent revision modules associated with an exam
  Future<List<RevisionTopic>> fetchTopicsForExam(int examId) async {
    final dbClient = await DatabaseService.db;
    final List<Map<String, dynamic>> maps = await dbClient.query(
      'revision_topics',
      where: 'exam_id = ?',
      whereArgs: [examId],
    );
    return List.generate(maps.length, (i) => RevisionTopic.fromMap(maps[i]));
  }

  /// Adds a parent revision topic under a specific exam
  Future<int> createTopic(RevisionTopic topic) async {
    final dbClient = await DatabaseService.db;
    return await dbClient.insert('revision_topics', topic.toMap());
  }

  /// Deletes an individual revision topic item
  Future<void> deleteTopic(int topicId) async {
    final dbClient = await DatabaseService.db;
    await dbClient.delete(
      'revision_topics',
      where: 'id = ?',
      whereArgs: [topicId],
    );
  }

  /// Updates the text/title of an individual revision topic
  Future<void> updateTopicName(int topicId, String newName) async {
    final dbClient = await DatabaseService.db;
    await dbClient.update(
      'revision_topics',
      {'name': newName},
      where: 'id = ?',
      whereArgs: [topicId],
    );
  }

  /// Updates the completion status of an individual revision topic
  Future<void> updateTopicCompletionStatus(int topicId, bool isCompleted) async {
    final dbClient = await DatabaseService.db;
    await dbClient.update(
      'revision_topics',
      {'is_completed': isCompleted ? 1 : 0},
      where: 'id = ?',
      whereArgs: [topicId],
    );
  }

  /// Deletes an event and its associated cascading data
  Future<int> deleteEvent(int examId) async {
    final dbClient = await DatabaseService.db;

    // Using a transaction ensures both topics and the exam itself are cleaned up reliably
    return await dbClient.transaction((txn) async {
      // 1. Delete associated subtopics via topics mapping if CASCADE isn't configured in SQL
      await txn.rawDelete('''
        DELETE FROM revision_subtopics 
        WHERE topic_id IN (SELECT id FROM revision_topics WHERE exam_id = ?)
      ''', [examId]);

      // 2. Delete main topic modules
      await txn.delete(
        'revision_topics',
        where: 'exam_id = ?',
        whereArgs: [examId],
      );

      // 3. Finally, delete the root exam record
      return await txn.delete(
        'exams',
        where: 'id = ?',
        whereArgs: [examId],
      );
    });
  }
}
