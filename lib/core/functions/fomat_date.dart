import 'package:get/get.dart';
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

String formatDateForLocale(String dateString) {
  final String lang = Get.locale?.languageCode ?? 'km';
  final String localeString = lang == 'km' ? 'km_KH' : 'en_US';

  final DateTime date = DateFormat('dd/MM/yyyy HH:mm').parse(dateString);

  return DateFormat('d MMM yyyy', localeString).format(date);
}

DateTime parseNoteDate(String dateString) {
  return DateFormat('dd/MM/yyyy HH:mm').parse(dateString);
}

String toKhmerNumerals(String input) {
  const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  const khmer = ['០', '១', '២', '៣', '៤', '៥', '៦', '៧', '៨', '៩'];
  String output = input;
  for (int i = 0; i < english.length; i++) {
    output = output.replaceAll(english[i], khmer[i]);
  }
  return output;
}

String getDateHeader(String dateStr) {
  try {
    DateTime noteDate = DateFormat('dd/MM/yyyy').parse(dateStr);
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime yesterday = today.subtract(const Duration(days: 1));
    DateTime noteDateMidnight = DateTime(noteDate.year, noteDate.month, noteDate.day);

    if (noteDateMidnight.isAtSameMomentAs(today)) {
      return 'today'.tr;
    } else if (noteDateMidnight.isAtSameMomentAs(yesterday)) {
      return 'yesterday'.tr;
    } else if (noteDate.year == now.year) {
      return DateFormat('MMMM d', Get.locale.toString()).format(noteDate);
    } else {
      return DateFormat('MMMM d, y', Get.locale.toString()).format(noteDate);
    }
  } catch (e) {
    return 'earlier'.tr;
  }
}
