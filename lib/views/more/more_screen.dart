// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:project_structure/controllers/mores/notification_controller.dart';
// import 'package:project_structure/controllers/mores/theme_controller.dart';
// import 'package:project_structure/controllers/notes/note_controller.dart';
// import 'package:project_structure/core/utils/app_color.dart';
// import 'package:project_structure/core/utils/app_fonts.dart';
// import 'package:project_structure/core/utils/app_layout.dart';
// import 'package:project_structure/views/more/components/font_size.dart';
// import 'package:project_structure/views/more/components/change_language.dart';
// import 'package:project_structure/views/more/components/dark_mode.dart';

// class MoreScreen extends StatefulWidget {
//   const MoreScreen({
//     super.key,
//   });

//   @override
//   State<MoreScreen> createState() => _MoreScreenState();
// }

// class _MoreScreenState extends State<MoreScreen> {
//   final controller = Get.put(DarkModeController());
//   final RxBool notificationEnabled = true.obs;
//   final NotificationController notificontroller = Get.put(NotificationController());
//   final controllerDarkMode = Get.put(DarkModeController());
//   final NoteController noteController = Get.put(NoteController());

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Padding(
//         padding: Layout.padding(),
//         child: SingleChildScrollView(
//           scrollDirection: Axis.vertical,
//           child: Column(
//             children: [
//               _buildSectionContainer([
//                 CustomCardSetting(
//                   icon: Icons.info_outline,
//                   title: "about".tr,
//                   onTap: () {
//                     Get.toNamed('/about');
//                   },
//                 ),
//                 CustomCardSetting(
//                   icon: Icons.help_outline,
//                   title: "how_to_use".tr,
//                   onTap: () {
//                     Get.toNamed('/howToUse');
//                   },
//                 ),
//                 ChangeLanguageView(),
//                 CustomCardSetting(
//                   icon: Icons.text_fields,
//                   title: "font_size".tr,
//                   onTap: () {
//                     Get.bottomSheet(const FontSizeBottomSheet());
//                   },
//                 ),
//                 CustomCardSetting(
//                   icon: Icons.share_outlined,
//                   title: "share_app".tr,
//                   onTap: () {},
//                 ),
//                 CustomCardSetting(
//                   icon: Icons.delete_outline,
//                   title: "recently_deleted".tr,
//                   onTap: () {
//                     Get.toNamed('/recentyDelete');
//                   },
//                 ),
//                 Obx(() => CustomCardSetting(
//                       icon: Icons.sync,
//                       title: noteController.isSyncing.value ? "syncing".tr : "sync".tr,
//                       onTap: () async {
//                         if (noteController.isSyncing.value) {
//                           return;
//                         }

//                         await noteController.syncDataAction(
//                           1, // default folder id
//                         );
//                       },
//                       trailing: noteController.isSyncing.value
//                           ? const SizedBox(
//                               width: 22,
//                               height: 22,
//                               child: CircularProgressIndicator(
//                                 strokeWidth: 2,
//                               ),
//                             )
//                           : Icon(
//                               Icons.arrow_forward_ios,
//                               size: context.isPhone ? 16 : 20,
//                               color: AppColor().gray,
//                             ),
//                     )),
//               ]),
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 15),
//                 child: _buildSectionContainer([
//                   DarkModeView(),
//                   CustomCardSetting(
//                     icon: Icons.notifications_outlined,
//                     title: "notification".tr,
//                     onTap: () {},
//                     trailing: Obx(() => Switch.adaptive(
//                           value: notificontroller.isNotificationEnabled.value,
//                           onChanged: (value) => notificontroller.toggleNotifications(value),
//                         )),
//                   ),
//                 ]),
//               ),
//               _buildSectionContainer([
//                 CustomCardSetting(
//                   icon: Icons.lock_outline,
//                   title: "change_password".tr,
//                   onTap: () {
//                     Get.toNamed('/changePassword');
//                   },
//                 ),
//                 CustomCardSetting(
//                   icon: Icons.sync_lock_outlined,
//                   title: "reset_password".tr,
//                   onTap: () {
//                     Get.toNamed('/resetPassword');
//                   },
//                 ),
//                 CustomCardSetting(
//                   icon: Icons.lock_reset,
//                   title: "forget_password".tr,
//                   onTap: () {
//                     Get.toNamed('/fogetPassword');
//                   },
//                 ),
//               ]),
//               SizedBox(
//                 height: 15,
//               ),
//               Text("copyright".tr,
//                   textAlign: TextAlign.center,
//                   style: text12.copyWith(
//                     height: 1.5,
//                   )),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildSectionContainer(List<Widget> children) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Theme.of(context).cardColor,
//         borderRadius: BorderRadius.circular(18),
//         boxShadow: AppDecorations.subtleShadow,
//       ),
//       child: Column(children: children),
//     );
//   }
// }

// class CustomCardSetting extends StatelessWidget {
//   final IconData icon;
//   final String title;
//   final VoidCallback onTap;
//   final Widget? trailing;

//   const CustomCardSetting({
//     super.key,
//     required this.icon,
//     required this.title,
//     required this.onTap,
//     this.trailing,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final isPhone = context.isPhone;

//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(12),
//       child: Padding(
//         padding: EdgeInsets.symmetric(
//           vertical: isPhone ? 12 : 16,
//           horizontal: 16,
//         ),
//         child: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: AppColor().primaryColor.withValues(alpha: 0.1),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Icon(
//                 icon,
//                 color: AppColor().primaryColor,
//                 size: isPhone ? 20 : 24,
//               ),
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Text(
//                 title,
//                 style: text16(context),
//               ),
//             ),
//             trailing ??
//                 Icon(
//                   Icons.arrow_forward_ios,
//                   size: context.isPhone ? 16 : 20,
//                   color: AppColor().gray,
//                 ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/controllers/mores/notification_controller.dart';
import 'package:project_structure/controllers/mores/theme_controller.dart';
import 'package:project_structure/controllers/notes/note_controller.dart';
import 'package:project_structure/core/services/auth_service.dart'; // 🛡️ Import AuthService ថ្មី
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/core/utils/app_fonts.dart';
import 'package:project_structure/core/utils/app_layout.dart';
import 'package:project_structure/views/more/components/font_size.dart';
import 'package:project_structure/views/more/components/change_language.dart';
import 'package:project_structure/views/more/components/dark_mode.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({
    super.key,
  });

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  final controller = Get.put(DarkModeController());
  final RxBool notificationEnabled = true.obs;
  final NotificationController notificontroller = Get.put(NotificationController());
  final controllerDarkMode = Get.put(DarkModeController());
  final NoteController noteController = Get.put(NoteController());

  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: Layout.padding(),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              // GOOGLE SIGN-IN PROFILE HEADER
              StreamBuilder(
                stream: _authService.authStateChanges,
                builder: (context, snapshot) {
                  final user = snapshot.data;

                  return Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: user != null
                        ? Row(
                            children: [
                              // Profile
                              Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColor().primaryColor,
                                      AppColor().primaryColor.withValues(alpha: 0.4),
                                    ],
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 32,
                                  backgroundColor: Theme.of(context).cardColor,
                                  backgroundImage: user.photoURL != null ? NetworkImage(user.photoURL!) : null,
                                  child: user.photoURL == null
                                      ? Icon(
                                          Icons.person,
                                          size: 35,
                                          color: AppColor().primaryColor,
                                        )
                                      : null,
                                ),
                              ),

                              const SizedBox(width: 16),

                              // User info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.displayName ?? "Google User",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: text16(context).copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      user.email ?? "",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: text12.copyWith(
                                        color: AppColor().gray,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Text(
                                        "Synced",
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Logout
                              IconButton(
                                onPressed: () async {
                                  await _authService.signOut();

                                  Get.snackbar(
                                    "Signed Out",
                                    "Your account has been disconnected.",
                                    snackPosition: SnackPosition.BOTTOM,
                                  );
                                },
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.red.withValues(alpha: 0.1),
                                ),
                                icon: const Icon(
                                  Icons.logout_rounded,
                                  color: Colors.redAccent,
                                ),
                              ),
                            ],
                          )
                        : InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () async {
                              final signedInUser = await _authService.signInWithGoogle();

                              if (signedInUser != null) {
                                Get.snackbar(
                                  "Welcome",
                                  signedInUser.displayName ?? "User",
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  // Google logo
                                  Container(
                                    width: 55,
                                    height: 55,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.08),
                                          blurRadius: 10,
                                        )
                                      ],
                                    ),
                                    child: Center(
                                      child: Image.asset(
                                        "assets/images/google.png",
                                        width: 30,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 16),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Backup & Restore",
                                          style: text16(context).copyWith(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "Sign in with Google to sync your notes",
                                          style: text12.copyWith(
                                            color: AppColor().gray,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppColor().primaryColor.withValues(alpha: 0.12),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 18,
                                      color: AppColor().primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                  );
                },
              ),
              SizedBox(
                height: 20,
              ),

              //  SETTINGS LIST
              _buildSectionContainer([
                CustomCardSetting(
                  icon: Icons.info_outline,
                  title: "about".tr,
                  onTap: () {
                    Get.toNamed('/about');
                  },
                ),
                CustomCardSetting(
                  icon: Icons.help_outline,
                  title: "how_to_use".tr,
                  onTap: () {
                    Get.toNamed('/howToUse');
                  },
                ),
                ChangeLanguageView(),
                CustomCardSetting(
                  icon: Icons.text_fields,
                  title: "font_size".tr,
                  onTap: () {
                    Get.bottomSheet(const FontSizeBottomSheet());
                  },
                ),
                CustomCardSetting(
                  icon: Icons.share_outlined,
                  title: "share_app".tr,
                  onTap: () {},
                ),
                CustomCardSetting(
                  icon: Icons.delete_outline,
                  title: "recently_deleted".tr,
                  onTap: () {
                    Get.toNamed('/recentyDelete');
                  },
                ),

                // 🔄 Sync Button with Reactive Loading State
                Obx(() => CustomCardSetting(
                      icon: Icons.sync,
                      title: noteController.isSyncing.value ? "syncing".tr : "sync".tr,
                      onTap: () async {
                        // ហៅមុខងារ SyncDataAction
                        await noteController.syncDataAction(1); // 1 = Default Folder ID
                      },
                      trailing: noteController.isSyncing.value
                          ? SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColor().primaryColor,
                              ),
                            )
                          : Icon(
                              Icons.arrow_forward_ios,
                              size: context.isPhone ? 16 : 20,
                              color: AppColor().gray,
                            ),
                    )),
              ]),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: _buildSectionContainer([
                  DarkModeView(),
                  CustomCardSetting(
                    icon: Icons.notifications_outlined,
                    title: "notification".tr,
                    onTap: () {},
                    trailing: Obx(() => Switch.adaptive(
                          value: notificontroller.isNotificationEnabled.value,
                          onChanged: (value) => notificontroller.toggleNotifications(value),
                        )),
                  ),
                ]),
              ),

              _buildSectionContainer([
                CustomCardSetting(
                  icon: Icons.lock_outline,
                  title: "change_password".tr,
                  onTap: () {
                    Get.toNamed('/changePassword');
                  },
                ),
                CustomCardSetting(
                  icon: Icons.sync_lock_outlined,
                  title: "reset_password".tr,
                  onTap: () {
                    Get.toNamed('/resetPassword');
                  },
                ),
                CustomCardSetting(
                  icon: Icons.lock_reset,
                  title: "forget_password".tr,
                  onTap: () {
                    Get.toNamed('/fogetPassword');
                  },
                ),
              ]),

              const SizedBox(height: 15),

              Text("copyright".tr,
                  textAlign: TextAlign.center,
                  style: text12.copyWith(
                    height: 1.5,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionContainer(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppDecorations.subtleShadow,
      ),
      child: Column(children: children),
    );
  }
}

class CustomCardSetting extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Widget? trailing;

  const CustomCardSetting({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isPhone = context.isPhone;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: isPhone ? 12 : 16,
          horizontal: 16,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColor().primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: AppColor().primaryColor,
                size: isPhone ? 20 : 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: text16(context),
              ),
            ),
            trailing ??
                Icon(
                  Icons.arrow_forward_ios,
                  size: context.isPhone ? 16 : 20,
                  color: AppColor().gray,
                ),
          ],
        ),
      ),
    );
  }
}
