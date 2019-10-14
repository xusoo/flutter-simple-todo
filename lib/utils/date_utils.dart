import 'package:intl/intl.dart';

class DateUtils {
  static DateTime truncate(DateTime dateTime) => new DateTime(dateTime.year, dateTime.month, dateTime.day);

  static String formatDate(DateTime date, String pattern) => DateFormat(pattern, Intl.getCurrentLocale()).format(date);

  static String friendlyFormatDate(DateTime date) {
    if (isTomorrow(date)) {
      return 'Tomorrow';
    } else if (isNextWeek(date)) {
      return 'Next week';
    } else {
      var days = daysFromNow(date);
      if (days < 7) {
        return "In $days days";
      }
    }
    return formatDate(date, 'yMd');
  }

  static bool isTomorrow(DateTime date) => date != null && daysFromNow(date) == 1;

  static bool isNextWeek(DateTime date) => date != null && daysFromNow(date) == 7;

  static int daysFromNow(DateTime date) => DateUtils.truncate(date).difference(DateUtils.truncate(DateTime.now())).inDays;
}
