import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:project_structure/controllers/more/font_size_controller.dart';
import 'package:project_structure/core/utils/app_bindings.dart';
import 'package:project_structure/core/database/database_service.dart';
import 'package:project_structure/core/services/firebase_services.dart';
import 'package:project_structure/core/services/themes_services.dart';
import 'package:project_structure/core/utils/app_language.dart';
import 'package:project_structure/core/functions/local_storage.dart';
import 'package:project_structure/widgets/firebase_options.dart';
import 'package:project_structure/models/focus_track/timer_model.dart';
import 'package:project_structure/route.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseServices().getInstance();
  await LocalStorage.init();
  await GetStorage.init();
  await dotenv.load(fileName: "assets/.env");

  /// SQLITE INIT (NOTES + FOLDERS)
  await DatabaseService.initDB();

  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  /// HIVE INIT (SETTINGS + TRASH + TIMER)
  Hive.registerAdapter(TimerModelAdapter());
  await Hive.deleteFromDisk();
  await Hive.openBox<TimerModel>('timer_box');
  await Hive.openBox('create_timer_box');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    final storage = GetStorage();
    return GetMaterialApp(
      defaultTransition: Platform.isAndroid ? Transition.cupertino : null,
      transitionDuration: Platform.isAndroid ? const Duration(milliseconds: 300) : null,
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeService().lightTheme,
      darkTheme: ThemeService().darkTheme,
      themeMode: ThemeService().getThemeMode(),
      initialRoute: '/',
      getPages: appRoute,
      initialBinding: InitialBinding(),
      translations: AppTranslations(),
      fallbackLocale: AppTranslations().fallbackLocale,
      locale: storage.read('langCode') != null ? Locale(storage.read('langCode'), storage.read('countryCode')) : const Locale('km', 'KM'),
      localizationsDelegates: const [
        FlutterQuillLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        final controller = Get.find<FontSizeController>();
        return Obx(() => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(controller.fontScale.value),
              ),
              child: child!,
            ));
      },
    );
  }
}
