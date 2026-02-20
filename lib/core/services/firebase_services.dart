import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:project_structure/main.dart';
import 'package:project_structure/views/home/test.dart';

class FirebaseServices {
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  static const String notificationChannelId = 'com.example.project_structure';
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> getInstance() async {
    await initNotification();
    // await getFCMToken();
    await configureMessaging();
    await initializeFlutterLocalNotificationsPlugin();
  }

  Future<void> initNotification() async {
    await firebaseMessaging.requestPermission();
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
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
    const initializationSettingsAndroid =
        AndroidInitializationSettings('@drawable/ic_launcher');
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
  void onDidReceiveNotificationResponse(
    NotificationResponse notificationResponse,
  ) async {
    switch (notificationResponse.notificationResponseType) {
      case NotificationResponseType.selectedNotification:
        debugPrint("-----Active Click-----");
        if (notificationResponse.payload != null) {
          try {
            navigatorKey.currentState?.push(
              MaterialPageRoute(
                builder: (context) => const TestScreen(),
              ),
            );
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
            builder: (context) => const TestScreen(),
          ),
        );
      }
    });
  }

  void _showNotification(RemoteMessage message) {
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
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
}
