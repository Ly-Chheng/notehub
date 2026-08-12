
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/core/database/database_service.dart';
import 'package:project_structure/core/services/firebase_services.dart';
 
import 'package:project_structure/models/event_planner/event_model.dart';
import 'package:project_structure/models/event_planner/revision_topic_model.dart';

class EventPlannerController extends GetxController {
  EventPlannerController();

  // ---------------------------------------------------------------------------
  // Reactive State
  // ---------------------------------------------------------------------------
  final RxList<EventModel> upcomingEvents = <EventModel>[].obs;
  final RxList<EventModel> completedEvents = <EventModel>[].obs;
  final RxBool isLoading = false.obs;

  final List<Map<String, dynamic>> availableIcons = const [
    {'name': 'study', 'image': 'assets/images/study.png'},
    {'name': 'work', 'image': 'assets/images/work.png'},
    {'name': 'todo', 'image': 'assets/images/todo.png'},
    {'name': 'meeting', 'image': 'assets/images/meeting.png'},
  ];

  @override
  void onInit() {
    super.onInit();
    // Automatically load data when controller initializes
    loadAllEvents();
  }

  // ---------------------------------------------------------------------------
  // Core Data Fetching & Sync
  // ---------------------------------------------------------------------------

  /// Fetches both upcoming and completed events from SQLite and updates state
  Future<void> loadAllEvents() async {
    isLoading.value = true;
    try {
      final upcoming = await fetchEvent(completed: false);
      final completed = await fetchEvent(completed: true);

      upcomingEvents.assignAll(upcoming);
      completedEvents.assignAll(completed);
    } catch (e) {
      debugPrint("Error loading events: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Raw database fetch helper
  Future<List<EventModel>> fetchEvent({required bool completed}) async {
    try {
      final dbClient = await DatabaseService.db;
      final List<Map<String, dynamic>> maps = await dbClient.query(
        'events',
        where: 'is_completed = ?',
        whereArgs: [completed ? 1 : 0],
        orderBy: 'date ASC',
      );
      return List.generate(maps.length, (i) => EventModel.fromMap(maps[i]));
    } catch (e) {
      debugPrint("Error querying events table: $e");
      return [];
    }
  }

  // ---------------------------------------------------------------------------
  // Event CRUD Operations (Auto-refreshes state)
  // ---------------------------------------------------------------------------

  /// Creates a new event, sets up notifications, and updates the reactive lists
  Future<int> createEvent(EventModel event) async {
    final dbClient = await DatabaseService.db;
    final int insertedId = await dbClient.insert('events', event.toMap());

    final reminderTime = _parseReminderDateTime(event);
    if (reminderTime != null && !event.isCompleted) {
      await FirebaseServices.eventReminderNotification(
        id: insertedId,
        title: event.title,
        body: "Reminder: Your event is scheduled for ${event.date} at ${event.time}",
        remiderDateTime: reminderTime,
      );
    }

    // Refresh observable state so UI updates instantly
    await loadAllEvents();

    return insertedId;
  }

  /// Updates event details, reschedules system alarms, and refreshes UI state
  Future<int> updateEvent(EventModel event) async {
    final dbClient = await DatabaseService.db;
    final int result = await dbClient.update(
      'events',
      event.toMap(),
      where: 'id = ?',
      whereArgs: [event.id],
    );

    if (event.id != null) {
      await FirebaseServices.cancelReminder(event.id!);

      final reminderTime = _parseReminderDateTime(event);
      if (reminderTime != null && !event.isCompleted) {
        await FirebaseServices.eventReminderNotification(
          id: event.id!,
          title: event.title,
          body: "Reminder: Your event is scheduled for ${event.date} at ${event.time}",
          remiderDateTime: reminderTime,
        );
      }
    }

    await loadAllEvents();
    return result;
  }

  /// Toggles event completion status and triggers state refresh
  Future<void> updateEventCompletionStatus(int eventId, bool isCompleted) async {
    final dbClient = await DatabaseService.db;
    await dbClient.update(
      'events',
      {'is_completed': isCompleted ? 1 : 0},
      where: 'id = ?',
      whereArgs: [eventId],
    );

    if (isCompleted) {
      await FirebaseServices.cancelReminder(eventId);
    }

    await loadAllEvents();
  }

  /// Deletes event and associated topics/subtopics in a transaction
  Future<int> deleteEvent(int eventId) async {
    final dbClient = await DatabaseService.db;

    await FirebaseServices.cancelReminder(eventId);

    final result = await dbClient.transaction((txn) async {
      await txn.rawDelete('''
        DELETE FROM revision_subtopics 
        WHERE topic_id IN (SELECT id FROM revision_topics WHERE event_id = ?)
      ''', [eventId]);

      await txn.delete(
        'revision_topics',
        where: 'event_id = ?',
        whereArgs: [eventId],
      );

      return await txn.delete(
        'events',
        where: 'id = ?',
        whereArgs: [eventId],
      );
    });

    await loadAllEvents();
    return result;
  }

  // ---------------------------------------------------------------------------
  // Topic Methods
  // ---------------------------------------------------------------------------

  Future<List<RevisionTopic>> fetchTopicsForEvent(int eventId) async {
    final dbClient = await DatabaseService.db;
    final List<Map<String, dynamic>> maps = await dbClient.query(
      'revision_topics',
      where: 'event_id = ?',
      whereArgs: [eventId],
    );
    return List.generate(maps.length, (i) => RevisionTopic.fromMap(maps[i]));
  }

  Future<int> createTopic(RevisionTopic topic) async {
    final dbClient = await DatabaseService.db;
    return await dbClient.insert('revision_topics', topic.toMap());
  }

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

  // ---------------------------------------------------------------------------
  // Helper Utilities
  // ---------------------------------------------------------------------------

  DateTime? _parseReminderDateTime(EventModel event) {
    if (event.reminderDate == null || event.reminderTimer == null) return null;
    try {
      final datePart = event.reminderDate!.trim();
      final timePart = event.reminderTimer!.trim();
      return DateTime.parse("$datePart $timePart");
    } catch (e) {
      debugPrint("Failed parsing reminder timestamp: $e");
      return null;
    }
  }

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
}
