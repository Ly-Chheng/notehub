import 'package:intl/intl.dart';

class FormateDate {
  static String formatDateTime(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    String formatDate = DateFormat('EEE,dd-MM-yyyy', 'en_US').format(dateTime);
    return formatDate;
  }

  static today() {
    var today = DateTime.now();
    return today;
  }

  static tomorrow() {
    var now = DateTime.now();
    var tomorrow = DateTime(now.year, now.month, now.day + 1);
    return tomorrow;
  }

  static nextWeek() {
    var now = DateTime.now();
    var nextWeek = now.add(const Duration(days: 7));
    return nextWeek;
  }

  static nextMonth() {
    var now = DateTime.now();
    var nextMonth = DateTime(now.year, now.month + 1, now.day);
    return nextMonth;
  }

  String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  static String? formatAccountNumber(value) {
    var bufferString = StringBuffer();
    for (int i = 0; i < value.length; i++) {
      bufferString.write(value[i]);
      var nonZeroIndexValue = i + 1;
      if (nonZeroIndexValue % 3 == 0 && nonZeroIndexValue != value.length) {
        bufferString.write('');
      }
    }
    return bufferString.toString();
  }
}
