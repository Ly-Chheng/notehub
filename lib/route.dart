import 'package:get/get.dart';
import 'package:project_structure/views/home/home_screen.dart';
import 'package:project_structure/views/home/test.dart';
import 'package:project_structure/widgets/splash_screen.dart';

final appRoute = [
  GetPage(name: '/', page: () => const SplashScreen()),
  GetPage(name: '/home', page: () => const MyHomePage()),
  GetPage(name: '/test', page: () => const TestScreen()),
];
