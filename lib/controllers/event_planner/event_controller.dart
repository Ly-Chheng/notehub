import 'package:project_structure/core/database/database_service.dart';
import 'package:project_structure/models/event_planner/event_model.dart';

class EventPlannerController {
  EventPlannerController();

  /// Fetches either upcoming or completed exams depending on the [completed] flag
  Future<List<EventModel>> fetchExams({required bool completed}) async {
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

  /// Adds a new exam schedule entry to the database
  Future<int> createExam(EventModel exam) async {
    final dbClient = await DatabaseService.db;
    return await dbClient.insert('exams', exam.toMap());
  }

  /// Adds a parent revision topic under a specific exam
  Future<int> createTopic(RevisionTopic topic) async {
    final dbClient = await DatabaseService.db;
    return await dbClient.insert('revision_topics', topic.toMap());
  }

  /// Adds an individual checklist item subtopic under a main topic
  Future<int> createSubtopic(RevisionSubtopic subtopic) async {
    final dbClient = await DatabaseService.db;
    return await dbClient.insert('revision_subtopics', subtopic.toMap());
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

  /// Resolves all atomic checklist items tied to a single parent topic module
  Future<List<RevisionSubtopic>> fetchSubtopicsForTopic(int topicId) async {
    final dbClient = await DatabaseService.db;
    final List<Map<String, dynamic>> maps = await dbClient.query(
      'revision_subtopics',
      where: 'topic_id = ?',
      whereArgs: [topicId],
    );
    return List.generate(maps.length, (i) => RevisionSubtopic.fromMap(maps[i]));
  }

  /// Updates checking/unchecking a checkbox status for any checklist subtopic
  Future<void> updateSubtopicCompletionStatus(int subtopicId, bool isCompleted) async {
    final dbClient = await DatabaseService.db;
    await dbClient.update(
      'revision_subtopics',
      {'is_completed': isCompleted ? 1 : 0},
      where: 'id = ?',
      whereArgs: [subtopicId],
    );
  }

  /// Aggregates database tracking numbers to return live layout stats
  Future<Map<String, int>> calculateExamProgressMetrics(int examId) async {
    final dbClient = await DatabaseService.db;
    final result = await dbClient.rawQuery('''
      SELECT 
        COUNT(s.id) as total,
        SUM(CASE WHEN s.is_completed = 1 THEN 1 ELSE 0 END) as completed
      FROM revision_topics t
      LEFT JOIN revision_subtopics s ON t.id = s.topic_id
      WHERE t.exam_id = ?
    ''', [examId]);

    if (result.isEmpty || result.first['total'] == 0) {
      return {'total': 0, 'completed': 0, 'pending': 0, 'percent': 0};
    }

    int total = (result.first['total'] ?? 0) as int;
    int completed = (result.first['completed'] ?? 0) as int;
    int pending = total - completed;
    int percent = total > 0 ? ((completed / total) * 100).round() : 0;

    return {
      'total': total,
      'completed': completed,
      'pending': pending,
      'percent': percent,
    };
  }

  /// Deletes an exam and its associated cascading data
  Future<int> deleteExam(int examId) async {
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

  /// Updates an existing exam entry in the database
  Future<int> updateExam(EventModel exam) async {
    final dbClient = await DatabaseService.db;
    return await dbClient.update(
      'exams',
      exam.toMap(),
      where: 'id = ?',
      whereArgs: [exam.id],
    );
  }

  /// Updates the completion status of an exam
  Future<void> updateExamCompletionStatus(int examId, bool isCompleted) async {
    final dbClient = await DatabaseService.db;
    await dbClient.update(
      'exams',
      {'is_completed': isCompleted ? 1 : 0},
      where: 'id = ?',
      whereArgs: [examId],
    );
  }
}
