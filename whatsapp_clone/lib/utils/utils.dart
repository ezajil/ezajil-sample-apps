import 'package:intl/intl.dart';

String formatSendingDate(int nanosecondsSinceEpoch,
    [bool timeOnly = false, bool meridiem = false]) {
  // Convert nanoseconds to microseconds since DateTime supports up to microseconds.
  int microsecondsSinceEpoch = nanosecondsSinceEpoch ~/ 1000;

  DateTime now = DateTime.now();
  DateTime date = DateTime.fromMicrosecondsSinceEpoch(microsecondsSinceEpoch);

  if (timeOnly || datesHaveSameDay(now, date)) {
    return meridiem
        ? DateFormat('hh:mm a').format(date)
        : DateFormat('HH:mm').format(date);
  }

  if (isYesterday(date)) {
    return 'Yesterday';
  }

  return DateFormat.yMd().format(date);
}

bool datesHaveSameDay(DateTime date1, DateTime date2) {
  return date1.year == date2.year &&
      date1.month == date2.month &&
      date1.day == date2.day;
}

bool isYesterday(DateTime date) {
  DateTime yesterday = DateTime.now().subtract(const Duration(days: 1));
  return date.year == yesterday.year &&
      date.month == yesterday.month &&
      date.day == yesterday.day;
}

String strFormattedSize(num size) {
  size /= 1024;

  final suffixes = ["KB", "MB", "GB", "TB"];
  String suffix = "";

  for (suffix in suffixes) {
    if (size < 1024) {
      break;
    }

    size /= 1024;
  }

  return "${size.toStringAsFixed(2)}$suffix";
}