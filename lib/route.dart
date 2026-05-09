import 'package:get/get.dart';
import 'package:project_structure/views/focus_track/components/create_timer_component.dart';
import 'package:project_structure/views/home/home_screen.dart';
import 'package:project_structure/views/lock/change_password_screen.dart';
import 'package:project_structure/views/lock/create_password_screen.dart';
import 'package:project_structure/views/lock/forget_password_screen.dart';
import 'package:project_structure/views/lock/remove_lock_screen.dart';
import 'package:project_structure/views/more/about_screen.dart';
import 'package:project_structure/views/more/how_to_use_screen.dart';
import 'package:project_structure/widgets/splash_screen.dart';

final appRoute = [
  GetPage(name: '/', page: () => const SplashScreen()),
  GetPage(name: '/home', page: () => const MyHomePage()),
  GetPage(name: '/createTimer', page: () => const CreateTimerScreen()),
  GetPage(name: '/about', page: () => const AboutScreen()),
  GetPage(name: '/howToUse', page: () => const HowToUseScreen()),
  GetPage(name: '/createPassword', page: () => const CreatePasswordScreen()),
  GetPage(name: '/changePassword', page: () => const ChangePasswordScreen()),
  GetPage(name: '/resetPassword', page: () => const RemoveLockScreen()),
  GetPage(name: '/fogetPassword', page: () => const ForgetPasswordScreen()),
];
