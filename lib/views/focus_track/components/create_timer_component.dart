import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:project_structure/controllers/focus_track/timer_controller.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/widgets/custom_appbar.dart';
import 'package:project_structure/widgets/custom_button.dart';
import 'package:project_structure/widgets/custom_header.dart';
import 'package:project_structure/widgets/sheet_header.dart';

class CreateTimerScreen extends StatefulWidget {
  final bool isEditing;
  final dynamic timerKey;
  final Map? existingTimer;

  const CreateTimerScreen({super.key, this.isEditing = false, this.timerKey, this.existingTimer});

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
    if (widget.isEditing && widget.existingTimer != null) {
      int total = widget.existingTimer!['totalSeconds'];
      selectedHours = total ~/ 3600;
      selectedMinutes = (total % 3600) ~/ 60;
      selectedSeconds = total % 60;
      _labelController = TextEditingController(text: widget.existingTimer!['title']);
    } else {
      selectedHours = 3;
      selectedMinutes = 50;
      selectedSeconds = 20;
      _labelController = TextEditingController(text: "Timer");
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

  void _showAddPresetSheet(BuildContext context) {
    int tempH = 1;
    int tempM = 3;
    int tempS = 5;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(builder: (context, setSheetState) {
          return Padding(
            padding: EdgeInsetsGeometry.all(15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SheetHeader(
                  title: "Add Quick Preset",
                ),
                const SizedBox(height: 20),
                Container(
                  height: 150,
                  decoration: BoxDecoration(color: Colors.grey.withOpacity(0.05), borderRadius: BorderRadius.circular(15)),
                  child: Row(
                    children: [
                      _buildSheetPicker(24, "h", (v) => setSheetState(() => tempH = v), initial: tempH),
                      _buildSheetPicker(60, "m", (v) => setSheetState(() => tempM = v), initial: tempM),
                      _buildSheetPicker(60, "s", (v) => setSheetState(() => tempS = v), initial: tempS),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                CustomButton(
                  text: "Save Preset",
                  backgroundColor: AppColor().primaryColor,
                  textColor: Colors.white,
                  borderRadius: 12,
                  onPressed: () {
                    _finalizePresetSave(tempH, tempM, tempS);
                    Navigator.pop(context);
                  },
                )
              ],
            ),
          );
        });
      },
    );
  }

  Widget _buildSheetPicker(int max, String label, Function(int) onChanged, {int initial = 0}) {
    return Expanded(
      child: CupertinoPicker(
        scrollController: FixedExtentScrollController(initialItem: initial),
        itemExtent: 40,
        onSelectedItemChanged: onChanged,
        children: List.generate(
          max,
          (index) => Center(
            child: Text(
              "$index $label",
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ),
      ),
    );
  }

  void _finalizePresetSave(int h, int m, int s) async {
    // 1. Guard against zero duration
    if (h == 0 && m == 0 && s == 0) return;

    final box = Hive.box('timer_box');
    List rawList = box.get('user_presets', defaultValue: []);
    List customPresets = List.from(rawList);

    // 2. DUPLICATE CHECK: Look for an existing preset with the same H, M, and S
    bool isDuplicate = customPresets.any((p) {
      final Map data = p as Map;
      return data['h'] == h && data['m'] == m && data['s'] == s;
    });

    if (isDuplicate) {
      Get.snackbar(
        "Already Exists",
        "This time is already in your presets.",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // 3. Generate Label
    String label = "${h > 0 ? '${h}h ' : ''}${m > 0 ? '${m}m ' : ''}${s > 0 ? '${s}s' : ''}".trim();

    if (h == 0 && m == 0 && s > 0) {
      label = "${s}s";
    }

    // 4. Save New Preset
    Map<String, dynamic> newPreset = {"label": label, "h": h, "m": m, "s": s};
    customPresets.add(newPreset);
    await box.put('user_presets', customPresets);

    setState(() {});
  }

  void _saveTimer() async {
    final box = Hive.box('timer_box');
    int totalSec = (selectedHours * 3600) + (selectedMinutes * 60) + selectedSeconds;

    if (totalSec <= 0) {
      Get.snackbar("Error", "Duration cannot be zero", snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final timerData = {
      "type": "timer",
      "title": _labelController.text,
      "totalSeconds": totalSec,
      "remainingSeconds": totalSec,
      "updatedAt": DateTime.now().toIso8601String(),
      "createdAt": widget.isEditing ? widget.existingTimer!['createdAt'] : DateTime.now().toIso8601String(),
    };

    if (widget.isEditing) {
      final TimerController controller = Get.find<TimerController>();
      controller.resetTimerMemory(widget.timerKey);
      await box.put(widget.timerKey, timerData);
    } else {
      await box.add(timerData);
    }
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: customAppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: widget.isEditing ? "Edit Timer" : "New Timer",
        titleColor: AppColor().primaryColor,
        context: context,
        leadingColor: AppColor().primaryColor,
        actions: [
          TextButton(
            onPressed: _saveTimer,
            child: Text("Save",
                style: TextStyle(
                  color: AppColor().primaryColor,
                  fontSize: 20,
                  fontFamily: 'EN-SEMIBOLD',
                )),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: customHeader("Duration"),
            ),
            _buildPickerSection(),
            const SizedBox(height: 30),
            _buildLabelRow(),
            const SizedBox(height: 30),
            _buildPresetHeader(),
            _buildAllPresets(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerSection() {
    return Container(
      height: 220,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          _buildPicker(24, "h", hourController, (v) => selectedHours = v),
          _buildPicker(60, "m", minController, (v) => selectedMinutes = v),
          _buildPicker(60, "s", secController, (v) => selectedSeconds = v),
        ],
      ),
    );
  }

  Widget _buildPicker(int count, String unit, FixedExtentScrollController controller, ValueChanged<int> onSelect) {
    return Expanded(
      child: CupertinoPicker(
        scrollController: controller,
        itemExtent: 40,
        onSelectedItemChanged: onSelect,
        children: List.generate(count, (i) => Center(child: Text("$i $unit", style: const TextStyle(fontSize: 22)))),
      ),
    );
  }

  Widget _buildLabelRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text("Label", style: TextStyle(fontSize: context.isPhone ? 16 : 18, fontFamily: 'EN-BOLD')),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _labelController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.withOpacity(0.1),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
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
          customHeader("Quick Presets"),
          IconButton(
            onPressed: () => _showAddPresetSheet(context),
            icon: Icon(Icons.add_circle_outline, color: AppColor().primaryColor, size: context.isPhone ? 25 : 28),
          ),
        ],
      ),
    );
  }

  Widget _buildAllPresets() {
    final box = Hive.box('timer_box');
    final List rawList = box.get('user_presets', defaultValue: []);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          _fixedPresetItem("10 m", 0, 10, 0),
          _fixedPresetItem("30 m", 0, 30, 0),
          _fixedPresetItem("50 m", 0, 50, 0),
          ...rawList.map((p) {
            final Map data = p as Map;
            return SizedBox(
              width: (MediaQuery.of(context).size.width - 60) / 3,
              child: _presetButton(
                data['label'].toString(),
                () => _setPreset(data['h'] as int, data['m'] as int, data['s'] as int),
                isCustom: true,
                onLongPress: () {
                  List updated = List.from(rawList);
                  updated.remove(p);
                  box.put('user_presets', updated);
                  setState(() {});
                },
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _fixedPresetItem(String text, int h, int m, int s) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 60) / 3,
      child: _presetButton(text, () => _setPreset(h, m, s)),
    );
  }

  Widget _presetButton(String text, VoidCallback onTap, {bool isCustom = false, VoidCallback? onLongPress}) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          // color: isCustom ? Colors.blueGrey.withOpacity(0.1) : AppColor().primaryColor.withOpacity(0.1),
          // borderRadius: BorderRadius.circular(10),
          color: Colors.blueGrey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.blueGrey.withOpacity(0.2)),
        ),
        child: Text(text, style: TextStyle(color: Colors.blueGrey, fontFamily: 'EN-REGULAR', fontSize: context.isPhone ? 12 : 14)),
      ),
    );
  }
}
