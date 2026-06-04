import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:project_structure/controllers/focus_track/timer_controller.dart';
import 'package:project_structure/core/utils/app_fonts.dart';
import 'package:project_structure/models/focus_track/timer_model.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/widgets/custom_appbar.dart';
import 'package:project_structure/widgets/custom_confirm_bottomsheet.dart';
import 'package:project_structure/widgets/custom_dialog.dart';
import 'package:project_structure/widgets/custom_text_field.dart';

class CreateTimerScreen extends StatefulWidget {
  final bool isEditing;
  final dynamic timerKey;
  final TimerModel? existingTimer;

  const CreateTimerScreen({
    super.key,
    this.isEditing = false,
    this.timerKey,
    this.existingTimer,
  });

  @override
  State<CreateTimerScreen> createState() => _CreateTimerScreenState();
}

class _CreateTimerScreenState extends State<CreateTimerScreen> {
  late int selectedHours;
  late int selectedMinutes;
  late int selectedSeconds;
  late TextEditingController _labelController;

  late FixedExtentScrollController hourController;
  late FixedExtentScrollController minController;
  late FixedExtentScrollController secController;

  @override
  void initState() {
    super.initState();
    // Initialize values based on whether we are editing or creating
    if (widget.isEditing && widget.existingTimer != null) {
      final total = widget.existingTimer!.totalSeconds;
      selectedHours = total ~/ 3600;
      selectedMinutes = (total % 3600) ~/ 60;
      selectedSeconds = total % 60;
      _labelController = TextEditingController(text: widget.existingTimer!.title);
    } else {
      selectedHours = 1;
      selectedMinutes = 20;
      selectedSeconds = 40;
      _labelController = TextEditingController(text: (widget.existingTimer?.title != null && widget.existingTimer!.title.isNotEmpty) ? widget.existingTimer!.title : "Timer");
    }

    hourController = FixedExtentScrollController(initialItem: selectedHours);
    minController = FixedExtentScrollController(initialItem: selectedMinutes);
    secController = FixedExtentScrollController(initialItem: selectedSeconds);
  }

  void _setPreset(int h, int m, int s) {
    setState(() {
      selectedHours = h;
      selectedMinutes = m;
      selectedSeconds = s;
    });

    hourController.animateToItem(h, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    minController.animateToItem(m, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    secController.animateToItem(s, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  Future<bool> _finalizePresetSave(int h, int m, int s) async {
    if (h == 0 && m == 0 && s == 0) return false;

    bool isFixedDuplicate = (h == 0 && m == 10 && s == 0) || (h == 0 && m == 30 && s == 0) || (h == 0 && m == 50 && s == 0);

    if (isFixedDuplicate) {
      showConfirmDialog(
        context: context,
        title: "already_exists".tr,
        subTitle: "preset_exists_msg".tr,
        showCancel: false,
        onConfirm: () {},
        confirmText: "ok".tr,
      );
      return false;
    }

    final settingsBox = Hive.box('create_timer_box');
    List rawList = settingsBox.get('user_presets', defaultValue: []);
    List customPresets = List.from(rawList);

    bool isUserDuplicate = customPresets.any((p) => p['h'] == h && p['m'] == m && p['s'] == s);

    if (isUserDuplicate) {
      showConfirmDialog(
        context: context,
        title: "already_exists".tr,
        subTitle: "preset_exists_msg".tr,
        showCancel: false,
        onConfirm: () {},
        confirmText: "ok".tr,
      );
      return false;
    }

    // String label = "${h > 0 ? '${h}h ' : ''}${m > 0 ? '${m}m ' : ''}${s > 0 ? '${s}s' : ''}".trim();
    String label = "${h > 0 ? '$h ${"h".tr} ' : ''}"
            "${m > 0 ? '$m ${"m".tr} ' : ''}"
            "${s > 0 ? '$s ${"s".tr}' : ''}"
        .trim();
    Map<String, dynamic> newPreset = {"label": label, "h": h, "m": m, "s": s};

    customPresets.add(newPreset);
    await settingsBox.put('user_presets', customPresets);
    setState(() {});
    return true;
  }

  void _saveTimer() async {
    final Box<TimerModel> box = Hive.box<TimerModel>('timer_box');
    int totalSec = (selectedHours * 3600) + (selectedMinutes * 60) + selectedSeconds;

    if (totalSec <= 0) {
      showConfirmDialog(
        context: context,
        title: "duration".tr,
        subTitle: "duration_zero_msg".tr,
        showCancel: false,
        onConfirm: () {},
        confirmText: "ok".tr,
      );
      return;
    }

    bool isDuplicate = box.values.any((timer) => timer.totalSeconds == totalSec && timer.title.trim().toLowerCase() == _labelController.text.trim().toLowerCase());

    if (isDuplicate) {
      showConfirmDialog(
        context: context,
        title: "duplicate".tr,
        subTitle: "duplicate_timer_msg".tr,
        showCancel: false,
        onConfirm: () {},
        confirmText: "ok".tr,
      );
      return;
    }

    if (widget.isEditing && widget.existingTimer != null) {
      final TimerController controller = Get.find<TimerController>();

      // Reset controller state for this timer
      controller.activeTimerKeys.remove(widget.timerKey);
      controller.resetTimerMemory(widget.timerKey);

      // Update the Hive object
      widget.existingTimer!.title = _labelController.text;
      widget.existingTimer!.totalSeconds = totalSec;
      widget.existingTimer!.remainingSeconds = totalSec;

      await widget.existingTimer!.save();
    } else {
      // Create and add new timer
      final newTimer = TimerModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _labelController.text,
        totalSeconds: totalSec,
        remainingSeconds: totalSec,
        createdAt: DateTime.now(),
      );
      await box.add(newTimer);
    }

    Get.back();
  }

  @override
  void dispose() {
    hourController.dispose();
    minController.dispose();
    secController.dispose();
    _labelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: customAppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: widget.isEditing ? "edit_timer".tr : "new_timer".tr,
        titleColor: AppColor().primaryColor,
        context: context,
        leadingColor: AppColor().primaryColor,
        actions: [
          TextButton(
              onPressed: _saveTimer,
              child: Text(
                "save".tr,
                style: text18(context).copyWith(color: AppColor().primaryColor),
              )),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: customHeader("duration".tr, context),
                ),
                _buildPickerSection(),
                const SizedBox(height: 25),
                _buildLabelRow(),
                const SizedBox(height: 20),
                _buildPresetHeader(),
                _buildAllPresets(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPickerSection() {
    return Container(
      height: context.isPhone ? 200 : 300,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          _buildPicker(24, "h".tr, hourController, (v) => selectedHours = v),
          _buildPicker(60, "m".tr, minController, (v) => selectedMinutes = v),
          _buildPicker(60, "s".tr, secController, (v) => selectedSeconds = v),
        ],
      ),
    );
  }

  Widget _buildPicker(int count, String unit, FixedExtentScrollController controller, ValueChanged<int> onSelect) {
    return Expanded(
      child: CupertinoPicker(
        scrollController: controller,
        itemExtent: 40,
        onSelectedItemChanged: (index) {
          setState(() => onSelect(index));
        },
        children: List.generate(count, (i) => Center(child: Text("$i $unit", style: TextStyle(fontSize: AppFontSize(context).titleSize, fontFamily: 'EN-REGULAR')))),
      ),
    );
  }

  Widget _buildLabelRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Text("label".tr, style: text16(context)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: customTextField(
              "password".tr,
              false,
              null,
              controller: _labelController,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetHeader() {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          customHeader("quick_presets".tr, context),
          IconButton(
            onPressed: () => showAddPresetSheet(),
            icon: Icon(Icons.add_circle_outline, color: AppColor().primaryColor, size: context.isPhone ? 28 : 32),
          ),
        ],
      ),
    );
  }

  Widget _buildAllPresets() {
    final settingsBox = Hive.box('create_timer_box');
    final List rawList = settingsBox.get('user_presets', defaultValue: []);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          _fixedPresetItem("10 ${'m'.tr}", 0, 10, 0),
          _fixedPresetItem("30 ${'m'.tr}", 0, 30, 0),
          _fixedPresetItem("50 ${'m'.tr}", 0, 50, 0),
          ...rawList.map((p) => _presetButton(
                p['label'].toString(),
                () => _setPreset(p['h'], p['m'], p['s']),
                onLongPress: () {
                  List updated = List.from(rawList);
                  updated.remove(p);
                  settingsBox.put('user_presets', updated);
                  setState(() {});
                },
              )),
        ],
      ),
    );
  }

  Widget _fixedPresetItem(String text, int h, int m, int s) => _presetButton(text, () => _setPreset(h, m, s));

  Widget _presetButton(String text, VoidCallback onTap, {VoidCallback? onLongPress}) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: (MediaQuery.of(context).size.width - 60) / 3,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.blueGrey.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.blueGrey.withValues(alpha: 0.1)),
        ),
        child: Center(
            child: Text(text,
                style: const TextStyle(
                  color: Colors.blueGrey,
                ))),
      ),
    );
  }

  void showAddPresetSheet() {
    int tempH = selectedHours;
    int tempM = selectedMinutes;
    int tempS = selectedSeconds;

    ConfirmBottomSheet.show(
      context: context,
      title: "add_quick_preset".tr,
      content: StatefulBuilder(
        builder: (context, setSheetState) {
          return Container(
            height: context.isPhone ? 200 : 300,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.01),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                _buildSheetPicker(24, "h".tr, (v) => setSheetState(() => tempH = v), initial: tempH),
                _buildSheetPicker(60, "m".tr, (v) => setSheetState(() => tempM = v), initial: tempM),
                _buildSheetPicker(60, "s".tr, (v) => setSheetState(() => tempS = v), initial: tempS),
              ],
            ),
          );
        },
      ),
      confirmText: "save_preset".tr,
      onConfirm: () async {
        await _finalizePresetSave(tempH, tempM, tempS);
      },
    );
  }

  Widget _buildSheetPicker(int max, String label, Function(int) onChanged, {int initial = 0}) {
    return Expanded(
      child: CupertinoPicker(
        scrollController: FixedExtentScrollController(initialItem: initial),
        itemExtent: 35,
        onSelectedItemChanged: onChanged,
        children: List.generate(
          max,
          (index) => Center(
            child: Text("$index $label", style: text16(context)),
          ),
        ),
      ),
    );
  }
}
