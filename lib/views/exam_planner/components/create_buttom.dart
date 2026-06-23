 // bottomNavigationBar: Padding(
      //   padding: const EdgeInsets.all(16.0),
      //   child: Padding(
      //     padding: const EdgeInsets.all(16.0),
      //     child: CustomButton(
      //       text: "add_exam".tr,
      //       onPressed: () {
      //         showModalBottomSheet(
      //           context: context,
      //           isScrollControlled: true,
      //           backgroundColor: Colors.white,
      //           shape: const RoundedRectangleBorder(
      //             borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      //           ),
      //           builder: (BuildContext context) {
      //             final titleController = TextEditingController();
      //             final locationController = TextEditingController();
      //             DateTime selectedDate = DateTime.now();
      //             TimeOfDay selectedTime = TimeOfDay.now();
      //             String reminderStr = '1 day before at 9:00 AM';

      //             return StatefulBuilder(
      //               builder: (BuildContext context, StateSetter setModalState) {
      //                 return Padding(
      //                   padding: EdgeInsets.only(
      //                     bottom: MediaQuery.of(context).viewInsets.bottom,
      //                     left: 20,
      //                     right: 20,
      //                     top: 20,
      //                   ),
      //                   child: SingleChildScrollView(
      //                     child: Column(
      //                       mainAxisSize: MainAxisSize.min,
      //                       crossAxisAlignment: CrossAxisAlignment.start,
      //                       children: [
      //                         Center(
      //                           child: Text(
      //                             "add_exam".tr,
      //                             style: text18(context),
      //                           ),
      //                         ),
      //                         const SizedBox(height: 20),
      //                         customTextField(
      //                           "exam_title".tr,
      //                           false,
      //                           null,
      //                           controller: titleController,
      //                         ),
      //                         const SizedBox(height: 16),
      //                         customTextField(
      //                           "location".tr,
      //                           false,
      //                           null,
      //                           controller: locationController,
      //                         ),
      //                         const SizedBox(height: 16),
      //                         Row(
      //                           children: [
      //                             Expanded(
      //                               child: ListTile(
      //                                 contentPadding: EdgeInsets.zero,
      //                                 subtitle: Container(
      //                                   padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      //                                   decoration: BoxDecoration(
      //                                     color: Colors.grey.withValues(alpha: 0.1),
      //                                     borderRadius: BorderRadius.circular(8.0),
      //                                   ),
      //                                   child: Row(
      //                                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //                                     children: [
      //                                       Text("${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}", style: text16(context)),
      //                                       Icon(
      //                                         Icons.calendar_today,
      //                                         color: AppColor().primaryColor,
      //                                         size: 20,
      //                                       ),
      //                                     ],
      //                                   ),
      //                                 ),
      //                                 onTap: () async {
      //                                   final DateTime? picked = await showDatePicker(
      //                                     context: context,
      //                                     initialDate: selectedDate,
      //                                     firstDate: DateTime.now(),
      //                                     lastDate: DateTime(2030),
      //                                   );
      //                                   if (picked != null) setModalState(() => selectedDate = picked);
      //                                 },
      //                               ),
      //                             ),
      //                             SizedBox(
      //                               width: 10,
      //                             ),
      //                             Expanded(
      //                               child: ListTile(
      //                                 contentPadding: EdgeInsets.zero,
      //                                 subtitle: Container(
      //                                     padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      //                                     decoration: BoxDecoration(
      //                                       color: Colors.grey.withValues(alpha: 0.1),
      //                                       borderRadius: BorderRadius.circular(8.0),
      //                                     ),
      //                                     child: Row(
      //                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //                                       children: [
      //                                         Text(selectedTime.format(context), style: text16(context)),
      //                                         Icon(
      //                                           Icons.access_time,
      //                                           color: AppColor().primaryColor,
      //                                           size: 24,
      //                                         ),
      //                                       ],
      //                                     )),
      //                                 onTap: () async {
      //                                   final TimeOfDay? picked = await showTimePicker(
      //                                     context: context,
      //                                     initialTime: selectedTime,
      //                                   );
      //                                   if (picked != null) setModalState(() => selectedTime = picked);
      //                                 },
      //                               ),
      //                             ),
      //                           ],
      //                         ),
      //                         const SizedBox(height: 16),
      //                         Container(
      //                           padding: const EdgeInsets.symmetric(horizontal: 16.0),
      //                           decoration: BoxDecoration(
      //                             color: Colors.grey.withValues(alpha: 0.1),
      //                             borderRadius: BorderRadius.circular(8.0),
      //                           ),
      //                           child: DropdownButton<String>(
      //                             value: reminderStr,
      //                             isExpanded: true,
      //                             underline: const SizedBox(),
      //                             items: ['10 minutes before', '1 hour before', '1 day before at 9:00 AM', '2 days before']
      //                                 .map((val) => DropdownMenuItem(
      //                                     value: val,
      //                                     child: Text(
      //                                       val,
      //                                       style: text16(context),
      //                                     )))
      //                                 .toList(),
      //                             onChanged: (val) => setModalState(() => reminderStr = val!),
      //                           ),
      //                         ),
      //                         const SizedBox(height: 24),
      //                         CustomButton(
      //                           text: "save".tr,
      //                           onPressed: () async {
      //                             if (titleController.text.isNotEmpty) {
      //                               final dateString = "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";
      //                               final timeString = selectedTime.format(context);

      //                               await _controller.createExam(Exam(
      //                                 title: titleController.text,
      //                                 date: dateString,
      //                                 time: timeString,
      //                                 location: locationController.text.isEmpty ? "Not Specified" : locationController.text,
      //                                 reminderTime: reminderStr,
      //                                 isCompleted: false,
      //                               ));

      //                               Get.back();
      //                               setState(() {});
      //                             } else {
      //                               Get.back();
      //                               AppSnackbar.showError(
      //                                 title: "error".tr,
      //                                 message: "please_provide_exam_title".tr,
      //                               );
      //                             }
      //                           },
      //                         ),
      //                         const SizedBox(height: 20),
      //                       ],
      //                     ),
      //                   ),
      //                 );
      //               },
      //             );
      //           },
      //         );
      //       },
      //     ),
      //   ),
      // ),