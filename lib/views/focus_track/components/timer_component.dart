import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_structure/core/utils/app_color.dart';
import 'package:project_structure/widgets/custom_appbar.dart';

class CreateTimerScreen extends StatefulWidget {
  const CreateTimerScreen({super.key});

  @override
  State<CreateTimerScreen> createState() => _CreateTimerScreenState();
}

class _CreateTimerScreenState extends State<CreateTimerScreen> {
  int selectedHours = 1;
  int selectedMinutes = 2;
  int selectedSeconds = 21;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: customAppBar(
        title: "Back",
        titleColor: AppColor().primaryColor,
        context: context,
        leadingColor: AppColor().primaryColor,
        actions: [
          TextButton(
            onPressed: () {},
            child: Text("Save",
                style: TextStyle(
                  color: AppColor().primaryColor,
                  fontSize: context.isPhone ? 16 : 20,
                  fontFamily: 'EN-SEMIBOLD',
                )),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildToggleHeader(),
              const Spacer(),
              _buildTimePickerSection(),
              const Spacer(),
              _buildLabelField(),
              const Spacer(),
              _buildStartButton(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleHeader() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EBF6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Center(child: Text("Stopwatch", style: TextStyle(color: Colors.black54))),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
              child: const Center(child: Text("Timer", style: TextStyle(fontWeight: FontWeight.w600))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimePickerSection() {
    return SizedBox(
      height: 250,
      child: Row(
        children: [
          _buildPickerColumn(24, "hours", (val) => setState(() => selectedHours = val), selectedHours),
          _buildPickerColumn(60, "min", (val) => setState(() => selectedMinutes = val), selectedMinutes),
          _buildPickerColumn(60, "sec", (val) => setState(() => selectedSeconds = val), selectedSeconds),
        ],
      ),
    );
  }

  Widget _buildPickerColumn(int count, String unit, ValueChanged<int> onChanged, int initial) {
    return Expanded(
      child: CupertinoPicker(
        scrollController: FixedExtentScrollController(initialItem: initial),
        itemExtent: 50,
        onSelectedItemChanged: onChanged,
        selectionOverlay: const CupertinoPickerDefaultSelectionOverlay(capStartEdge: false, capEndEdge: false),
        children: List.generate(count, (index) {
          return Center(
            child: Text(
              "$index $unit",
              style: const TextStyle(fontSize: 22, color: Colors.black87),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildLabelField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EBF6).withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Label", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500)),
          Text("Timer", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildStartButton() {
    return Container(
      width: 80,
      height: 80,
      decoration: const BoxDecoration(
        color: Color(0xFF4D7CFF),
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Color(0x4D4D7CFF), blurRadius: 20, offset: Offset(0, 10))],
      ),
      child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 50),
    );
  }
}
