import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationController extends GetxController {
  final _storage = GetStorage();
  final RxBool isNotificationEnabled = true.obs;

  @override
  void onInit() {
    super.onInit();
    isNotificationEnabled.value = _storage.read('notifications_enabled') ?? true;
  }

  Future<void> toggleNotifications(bool value) async {
    isNotificationEnabled.value = value;
    await _storage.write('notifications_enabled', value);

    if (!value) {
      await FlutterLocalNotificationsPlugin().cancelAll();
    }
  }
}
