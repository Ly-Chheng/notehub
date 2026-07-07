import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:project_structure/main.dart';
import 'package:project_structure/views/home/home_screen.dart';
import 'package:timezone/timezone.dart' as tz;

class FirebaseServices {
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  static const String notificationChannelId = 'com.example.project_structure';
  // final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> getInstance() async {
    await initNotification();
    // await getFCMToken();
    await configureMessaging();
    await initializeFlutterLocalNotificationsPlugin();
  }

  Future<void> initNotification() async {
    await firebaseMessaging.requestPermission();
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  //! Get Token
  Future<String?> getFCMToken() async {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    debugPrint("------FCM Token:$fcmToken");
    // if (Platform.isIOS) {
    //   String? apnsToken = await firebaseMessaging.getAPNSToken();
    //   debugPrint('---APNS Token: $apnsToken');
    //   await Future.delayed(
    //     Duration(seconds: 2),
    //   );
    // }
    return fcmToken;
  }

  // ! LocalNotificationsPlugin
  Future<void> initializeFlutterLocalNotificationsPlugin() async {
    const initializationSettingsAndroid = AndroidInitializationSettings('@drawable/ic_launcher');
    var initializationSettingsIos = const DarwinInitializationSettings(
      defaultPresentAlert: true,
      defaultPresentSound: true,
    );
    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIos,
    );
    await FlutterLocalNotificationsPlugin().initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );
  }

  // ! Handle messages click when active app
  // void onDidReceiveNotificationResponse(
  //   NotificationResponse notificationResponse,
  // ) async {
  //   switch (notificationResponse.notificationResponseType) {
  //     case NotificationResponseType.selectedNotification:
  //       debugPrint("-----Active Click-----");
  //       if (notificationResponse.payload != null) {
  //         try {
  //           // navigatorKey.currentState?.push(
  //           //   MaterialPageRoute(
  //           //     builder: (context) => const MyHomePage(),
  //           //   ),
  //           // );
  //           FirebaseMessaging.onMessageOpenedApp.listen((message) {
  //             Get.offAllNamed('/mainHome', arguments: {
  //               'tab': 1,
  //               'focusTab': 1,
  //             });
  //           });
  //         } catch (error) {
  //           debugPrint('-----Notification payload error: $error');
  //         }
  //       }
  //       break;
  //     default:
  //   }
  // }
  // ! Handle messages click when active app
  void onDidReceiveNotificationResponse(
    NotificationResponse notificationResponse,
  ) async {
    switch (notificationResponse.notificationResponseType) {
      case NotificationResponseType.selectedNotification:
        debugPrint("-----Active Click-----");
        if (notificationResponse.payload != null) {
          try {
            FirebaseMessaging.onMessageOpenedApp.listen((message) {
              Get.offAllNamed('/mainHome', arguments: {
                'tab': 1,
                'focusTab': 1,
              });
            });
          } catch (error) {
            debugPrint('-----Notification payload error: $error');
          }
        }
        break;
      default:
    }
  }

  //! show messages when active app
  Future<void> configureMessaging() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      if (message.notification != null) {
        _showNotification(message);
      }
    });

    // Handle messages click when minimised app
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      final data = message.data;

      debugPrint('-----onMessageOpenedApp: $data');
      if (message.notification != null) {
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) => const MyHomePage(),
          ),
        );
      }
    });
  }

  void _showNotification(RemoteMessage message) {
    AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      notificationChannelId,
      'High Importance Notifications',
      importance: Importance.max,
      priority: Priority.high,
      channelShowBadge: true,
    );

    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: DarwinNotificationDetails(),
    );

    if (Platform.isAndroid) {
      final RemoteNotification? notification = message.notification;
      if (notification != null) {
        _notificationsPlugin.show(
          message.hashCode,
          notification.title,
          notification.body,
          platformChannelSpecifics,
          payload: message.data.isNotEmpty ? json.encode(message.data) : null,
        );
      }
    }
  }

  static Future<void> showTimerFinishedNotification({required String title, required String body}) async {
    final box = GetStorage();
    bool isEnabled = box.read('notifications_enabled') ?? true;

    if (!isEnabled) {
      return;
    }

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'timer_channel_id',
      'Timer Notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: false,
    );

    await _notificationsPlugin.show(
      0,
      title,
      body,
      const NotificationDetails(android: androidDetails),
    );
  }

  static Future<void> eventReminderNotification({
    required int id,
    required String title,
    required String body,
    required DateTime remiderDateTime,
  }) async {
    // 1. Define the Android channel specifics
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'event_planner_channel',
      'Event Reminders',
      channelDescription: 'Notifications for your scheduled events and revision topics',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    // 2. Define iOS specifics
    const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    // 3. Schedule the alarm at the exact user-selected date and time
    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(remiderDateTime, tz.local),
      platformDetails,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // Forces fire even under device battery optimization sleep modes
    );
  }

  static Future<void> cancelReminder(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  /// Fires an instant, real system notification using the exact same configuration profile as the event reminder channel.
  static Future<void> testReminderNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    final box = GetStorage();
    bool isEnabled = box.read('notifications_enabled') ?? true;
    if (!isEnabled) return;

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'event_reminder_channel_id',
      'Event Reminder Notifications',
      channelDescription: 'Channel specifically engineered for timing out upcoming local calendar events',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _notificationsPlugin.show(id, title, body, platformDetails);
  }
}
