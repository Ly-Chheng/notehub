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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: customAppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                  fontSize: context.isPhone ? 20 : 22,
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
              const Spacer(),
              _buildTimePickerSection(),
              const Spacer(),
              _buildLabelField(),
              SizedBox(
                height: 20,
              ),
              _buildQuickTimerRow(),
              const Spacer(),
              _buildStartButton(),
              const SizedBox(height: 30),
            ],
          ),
        ),
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
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            decoration: InputDecoration(
              labelText: "Label",
              hintStyle: const TextStyle(
                color: Colors.black54,
                fontFamily: 'EN-REGULAR',
              ),
              filled: true,
              fillColor: const Color(0xFFE8EBF6).withOpacity(0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextFormField(
            decoration: InputDecoration(
              hintText: "Timer",
              hintStyle: const TextStyle(
                color: Colors.black54,
                fontFamily: 'EN-REGULAR',
              ),
              filled: true,
              fillColor: const Color(0xFFE8EBF6).withOpacity(0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      ],
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
      child: Icon(Icons.play_arrow_rounded, color: Theme.of(context).cardColor, size: 50),
    );
  }

  Widget _buildQuickTimerRow() {
    final presets = [1, 5, 10, 15, 30];

    return SizedBox(
      height: 45,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: presets.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final minute = presets[index];

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedHours = 0;
                selectedMinutes = minute;
                selectedSeconds = 0;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFE8EBF6).withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "$minute MIN",
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
