import 'package:intl/intl.dart';

class DateUtils {
  static DateTime truncate(DateTime dateTime) => new DateTime(dateTime.year, dateTime.month, dateTime.day);

  static String formatDate(DateTime date, String pattern) => DateFormat(pattern, Intl.getCurrentLocale()).format(date);

  static String friendlyFormatDate(DateTime date) {
    if (isToday(date)) {
      return 'Today';
    } else if (isTomorrow(date)) {
      return 'Tomorrow';
    } else if (isNextWeek(date)) {
      return 'Next week';
    } else {
      int days = daysFromNow(date);
      if (days > 0 && days < 7) {
        return "In $days days";
      }
    }
    return formatDate(date, 'yMd');
  }

  static bool isToday(DateTime date) => date != null && daysFromNow(date) == 0;

  static bool isTomorrow(DateTime date) => date != null && daysFromNow(date) == 1;

  static bool isNextWeek(DateTime date) => date != null && daysFromNow(date) == 7;

  static int daysFromNow(DateTime date) => DateUtils.truncate(date).difference(DateUtils.truncate(DateTime.now())).inDays;
}
