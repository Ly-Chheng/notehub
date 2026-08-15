// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import 'package:project_structure/controllers/event_planner/event_controller.dart';
// import 'package:project_structure/core/utils/app_color.dart';
// import 'package:project_structure/core/utils/app_fonts.dart';
// import 'package:project_structure/models/event_planner/event_model.dart';
// import 'package:project_structure/views/event_planner/add_event_screen.dart';
// import 'package:project_structure/views/event_planner/event_details_screen.dart';
// import 'package:project_structure/widgets/custom_menu_item.dart.dart';
// import 'package:project_structure/widgets/app_snack_bar.dart';
// import 'package:project_structure/widgets/custome_no_data.dart';
// import 'package:project_structure/widgets/dialog_and_buttonsheet/confirm_bottomsheet.dart';
// import 'package:project_structure/widgets/dialog_and_buttonsheet/custom_dialog.dart';

// class UpcomingEventList extends StatefulWidget {
//   const UpcomingEventList({super.key});

//   @override
//   State<UpcomingEventList> createState() => _UpcomingEventListState();
// }

// class _UpcomingEventListState extends State<UpcomingEventList> {
//   final EventPlannerController _controller = Get.find<EventPlannerController>();
//   Timer? _tickerTimer;

//   @override
//   void initState() {
//     super.initState();
//     _tickerTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (mounted) setState(() {});
//     });
//   }

//   @override
//   void dispose() {
//     _tickerTimer?.cancel();
//     super.dispose();
//   }

//   DateTime? _getEventDateTime(EventModel exam) {
//     try {
//       String combinedString = "${exam.date.trim()} ${exam.time.trim()}";
//       return exam.time.toUpperCase().contains('AM') || exam.time.toUpperCase().contains('PM')
//           ? DateFormat("yyyy-MM-dd h:mm a").parse(combinedString)
//           : DateTime.parse("${exam.date.trim()} ${exam.time.split(':')[0].padLeft(2, '0')}:${exam.time.split(':')[1].padLeft(2, '0')}:00");
//     } catch (_) {
//       return null;
//     }
//   }

//   Duration _calculateTimeRemaining(EventModel event) {
//     final eventDateTime = _getEventDateTime(event);
//     if (eventDateTime == null) return const Duration();
//     final difference = eventDateTime.difference(DateTime.now());
//     return difference.isNegative ? const Duration() : difference;
//   }

//   double _calculateProgress(EventModel event) {
//     final targetTime = _getEventDateTime(event);
//     if (targetTime == null) return 0.0;

//     // Use a fallback creation time if your model doesn't store it (e.g., 7 days prior)
//     // If your EventModel has a `createdAt` field, replace `subtract` line with: exam.createdAt
//     final startTime = targetTime.subtract(const Duration(days: 7));
//     final totalDuration = targetTime.difference(startTime).inSeconds;
//     final elapsedDuration = DateTime.now().difference(startTime).inSeconds;

//     if (totalDuration <= 0) return 1.0;

//     double progress = elapsedDuration / totalDuration;
//     return progress.clamp(0.0, 1.0);
//   }

//   String _getImageAsset(String? iconName) {
//     final cleanName = iconName?.toLowerCase().trim();
//     switch (cleanName) {
//       case 'study':
//       case 'work':
//       case 'todo':
//       case 'meeting':
//         return 'assets/images/$cleanName.png';
//       default:
//         return 'assets/images/study.png';
//     }
//   }

//   void _showActionBottomSheet(BuildContext context, EventModel event) {
//     ConfirmBottomSheet.show(
//       context: context,
//       isFloating: true,
//       title: "event".tr,
//       content: SafeArea(
//         child: Wrap(
//           children: [
//             buildActionItem(
//               context,
//               icon: Icons.check,
//               color: AppColor().primaryColor,
//               title: "completed".tr,
//               onTap: () {
//                 Navigator.pop(context);
//                 if (event.id != null) {
//                   showConfirmDialog(
//                     context: context,
//                     title: "make_completed".tr,
//                     subTitle: "are_you_sure_make_completed".tr,
//                     confirmText: "completed".tr,
//                     onConfirm: () async {
//                       await _controller.updateEventCompletionStatus(event.id!, true);
//                     },
//                   );
//                 } else {
//                   AppSnackbar.showError(title: "error".tr, message: "cannot_make_completed".tr);
//                 }
//               },
//             ),
//             buildActionItem(
//               context,
//               icon: Icons.edit_outlined,
//               color: AppColor().primaryColor,
//               title: "edit".tr,
//               onTap: () async {
//                 Navigator.pop(context);
//                 Get.to(() => AddEventScreen(event: event));
//               },
//             ),
//             buildActionItem(
//               context,
//               icon: Icons.delete_outline,
//               color: AppColor().red,
//               title: "delete".tr,
//               onTap: () {
//                 Navigator.pop(context);
//                 if (event.id != null) {
//                   showConfirmDialog(
//                     context: context,
//                     title: "delete".tr,
//                     subTitle: "delete_confirm".tr,
//                     confirmText: "delete".tr,
//                     onConfirm: () async {
//                       await _controller.deleteEvent(event.id!);
//                     },
//                   );
//                 } else {
//                   AppSnackbar.showError(title: "error".tr, message: "cannot_delete_event".tr);
//                 }
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Obx(() {
//       if (_controller.isLoading.value) {
//         return const Center(child: CircularProgressIndicator());
//       }

//       final events = _controller.upcomingEvents;
//       if (events.isEmpty) {
//         return Center(
//           child: CustomNoData(
//             message: "no_data".tr,
//           ),
//         );
//       }

//       return RefreshIndicator(
//         onRefresh: _controller.loadAllEvents,
//         child: ListView.builder(
//           padding: const EdgeInsets.all(16),
//           itemCount: events.length,
//           itemBuilder: (context, index) {
//             final event = events[index];
//             final Color baseColor = event.color != null ? Color(event.color!) : AppColor().primaryColor;

//             final duration = _calculateTimeRemaining(event);
//             final days = duration.inDays.toString().padLeft(2, '0');
//             final hours = (duration.inHours % 24).toString().padLeft(2, '0');
//             final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
//             final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');

//             final double progressPercentage = _calculateProgress(event);

//             return Container(
//               margin: const EdgeInsets.only(bottom: 15),
//               decoration: BoxDecoration(
//                 color: baseColor.withValues(alpha: 0.05),
//                 borderRadius: BorderRadius.circular(18),
//               ),
//               child: InkWell(
//                 borderRadius: BorderRadius.circular(18),
//                 onTap: () => Get.to(() => EventDetailsScreen(event: event)),
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//                   child: Column(
//                     children: [
//                       Row(
//                         children: [
//                           Container(
//                             padding: const EdgeInsets.all(8),
//                             decoration: BoxDecoration(
//                               color: baseColor.withValues(alpha: 0.2),
//                               borderRadius: BorderRadius.circular(12),
//                               border: Border.all(width: 1, color: baseColor.withValues(alpha: 0.4)),
//                             ),
//                             child: Image.asset(
//                               _getImageAsset(event.icon),
//                               width: 40,
//                               height: 40,
//                               fit: BoxFit.contain,
//                             ),
//                           ),
//                           const SizedBox(width: 16),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Expanded(
//                                       child: Text(
//                                         event.title,
//                                         style: fix18(context),
//                                         maxLines: 1,
//                                         overflow: TextOverflow.ellipsis,
//                                       ),
//                                     ),
//                                     IconButton(
//                                       icon: Icon(Icons.more_horiz_outlined, color: AppColor().gray),
//                                       onPressed: () => _showActionBottomSheet(context, event),
//                                     ),
//                                   ],
//                                 ),
//                                 Text("${event.date} | ${event.time}", style: fix16(context).copyWith(color: AppColor().gray)),
//                                 const SizedBox(height: 10)
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 10),
//                       Row(
//                         children: [
//                           Expanded(child: _countdownCard(days, "d".tr)),
//                           const SizedBox(width: 20),
//                           Expanded(child: _countdownCard(hours, "h".tr)),
//                           const SizedBox(width: 20),
//                           Expanded(child: _countdownCard(minutes, "m".tr)),
//                           const SizedBox(width: 20),
//                           Expanded(child: _countdownCard(seconds, "s".tr)),
//                         ],
//                       ),
//                       // Overall Progress Bar Section
//                       const SizedBox(height: 20),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text("overall_progress".tr,
//                               style: text14(context).copyWith(
//                                 color: AppColor().gray,
//                               )),
//                           Text(
//                             "${(progressPercentage * 100).toStringAsFixed(0)}%",
//                             style: fix16(context).copyWith(color: baseColor, fontWeight: FontWeight.bold),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 6),
//                       ClipRRect(
//                         borderRadius: BorderRadius.circular(8),
//                         child: LinearProgressIndicator(
//                           value: progressPercentage,
//                           minHeight: 10,
//                           backgroundColor: baseColor.withValues(alpha: 0.1),
//                           valueColor: AlwaysStoppedAnimation<Color>(baseColor),
//                         ),
//                       ),
//                       const SizedBox(height: 10),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       );
//     });
//   }

//   Widget _countdownCard(String value, String label) {
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Column(
//         children: [
//           Text(
//             value,
//             style: fix18(context).copyWith(
//               fontSize: 26,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           Text(label, style: text16(context).copyWith(color: AppColor().gray)),
//         ],
//       ),
//     );
//   }
// }

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import 'package:project_structure/controllers/event_planner/event_controller.dart';
// import 'package:project_structure/core/utils/app_color.dart';
// import 'package:project_structure/core/utils/app_fonts.dart';
// import 'package:project_structure/models/event_planner/event_model.dart';
// import 'package:project_structure/views/event_planner/add_event_screen.dart';
// import 'package:project_structure/views/event_planner/event_details_screen.dart';
// import 'package:project_structure/widgets/custom_menu_item.dart.dart';
// import 'package:project_structure/widgets/app_snack_bar.dart';
// import 'package:project_structure/widgets/custome_no_data.dart';
// import 'package:project_structure/widgets/dialog_and_buttonsheet/confirm_bottomsheet.dart';
// import 'package:project_structure/widgets/dialog_and_buttonsheet/custom_dialog.dart';

// class UpcomingEventList extends StatefulWidget {
//   const UpcomingEventList({super.key});

//   @override
//   State<UpcomingEventList> createState() => _UpcomingEventListState();
// }

// class _UpcomingEventListState extends State<UpcomingEventList> {
//   final EventPlannerController _controller = Get.find<EventPlannerController>();
//   Timer? _tickerTimer;

//   @override
//   void initState() {
//     super.initState();
//     // ធ្វើបច្ចុប្បន្នភាព UI រៀងរាល់ ១ វិនាទីដើម្បីរាប់ថយក្រោយ
//     _tickerTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (mounted) setState(() {});
//     });
//   }

//   @override
//   void dispose() {
//     _tickerTimer?.cancel();
//     super.dispose();
//   }

//   /// មុខងារ Parse ថ្ងៃ និងម៉ោងរបស់ Event ឲ្យបានត្រឹមត្រូវ
//   DateTime? _getEventDateTime(EventModel exam) {
//     try {
//       final dateStr = exam.date.trim();
//       final timeStr = exam.time.trim();
//       final combinedString = "$dateStr $timeStr";

//       // ប្រសិនបើ timeStr មាន AM/PM
//       if (timeStr.toUpperCase().contains('AM') || timeStr.toUpperCase().contains('PM')) {
//         return DateFormat("yyyy-MM-dd h:mm a").parse(combinedString);
//       }

//       // ប្រសិនបើ timeStr ជា 24-hour format (HH:mm:ss)
//       final parts = timeStr.split(':');
//       final hour = int.parse(parts[0]).toString().padLeft(2, '0');
//       final minute = int.parse(parts[1]).toString().padLeft(2, '0');
//       return DateTime.parse("$dateStr $hour:$minute:00");
//     } catch (_) {
//       return null;
//     }
//   }

//   /// គណនារយៈពេលដែលនៅសល់ (Countdown)
//   Duration _calculateTimeRemaining(EventModel event) {
//     final eventDateTime = _getEventDateTime(event);
//     if (eventDateTime == null) return const Duration();

//     final now = DateTime.now();
//     final difference = eventDateTime.difference(now);

//     // ប្រសិនបើម៉ោងទើបតែឆ្លងផុត វានឹងបង្ហាញ 00:00:00:00
//     if (difference.isNegative) {
//       return const Duration();
//     }
//     return difference;
//   }

//   /// គណនា Progress Bar ភាគរយ (%)
//   double _calculateProgress(EventModel event) {
//     final targetTime = _getEventDateTime(event);
//     if (targetTime == null) return 0.0;

//     final now = DateTime.now();

//     // ប្រើថ្ងៃចាប់ផ្តើមជាដើមថ្ងៃនៃ Event Date (ឬថ្ងៃបង្កើត Event)
//     final startTime = DateTime(targetTime.year, targetTime.month, targetTime.day, 0, 0, 0);

//     final totalDuration = targetTime.difference(startTime).inSeconds;
//     final elapsedDuration = now.difference(startTime).inSeconds;

//     if (totalDuration <= 0) {
//       return now.isAfter(targetTime) ? 1.0 : 0.0;
//     }

//     double progress = elapsedDuration / totalDuration;
//     return progress.clamp(0.0, 1.0);
//   }

//   String _getImageAsset(String? iconName) {
//     final cleanName = iconName?.toLowerCase().trim();
//     switch (cleanName) {
//       case 'study':
//       case 'work':
//       case 'todo':
//       case 'meeting':
//         return 'assets/images/$cleanName.png';
//       default:
//         return 'assets/images/study.png';
//     }
//   }

//   void _showActionBottomSheet(BuildContext context, EventModel event) {
//     ConfirmBottomSheet.show(
//       context: context,
//       isFloating: true,
//       title: "event".tr,
//       content: SafeArea(
//         child: Wrap(
//           children: [
//             buildActionItem(
//               context,
//               icon: Icons.check,
//               color: AppColor().primaryColor,
//               title: "completed".tr,
//               onTap: () {
//                 Navigator.pop(context);
//                 if (event.id != null) {
//                   showConfirmDialog(
//                     context: context,
//                     title: "make_completed".tr,
//                     subTitle: "are_you_sure_make_completed".tr,
//                     confirmText: "completed".tr,
//                     onConfirm: () async {
//                       await _controller.updateEventCompletionStatus(event.id!, true);
//                     },
//                   );
//                 } else {
//                   AppSnackbar.showError(title: "error".tr, message: "cannot_make_completed".tr);
//                 }
//               },
//             ),
//             buildActionItem(
//               context,
//               icon: Icons.edit_outlined,
//               color: AppColor().primaryColor,
//               title: "edit".tr,
//               onTap: () async {
//                 Navigator.pop(context);
//                 Get.to(() => AddEventScreen(event: event));
//               },
//             ),
//             buildActionItem(
//               context,
//               icon: Icons.delete_outline,
//               color: AppColor().red,
//               title: "delete".tr,
//               onTap: () {
//                 Navigator.pop(context);
//                 if (event.id != null) {
//                   showConfirmDialog(
//                     context: context,
//                     title: "delete".tr,
//                     subTitle: "delete_confirm".tr,
//                     confirmText: "delete".tr,
//                     onConfirm: () async {
//                       await _controller.deleteEvent(event.id!);
//                     },
//                   );
//                 } else {
//                   AppSnackbar.showError(title: "error".tr, message: "cannot_delete_event".tr);
//                 }
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Obx(() {
//       if (_controller.isLoading.value) {
//         return const Center(child: CircularProgressIndicator());
//       }

//       final events = _controller.upcomingEvents;
//       if (events.isEmpty) {
//         return Center(
//           child: CustomNoData(
//             message: "no_data".tr,
//           ),
//         );
//       }

//       return RefreshIndicator(
//         onRefresh: _controller.loadAllEvents,
//         child: ListView.builder(
//           padding: const EdgeInsets.all(16),
//           itemCount: events.length,
//           itemBuilder: (context, index) {
//             final event = events[index];
//             final Color baseColor = event.color != null ? Color(event.color!) : AppColor().primaryColor;

//             final duration = _calculateTimeRemaining(event);
//             final days = duration.inDays.toString().padLeft(2, '0');
//             final hours = (duration.inHours % 24).toString().padLeft(2, '0');
//             final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
//             final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');

//             final double progressPercentage = _calculateProgress(event);

//             return Container(
//               margin: const EdgeInsets.only(bottom: 15),
//               decoration: BoxDecoration(
//                 color: baseColor.withValues(alpha: 0.05),
//                 borderRadius: BorderRadius.circular(18),
//               ),
//               child: InkWell(
//                 borderRadius: BorderRadius.circular(18),
//                 onTap: () => Get.to(() => EventDetailsScreen(event: event)),
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//                   child: Column(
//                     children: [
//                       Row(
//                         children: [
//                           Container(
//                             padding: const EdgeInsets.all(8),
//                             decoration: BoxDecoration(
//                               color: baseColor.withValues(alpha: 0.2),
//                               borderRadius: BorderRadius.circular(12),
//                               border: Border.all(width: 1, color: baseColor.withValues(alpha: 0.4)),
//                             ),
//                             child: Image.asset(
//                               _getImageAsset(event.icon),
//                               width: 40,
//                               height: 40,
//                               fit: BoxFit.contain,
//                             ),
//                           ),
//                           const SizedBox(width: 16),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Expanded(
//                                       child: Text(
//                                         event.title,
//                                         style: fix18(context),
//                                         maxLines: 1,
//                                         overflow: TextOverflow.ellipsis,
//                                       ),
//                                     ),
//                                     IconButton(
//                                       icon: Icon(Icons.more_horiz_outlined, color: AppColor().gray),
//                                       onPressed: () => _showActionBottomSheet(context, event),
//                                     ),
//                                   ],
//                                 ),
//                                 Text("${event.date} | ${event.time}", style: fix16(context).copyWith(color: AppColor().gray)),
//                                 const SizedBox(height: 10)
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 10),
//                       Row(
//                         children: [
//                           Expanded(child: _countdownCard(days, "d".tr)),
//                           const SizedBox(width: 20),
//                           Expanded(child: _countdownCard(hours, "h".tr)),
//                           const SizedBox(width: 20),
//                           Expanded(child: _countdownCard(minutes, "m".tr)),
//                           const SizedBox(width: 20),
//                           Expanded(child: _countdownCard(seconds, "s".tr)),
//                         ],
//                       ),
//                       // Overall Progress Bar Section
//                       const SizedBox(height: 20),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text("overall_progress".tr,
//                               style: text14(context).copyWith(
//                                 color: AppColor().gray,
//                               )),
//                           Text(
//                             "${(progressPercentage * 100).toStringAsFixed(0)}%",
//                             style: fix16(context).copyWith(color: baseColor, fontWeight: FontWeight.bold),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 6),
//                       ClipRRect(
//                         borderRadius: BorderRadius.circular(8),
//                         child: LinearProgressIndicator(
//                           value: progressPercentage,
//                           minHeight: 10,
//                           backgroundColor: baseColor.withValues(alpha: 0.1),
//                           valueColor: AlwaysStoppedAnimation<Color>(baseColor),
//                         ),
//                       ),
//                       const SizedBox(height: 10),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       );
//     });
//   }

//   Widget _countdownCard(String value, String label) {
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Column(
//         children: [
//           Text(
//             value,
//             style: fix18(context).copyWith(
//               fontSize: 26,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           Text(label, style: text16(context).copyWith(color: AppColor().gray)),
//         ],
//       ),
//     );
//   }
// }

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:project_structure/controllers/event_planner/event_controller.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/core/utils/app_fonts.dart';
import 'package:project_structure/models/event_planner/event_model.dart';
import 'package:project_structure/views/event_planner/add_event_screen.dart';
import 'package:project_structure/views/event_planner/event_details_screen.dart';
import 'package:project_structure/widgets/custom_menu_item.dart.dart';
import 'package:project_structure/widgets/app_snack_bar.dart';
import 'package:project_structure/widgets/custome_no_data.dart';
import 'package:project_structure/widgets/dialog_and_buttonsheet/confirm_bottomsheet.dart';
import 'package:project_structure/widgets/dialog_and_buttonsheet/custom_dialog.dart';

class UpcomingEventList extends StatefulWidget {
  const UpcomingEventList({super.key});

  @override
  State<UpcomingEventList> createState() => _UpcomingEventListState();
}

class _UpcomingEventListState extends State<UpcomingEventList> {
  final EventPlannerController _controller = Get.find<EventPlannerController>();
  Timer? _tickerTimer;

  @override
  void initState() {
    super.initState();
    _tickerTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tickerTimer?.cancel();
    super.dispose();
  }

  /// Parse ថ្ងៃ និងម៉ោងរបស់ Event ឱ្យបានច្បាស់លាស់
  DateTime? _getEventDateTime(EventModel exam) {
    try {
      final dateStr = exam.date.trim();
      final timeStr = exam.time.trim();
      final combinedString = "$dateStr $timeStr";

      if (timeStr.toUpperCase().contains('AM') || timeStr.toUpperCase().contains('PM')) {
        return DateFormat("yyyy-MM-dd h:mm a").parse(combinedString);
      }

      final parts = timeStr.split(':');
      final hour = int.parse(parts[0]).toString().padLeft(2, '0');
      final minute = int.parse(parts[1]).toString().padLeft(2, '0');
      return DateTime.parse("$dateStr $hour:$minute:00");
    } catch (_) {
      return null;
    }
  }

  /// គណនារយៈពេលនៅសល់ (ឬរយៈពេលដែលបានកន្លងផុតប្រសិនបើម៉ោងតូចជាង)
  Duration _calculateTimeRemaining(EventModel event) {
    final eventDateTime = _getEventDateTime(event);
    if (eventDateTime == null) return const Duration();

    final now = DateTime.now();

    // 1. ប្រសិនបើ Event ស្ថិតក្នុងថ្ងៃបច្ចុប្បន្ន (Today) ប៉ុន្តែម៉ោងតូចជាងម៉ោងបច្ចុប្បន្ន
    // យើងគណនារយៈពេលរហូតដល់ចុងបញ្ចប់នៃថ្ងៃនេះ (23:59:59)
    final isToday = eventDateTime.year == now.year && eventDateTime.month == now.month && eventDateTime.day == now.day;

    if (isToday && eventDateTime.isBefore(now)) {
      final endOfToday = DateTime(now.year, now.month, now.day, 23, 59, 59);
      return endOfToday.difference(now);
    }

    // 2. គណនា difference រវាង EventDateTime និង ម៉ោងបច្ចុប្បន្នធម្មតា
    final difference = eventDateTime.difference(now);
    return difference.isNegative ? Duration.zero : difference;
  }

  /// គណនា Progress Percentage (%)
  double _calculateProgress(EventModel event) {
    final targetTime = _getEventDateTime(event);
    if (targetTime == null) return 0.0;

    final now = DateTime.now();
    // កំណត់វេលាចាប់ផ្តើមនៃថ្ងៃ (00:00:00)
    final startTime = DateTime(targetTime.year, targetTime.month, targetTime.day, 0, 0, 0);

    final totalDuration = targetTime.difference(startTime).inSeconds;
    final elapsedDuration = now.difference(startTime).inSeconds;

    if (totalDuration <= 0) {
      return now.isAfter(targetTime) ? 1.0 : 0.0;
    }

    double progress = elapsedDuration / totalDuration;
    return progress.clamp(0.0, 1.0);
  }

  String _getImageAsset(String? iconName) {
    final cleanName = iconName?.toLowerCase().trim();
    switch (cleanName) {
      case 'study':
      case 'work':
      case 'todo':
      case 'meeting':
        return 'assets/images/$cleanName.png';
      default:
        return 'assets/images/study.png';
    }
  }

  void _showActionBottomSheet(BuildContext context, EventModel event) {
    ConfirmBottomSheet.show(
      context: context,
      isFloating: true,
      title: "event".tr,
      content: SafeArea(
        child: Wrap(
          children: [
            buildActionItem(
              context,
              icon: Icons.check,
              color: AppColor().primaryColor,
              title: "completed".tr,
              onTap: () {
                Navigator.pop(context);
                if (event.id != null) {
                  showConfirmDialog(
                    context: context,
                    title: "make_completed".tr,
                    subTitle: "are_you_sure_make_completed".tr,
                    confirmText: "completed".tr,
                    onConfirm: () async {
                      await _controller.updateEventCompletionStatus(event.id!, true);
                    },
                  );
                } else {
                  AppSnackbar.showError(title: "error".tr, message: "cannot_make_completed".tr);
                }
              },
            ),
            buildActionItem(
              context,
              icon: Icons.edit_outlined,
              color: AppColor().primaryColor,
              title: "edit".tr,
              onTap: () async {
                Navigator.pop(context);
                Get.to(() => AddEventScreen(event: event));
              },
            ),
            buildActionItem(
              context,
              icon: Icons.delete_outline,
              color: AppColor().red,
              title: "delete".tr,
              onTap: () {
                Navigator.pop(context);
                if (event.id != null) {
                  showConfirmDialog(
                    context: context,
                    title: "delete".tr,
                    subTitle: "delete_confirm".tr,
                    confirmText: "delete".tr,
                    onConfirm: () async {
                      await _controller.deleteEvent(event.id!);
                    },
                  );
                } else {
                  AppSnackbar.showError(title: "error".tr, message: "cannot_delete_event".tr);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final events = _controller.upcomingEvents;
      if (events.isEmpty) {
        return Center(
          child: CustomNoData(
            message: "no_data".tr,
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          final Color baseColor = event.color != null ? Color(event.color!) : AppColor().primaryColor;
      
          final duration = _calculateTimeRemaining(event);
          final days = duration.inDays.toString().padLeft(2, '0');
          final hours = (duration.inHours % 24).toString().padLeft(2, '0');
          final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
          final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
      
          final double progressPercentage = _calculateProgress(event);
      
          return Container(
            margin: const EdgeInsets.only(bottom: 15),
            decoration: BoxDecoration(
              color: baseColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(18),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => Get.to(() => EventDetailsScreen(event: event)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: baseColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(width: 1, color: baseColor.withValues(alpha: 0.4)),
                          ),
                          child: Image.asset(
                            _getImageAsset(event.icon),
                            width: 40,
                            height: 40,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      event.title,
                                      style: fix18(context),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.more_horiz_outlined, color: AppColor().gray),
                                    onPressed: () => _showActionBottomSheet(context, event),
                                  ),
                                ],
                              ),
                              Text("${event.date} | ${event.time}", style: fix16(context).copyWith(color: AppColor().gray)),
                              const SizedBox(height: 10)
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: _countdownCard(days, "d".tr)),
                        const SizedBox(width: 20),
                        Expanded(child: _countdownCard(hours, "h".tr)),
                        const SizedBox(width: 20),
                        Expanded(child: _countdownCard(minutes, "m".tr)),
                        const SizedBox(width: 20),
                        Expanded(child: _countdownCard(seconds, "s".tr)),
                      ],
                    ),
                    // Overall Progress Bar Section
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("overall_progress".tr,
                            style: text14(context).copyWith(
                              color: AppColor().gray,
                            )),
                        Text(
                          "${(progressPercentage * 100).toStringAsFixed(0)}%",
                          style: fix16(context).copyWith(color: baseColor, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progressPercentage,
                        minHeight: 10,
                        backgroundColor: baseColor.withValues(alpha: 0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(baseColor),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          );
        },
      );
    });
  }

  Widget _countdownCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          Text(
            value,
            style: fix18(context).copyWith(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(label, style: text16(context).copyWith(color: AppColor().gray)),
        ],
      ),
    );
  }
}
