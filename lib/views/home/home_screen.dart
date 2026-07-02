import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:project_structure/controllers/lock/lock_controller.dart';
import 'package:project_structure/controllers/home/folder_controller.dart';
import 'package:project_structure/controllers/notes/note_controller.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/core/utils/app_fonts.dart';
import 'package:project_structure/core/utils/app_layout.dart';
import 'package:project_structure/models/home/folder_model.dart';
import 'package:project_structure/views/note/create_note/create_note_screen.dart';
import 'package:project_structure/views/note/folder_note_list/folder_note_list_screen.dart';
import 'package:project_structure/views/home/components/create_folder.dart';
import 'package:project_structure/views/home/components/folder_search.dart';
import 'package:project_structure/widgets/app_snack_bar.dart';
import 'package:project_structure/widgets/dialog_and_buttonsheet/custom_dialog.dart';
import 'package:project_structure/widgets/custom_fab.dart';
import 'package:project_structure/widgets/app_slidable_asction.dart';
import 'package:project_structure/widgets/custome_no_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FolderController controller = Get.put(FolderController());
  final NoteController noteController = Get.put(NoteController());
  final LockController lockController = Get.put(LockController());
  final TextEditingController folderSearchController = TextEditingController();

  final GlobalKey _firstShowcaseWidget = GlobalKey();
  final GlobalKey _lastShowcaseWidget = GlobalKey();
  final GlobalKey _two = GlobalKey();
  final GlobalKey _three = GlobalKey();
  final GlobalKey _four = GlobalKey();

  @override
  void initState() {
    super.initState();
    _registerShowcaseConfiguration();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkAndStartShowcase());
  }

  Future<void> _checkAndStartShowcase() async {
    final prefs = await SharedPreferences.getInstance();
    bool hasShownShowcase = prefs.getBool('has_shown_showcase') ?? false;

    if (!hasShownShowcase) {
      if (mounted) {
        ShowcaseView.get().startShowCase(
          [_firstShowcaseWidget, _two, _three, _four, _lastShowcaseWidget],
        );
        await prefs.setBool('has_shown_showcase', true);
      }
    }
  }

  void _registerShowcaseConfiguration() {
    ShowcaseView.register(
      hideFloatingActionWidgetForShowcase: [_lastShowcaseWidget],
      globalFloatingActionWidget: (showcaseContext) => FloatingActionWidget(
        left: 16,
        bottom: 16,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () => ShowcaseView.get().dismiss(),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xffEE5366)),
            child: Text('skip'.tr, style: text12.copyWith(color: AppColor().white)),
          ),
        ),
      ),
      onStart: (index, key) => log('onStart: $index, $key'),
      onComplete: (index, key) {
        log('onComplete: $index, $key');
        if (index == 4) {
          SystemChrome.setSystemUIOverlayStyle(
            SystemUiOverlayStyle.light.copyWith(
              statusBarIconBrightness: Brightness.dark,
              statusBarColor: AppColor().white,
            ),
          );
        }
      },
      blurValue: 1,
      autoPlayDelay: const Duration(seconds: 3),
      globalTooltipActionConfig: const TooltipActionConfig(
        position: TooltipActionPosition.inside,
        alignment: MainAxisAlignment.spaceBetween,
        actionGap: 20,
      ),
      globalTooltipActions: [
        TooltipActionButton(
          type: TooltipDefaultActionType.previous,
          name: 'previous'.tr,
          textStyle: text12.copyWith(color: AppColor().white),
          hideActionWidgetForShowcase: [_firstShowcaseWidget],
        ),
        TooltipActionButton(
          type: TooltipDefaultActionType.next,
          name: 'next'.tr,
          textStyle: text12.copyWith(color: AppColor().white),
          hideActionWidgetForShowcase: [_lastShowcaseWidget],
        ),
      ],
      onDismiss: (key) => debugPrint('Dismissed at $key'),
    );
  }

  @override
  void dispose() {
    folderSearchController.dispose();
    ShowcaseView.get().unregister();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FolderSearch(
            controller: folderSearchController,
            folderController: controller,
            showcaseKey: _firstShowcaseWidget,
          ),
          Padding(
            padding: Layout.padding(),
            child: Text(
              "folder".tr,
              style: text20(context),
            ),
          ),
          Expanded(
            child: Obx(() {
              final displayedFolders = controller.filteredFolders;

              if (displayedFolders.isEmpty) {
                return _buildEmptyState();
              }
              return SlidableAutoCloseBehavior(
                child: ListView.builder(
                  itemCount: controller.folders.length,
                  padding: const EdgeInsets.only(bottom: 100),
                  itemBuilder: (context, index) {
                    final folder = controller.folders[index];
                    final isDefault = controller.isDefaultFolder(folder);

                    return Padding(
                      padding: Layout.padding(),
                      child: Showcase(
                        key: _two,
                        description: 'tap_to_my_folder'.tr,
                        descTextStyle: text14(context).copyWith(color: AppColor().black),
                        onBarrierClick: () {
                          debugPrint('Barrier clicked');
                          debugPrint(
                            'Floating Action widget for first showcase is now hidden',
                          );
                          ShowcaseView.get().hideFloatingActionWidgetForKeys([
                            _firstShowcaseWidget,
                            _lastShowcaseWidget,
                          ]);
                        },
                        targetBorderRadius: BorderRadius.circular(12),
                        tooltipBorderRadius: BorderRadius.circular(12),
                        tooltipActionConfig: const TooltipActionConfig(
                          alignment: MainAxisAlignment.end,
                          position: TooltipActionPosition.outside,
                          gapBetweenContentAndAction: 10,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Slidable(
                            enabled: !isDefault,
                            key: ValueKey(folder.id),
                            startActionPane: ActionPane(
                              motion: const BehindMotion(),
                              children: [
                                AppSlidableAction(
                                  onPressed: () => _togglePin(folder),
                                  icon: folder.isPinned ? Icons.push_pin_outlined : Icons.push_pin,
                                  label: folder.isPinned ? 'unpin'.tr : 'pin'.tr,
                                  iconSize: 20,
                                  backgroundColor: AppColor().orange,
                                ),
                                AppSlidableAction(
                                  onPressed: () => _toggleLock(folder),
                                  icon: folder.isLocked ? Icons.lock_open : Icons.lock,
                                  label: folder.isLocked ? 'unlock'.tr : 'lock'.tr,
                                  iconSize: 20,
                                  backgroundColor: AppColor().green,
                                ),
                              ],
                            ),
                            endActionPane: ActionPane(
                              motion: const DrawerMotion(),
                              children: [
                                AppSlidableAction(
                                  onPressed: () => _handleEditFolder(context, folder),
                                  icon: Icons.edit,
                                  label: 'edit'.tr,
                                  iconSize: 20,
                                  backgroundColor: AppColor().primaryColor,
                                ),
                                AppSlidableAction(
                                  onPressed: () => _confirmDelete(context, folder),
                                  icon: Icons.delete,
                                  label: 'delete'.tr,
                                  iconSize: 20,
                                  backgroundColor: AppColor().red,
                                  borderRadius: const BorderRadius.horizontal(
                                    right: Radius.circular(16),
                                  ),
                                ),
                              ],
                            ),
                            child: folderTile(folder, isDefault),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: Showcase(
        key: _three,
        description: 'tap_to_create_note'.tr,
        descTextStyle: text14(context).copyWith(color: AppColor().black),
        targetBorderRadius: BorderRadius.circular(12),
        tooltipBorderRadius: BorderRadius.circular(12),
        tooltipActionConfig: const TooltipActionConfig(
          alignment: MainAxisAlignment.end,
          position: TooltipActionPosition.outside,
          gapBetweenContentAndAction: 10,
        ),
        tooltipActions: [
          TooltipActionButton(
              type: TooltipDefaultActionType.previous,
              name: 'previous'.tr,
              onTap: () {
                ShowcaseView.get().previous();
              },
              backgroundColor: AppColor().primaryColor,
              textStyle: text14(context).copyWith(color: AppColor().white)),
          TooltipActionButton(type: TooltipDefaultActionType.skip, name: 'next'.tr, textStyle: text14(context).copyWith(color: AppColor().white)),
        ],
        child: CustomFab(
          onPressed: () {
            final int targetFolderId = controller.defaultFolderId;

            Get.to(() => CreateNoteScreen(
                  isEditing: false,
                  folderId: targetFolderId,
                ));
          },
        ),
      ),
    );
  }

  void _togglePin(FolderModel folder) async {
    await controller.togglePin(folder.id!);
  }

  void _toggleLock(FolderModel folder) async {
    final settings = await lockController.getSecuritySettings();
    String storedPass = settings?['master_password'] ?? "";

    if (storedPass.isEmpty) {
      Get.toNamed('/createPassword');
      return;
    }

    if (folder.isLocked) {
      final TextEditingController verifyPassController = TextEditingController();

      if (!mounted) return;

      showConfirmDialog(
        context: context,
        title: "unlock_folder".tr,
        subTitle: "enter_password_unlock_folder".tr,
        confirmText: "unlock".tr,
        controller: verifyPassController,
        obscureText: true,
        hintText: "password".tr,
        onConfirm: () async {
          if (verifyPassController.text == storedPass) {
            await controller.toggleLock(folder.id!);
            Get.back();
          } else {
            AppSnackbar.showError(
              title: "verification_failed".tr,
              message: "incorrect_password".tr,
            );
          }
        },
      );
    } else {
      await controller.toggleLock(folder.id!);
    }
  }

  void _handleEditFolder(BuildContext context, FolderModel folder) async {
    if (!folder.isLocked) {
      createFolder(context, folder: folder);
      return;
    }
    final settings = await lockController.getSecuritySettings();
    String storedPass = settings?['master_password'] ?? "";
    final TextEditingController verifyPassController = TextEditingController();

    if (!mounted) return;

    showConfirmDialog(
      context: Get.context!,
      title: "verify_password".tr,
      subTitle: "enter_password_edit_folder".tr,
      confirmText: "verify".tr,
      controller: verifyPassController,
      obscureText: true,
      hintText: "password".tr,
      onConfirm: () {
        if (verifyPassController.text == storedPass) {
          Get.back();
          createFolder(context, folder: folder);
        } else {
          AppSnackbar.showError(
            title: "verification_failed".tr,
            message: "incorrect_password".tr,
          );
        }
      },
    );
  }

  void _confirmDelete(BuildContext context, FolderModel folder) async {
    bool folderLocked = folder.isLocked;

    bool containsLockedNotes = await noteController.hasLockedNotesInFolder(folder.id!);

    if (folderLocked || containsLockedNotes) {
      final settings = await lockController.getSecuritySettings();
      String storedPass = settings?['master_password'] ?? "";
      final TextEditingController verifyPassController = TextEditingController();

      if (!context.mounted) return;

      showConfirmDialog(
        context: context,
        title: "locked_folder".tr,
        subTitle: containsLockedNotes ? "locked_folder_with_notes".tr : "locked_folder_no_notes".tr,
        confirmText: "unlock".tr,
        controller: verifyPassController,
        obscureText: true,
        hintText: "password".tr,
        onConfirm: () {
          if (verifyPassController.text == storedPass) {
            Get.back();
            _proceedWithDeletion(folder);
          } else {
            AppSnackbar.showError(
              title: "verification_failed".tr,
              message: "incorrect_password".tr,
            );
          }
        },
      );
    } else {
      _proceedWithDeletion(folder);
    }
  }

  void _proceedWithDeletion(FolderModel folder) {
    showConfirmDialog(
      context: context,
      title: "delete_folder".tr,
      subTitle: "delete_folder_confirm_subtitle".tr,
      confirmText: "delete".tr,
      onConfirm: () async {
        await noteController.bulkMoveToTrashByFolder(folder.id!, controller.defaultFolderId);
        await controller.deleteFolder(folder.id!);
        await noteController.fetchTrashNotes();

        Get.back();
      },
    );
  }

  Widget folderTile(FolderModel folder, bool isDefault) {
    return GestureDetector(
      onTap: () async {
        final settings = await lockController.getSecuritySettings();
        String storedPass = settings?['master_password'] ?? "";

        bool needsVerification = folder.isLocked && storedPass.isNotEmpty;

        if (needsVerification) {
          final TextEditingController verifyPassController = TextEditingController();

          if (!context.mounted) return;

          showConfirmDialog(
            context: Get.context!,
            title: "locked_folder".tr,
            subTitle: "enter_password_unlock_folder".tr,
            confirmText: "unlock".tr,
            controller: verifyPassController,
            obscureText: true,
            hintText: "password".tr,
            onConfirm: () {
              if (verifyPassController.text == storedPass) {
                Get.back();
                Get.to(() => FolderNoteListScreen(
                      folderId: folder.id!,
                      folderName: folder.title,
                    ));
                controller.folders.refresh();
              } else {
                AppSnackbar.showError(
                  title: "verification_failed".tr,
                  message: "incorrect_password".tr,
                );
              }
            },
          );
        } else {
          Get.to(() => FolderNoteListScreen(
                folderId: folder.id!,
                folderName: folder.title,
              ));
          controller.folders.refresh();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            buildFolderIcon(folder, isDefault),
            const SizedBox(width: 12),
            Expanded(
              child: Text(controller.isDefaultFolder(folder) ? controller.displayDefaultFolderName : folder.title,
                  // folder.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: fix16(context)),
            ),
            const SizedBox(width: 10),
            if (folder.isPinned)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Icon(Icons.push_pin, size: 18, color: AppColor().orange),
              ),
            Obx(() {
              noteController.notes.length;

              return FutureBuilder<int>(
                future: noteController.getCountForFolder(folder.id!),
                builder: (context, snapshot) {
                  return Text(
                    "${snapshot.data ?? 0}",
                    style: text16(context).copyWith(color: AppColor().gray),
                  );
                },
              );
            })
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: CustomNoData(
        message: controller.searchQuery.isEmpty ? "no_folders_yet".tr : "no_data".tr,
        imagePath: "assets/images/no_data.png",
      ),
    );
  }

  Widget buildFolderIcon(FolderModel folder, bool isDefault) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(
          Icons.folder,
          color: isDefault ? AppColor().primaryColor : AppColor().primaryColor,
          size: 35,
        ),
        if (!isDefault && folder.isLocked)
          Icon(
            Icons.lock,
            size: 16,
            color: AppColor().white,
          ),
      ],
    );
  }
}
