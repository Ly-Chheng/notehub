import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/core/database/database_service.dart';
import 'package:project_structure/core/services/firebase_services.dart';
import 'package:project_structure/models/event_planner/event_model.dart';
import 'package:project_structure/models/event_planner/revision_topic_model.dart';

class EventPlannerController extends GetxController {
  EventPlannerController();
  final List<Map<String, dynamic>> availableIcons = [
    {'name': 'study', 'image': 'assets/images/study.png'},
    {'name': 'work', 'image': 'assets/images/work.png'},
    {'name': 'todo', 'image': 'assets/images/todo.png'},
    {'name': 'meeting', 'image': 'assets/images/meeting.png'},
  ];

  DateTime? _parseReminderDateTime(EventModel exam) {
    if (exam.reminderDate == null || exam.reminderTimer == null) return null;
    try {
      final datePart = exam.reminderDate!.trim();
      final timePart = exam.reminderTimer!.trim();

      // Directly stitches clean "YYYY-MM-DD" and "HH:mm:ss" strings safely
      return DateTime.parse("$datePart $timePart");
    } catch (e) {
      debugPrint("Failed parsing reminder timestamp: $e");
      return null;
    }
  }

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

  /// Add
  Future<int> createEvent(EventModel exam) async {
    final dbClient = await DatabaseService.db;
    final int insertedId = await dbClient.insert('exams', exam.toMap());

    final reminderTime = _parseReminderDateTime(exam);
    if (reminderTime != null && !exam.isCompleted) {
      await FirebaseServices.eventReminderNotification(
        id: insertedId,
        title: exam.title,
        body: "Reminder: Your event is scheduled for ${exam.date} at ${exam.time}",
        remiderDateTime: reminderTime,
      );
    }
    return insertedId;
  }

  /// Updates event + Syncs System Alarms
  Future<int> updateEvent(EventModel exam) async {
    final dbClient = await DatabaseService.db;
    final int result = await dbClient.update(
      'exams',
      exam.toMap(),
      where: 'id = ?',
      whereArgs: [exam.id],
    );

    if (exam.id != null) {
      await FirebaseServices.cancelReminder(exam.id!);

      final reminderTime = _parseReminderDateTime(exam);
      if (reminderTime != null && !exam.isCompleted) {
        await FirebaseServices.eventReminderNotification(
          id: exam.id!,
          title: exam.title,
          body: "Reminder: Your event is scheduled for ${exam.date} at ${exam.time}",
          remiderDateTime: reminderTime,
        );
      }
    }
    return result;
  }

  /// Update
  Future<void> updateEventCompletionStatus(int examId, bool isCompleted) async {
    final dbClient = await DatabaseService.db;
    await dbClient.update(
      'exams',
      {'is_completed': isCompleted ? 1 : 0},
      where: 'id = ?',
      whereArgs: [examId],
    );

    // If marked complete, we must drop any pending notification alarms
    if (isCompleted) {
      await FirebaseServices.cancelReminder(examId);
    }
  }

  /// Deletes
  Future<int> deleteEvent(int examId) async {
    final dbClient = await DatabaseService.db;

    // Cancel the notification alarm first
    await FirebaseServices.cancelReminder(examId);

    return await dbClient.transaction((txn) async {
      await txn.rawDelete('''
        DELETE FROM revision_subtopics 
        WHERE topic_id IN (SELECT id FROM revision_topics WHERE exam_id = ?)
      ''', [examId]);

      await txn.delete(
        'revision_topics',
        where: 'exam_id = ?',
        whereArgs: [examId],
      );

      return await txn.delete(
        'exams',
        where: 'id = ?',
        whereArgs: [examId],
      );
    });
  }

  // Converts event/reminder date difference into a localized string.
  String reminderConvertFromDateTime({
    required String eventDateStr,
    required String? reminderDateStr,
    required String fallbackReminderTime,
  }) {
    if (fallbackReminderTime.isEmpty || reminderDateStr == null) {
      return "none".tr;
    }

    try {
      final parsedEvent = DateTime.parse(eventDateStr.trim());
      final parsedReminder = DateTime.parse(reminderDateStr.trim());

      final cleanEventDate = DateTime.utc(parsedEvent.year, parsedEvent.month, parsedEvent.day);
      final cleanReminderDate = DateTime.utc(parsedReminder.year, parsedReminder.month, parsedReminder.day);

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

  /// get topic
  Future<List<RevisionTopic>> fetchTopicsForEvent(int examId) async {
    final dbClient = await DatabaseService.db;
    final List<Map<String, dynamic>> maps = await dbClient.query(
      'revision_topics',
      where: 'exam_id = ?',
      whereArgs: [examId],
    );
    return List.generate(maps.length, (i) => RevisionTopic.fromMap(maps[i]));
  }

  /// Add topic
  Future<int> createTopic(RevisionTopic topic) async {
    final dbClient = await DatabaseService.db;
    return await dbClient.insert('revision_topics', topic.toMap());
  }

  /// Deletes topic
  Future<void> deleteTopic(int topicId) async {
    final dbClient = await DatabaseService.db;
    await dbClient.delete(
      'revision_topics',
      where: 'id = ?',
      whereArgs: [topicId],
    );
  }

  Future<void> updateTopicName(int topicId, String newName) async {
    final dbClient = await DatabaseService.db;
    await dbClient.update(
      'revision_topics',
      {'name': newName},
      where: 'id = ?',
      whereArgs: [topicId],
    );
  }

  Future<void> updateTopicCompletionStatus(int topicId, bool isCompleted) async {
    final dbClient = await DatabaseService.db;
    await dbClient.update(
      'revision_topics',
      {'is_completed': isCompleted ? 1 : 0},
      where: 'id = ?',
      whereArgs: [topicId],
    );
  }
}
