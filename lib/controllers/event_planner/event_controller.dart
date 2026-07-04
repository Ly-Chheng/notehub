import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/core/database/database_service.dart';
import 'package:project_structure/models/event_planner/event_model.dart';
import 'package:project_structure/models/event_planner/revision_topic_model.dart';

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

  /// Add event
  Future<int> createEvent(EventModel exam) async {
    final dbClient = await DatabaseService.db;
    return await dbClient.insert('exams', exam.toMap());
  }

  /// Updates event
  Future<int> updateEvent(EventModel exam) async {
    final dbClient = await DatabaseService.db;
    return await dbClient.update(
      'exams',
      exam.toMap(),
      where: 'id = ?',
      whereArgs: [exam.id],
    );
  }

  /// Updates the completion status of an event
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
  Future<List<RevisionTopic>> fetchTopicsForEvent(int examId) async {
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

    return await dbClient.transaction((txn) async {
      await txn.rawDelete('''
        DELETE FROM revision_subtopics 
        WHERE topic_id IN (SELECT id FROM revision_topics WHERE exam_id = ?)
      ''', [examId]);

      // Delete main topic modules
      await txn.delete(
        'revision_topics',
        where: 'exam_id = ?',
        whereArgs: [examId],
      );

      // Finally, delete the root exam record
      return await txn.delete(
        'exams',
        where: 'id = ?',
        whereArgs: [examId],
      );
    });
  }

  // Calculates the offset between the event date and the reminder date in days, returning a user-friendly string.
  String reminderConvertFromDateTime({
    required String eventDateStr,
    required String? reminderDateStr,
    required String fallbackReminderTime,
  }) {
    if (fallbackReminderTime.isEmpty || reminderDateStr == null) {
      return "none".tr;
    }

    try {
      // Clean and parse strings safely
      final parsedEvent = DateTime.parse(eventDateStr.trim());
      final parsedReminder = DateTime.parse(reminderDateStr.trim());

      // This strips any hidden timestamp or time zone offsets causing math errors
      final cleanEventDate = DateTime.utc(parsedEvent.year, parsedEvent.month, parsedEvent.day);
      final cleanReminderDate = DateTime.utc(parsedReminder.year, parsedReminder.month, parsedReminder.day);

      //Calculate the true calendar day difference
      final differenceInDays = cleanEventDate.difference(cleanReminderDate).inDays;

      if (differenceInDays == 0) {
        return "same_day".tr;
      } else if (differenceInDays > 0) {
        return "$differenceInDays ${'days_before'.tr}";
      }
    } catch (e) {
      debugPrint("Error parsing dates in reminderConvertFromDateTime: $e");
    }

    return fallbackReminderTime;
  }
}
