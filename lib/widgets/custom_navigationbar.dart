import 'package:flutter/material.dart';
import 'package:get/get.dart';

customNavigationBar({
  required BuildContext context,
  final List<BottomNavigationBarItem>? items,
  required final int currentIndex,
  final Color? selectedItemColor,
  final Color? unselectedItemColor,
  final void Function(int)? onTap,
}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(0),
    child: BottomNavigationBar(
      items: items ??
          <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/images/home.png',
                width: context.isPhone ? 24 : 30,
                height: context.isPhone ? 24 : 30,
              ),
              activeIcon: Image.asset(
                'assets/images/home_active.png',
                width: context.isPhone ? 24 : 30,
                height: context.isPhone ? 24 : 30,
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/images/timer.png',
                width: context.isPhone ? 26 : 32,
                height: context.isPhone ? 26 : 32,
              ),
              activeIcon: Image.asset(
                'assets/images/timer_active.png',
                width: context.isPhone ? 26 : 32,
                height: context.isPhone ? 26 : 32,
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/images/more.png',
                width: context.isPhone ? 24 : 30,
                height: context.isPhone ? 24 : 30,
              ),
              activeIcon: Image.asset(
                'assets/images/more_active.png',
                width: context.isPhone ? 24 : 30,
                height: context.isPhone ? 24 : 30,
              ),
              label: '',
            ),
          ],
      currentIndex: currentIndex,
      selectedItemColor: selectedItemColor ?? const Color.fromARGB(255, 108, 39, 176),
      onTap: onTap,
      unselectedItemColor: unselectedItemColor ?? Colors.grey.shade700,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      type: BottomNavigationBarType.fixed,
      elevation: 10,
      showUnselectedLabels: true,
      showSelectedLabels: false,
    ),
  );
}

// import 'package:flutter/material.dart';
// Widget customNavigationBar({
//   final List<BottomNavigationBarItem>? items,
//   required final int currentIndex,
//   final Color? selectedItemColor,
//   final Color? unselectedItemColor,
//   final void Function(int)? onTap,
// }) {
//   return SafeArea(
//     child: Container(
//       margin: const EdgeInsets.only(bottom: 12, left: 30, right: 30),
//       height: 64,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(30),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 15,
//             offset: const Offset(0, 8),
//           )
//         ],
//       ),
//       child: Theme(
//         data: ThemeData(
//           splashColor: Colors.transparent,
//           highlightColor: Colors.transparent,
//           canvasColor: Colors.transparent,
//         ),
//         child: BottomNavigationBar(
//           items: items ??
//               <BottomNavigationBarItem>[
//                 BottomNavigationBarItem(
//                   icon: Image.asset('assets/images/home.png', width: 24, height: 24),
//                   activeIcon: Image.asset('assets/images/home_active.png', width: 24, height: 24),
//                   label: '',
//                 ),
//                 BottomNavigationBarItem(
//                   icon: Image.asset('assets/images/timer.png', width: 24, height: 24),
//                   activeIcon: Image.asset('assets/images/timer_active.png', width: 24, height: 24),
//                   label: '',
//                 ),
//                 BottomNavigationBarItem(
//                   icon: Image.asset('assets/images/more.png', width: 24, height: 24),
//                   activeIcon: Image.asset('assets/images/more_active.png', width: 24, height: 24),
//                   label: '',
//                 ),
//               ],
//           currentIndex: currentIndex,
//           onTap: onTap,
//           backgroundColor: Colors.transparent,
//           elevation: 0,
//           type: BottomNavigationBarType.fixed,
//           showSelectedLabels: false,
//           showUnselectedLabels: false,
//           selectedItemColor:
//               selectedItemColor ?? const Color.fromARGB(255, 108, 39, 176),
//           unselectedItemColor:
//               unselectedItemColor ?? Colors.grey.shade600,
//         ),
//       ),
//     ),
//   );
// }
