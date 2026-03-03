import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:project_structure/core/services/firebase_services.dart';
import 'package:project_structure/core/services/themes_services.dart';
import 'package:project_structure/core/utils/app_language.dart';
import 'package:project_structure/core/functions/local_storage.dart';
import 'package:project_structure/firebase_options.dart';
import 'package:project_structure/route.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("-------------Handling a background message: ${message.data}");
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Set the background messaging handler early on, as a named top-level function
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseServices().getInstance();
  await LocalStorage.init();
  await GetStorage.init();
  await dotenv.load(fileName: "assets/.env");

  WidgetsFlutterBinding.ensureInitialized();

// 2. Initialize Hive properly
  await Hive.initFlutter();

  // 3. Open Boxes as Generic (No <Models>)
  // If you still get errors, you can use Hive.deleteBoxFromDisk('folders_box') 
  // once to force a reset, then remove that line.
  await Hive.openBox('student_notes');
  await Hive.openBox('folders_box');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    final storage = GetStorage();
    return GetMaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeService().lightTheme,
      darkTheme: ThemeService().darkTheme,
      themeMode: ThemeService().getThemeMode(),
      initialRoute: '/',
      getPages: appRoute,
      translations: AppTranslations(),
      fallbackLocale: AppTranslations().fallbackLocale,
      locale: storage.read('langCode') != null ? Locale(storage.read('langCode'), storage.read('countryCode')) : const Locale('km', 'KM'),
    );
  }
}
