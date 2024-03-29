import 'package:intl/intl.dart';

class TimeUtil{

  //Format example: Fri, Jul 7, 2023
  static String convertDatetimeToYMMMED(DateTime dateTime){
    return DateFormat.yMMMEd().format(dateTime);
  }

  static String convertDatetimeToReadableString(DateTime dateTime){
    return "${DateFormat.yMMMMEEEEd().format(dateTime)} ${DateFormat.Hm().format(dateTime)}";
  }

  static DateTime addDurationToDateTime(DateTime dateTime, int weeks, int days, int hours, int minutes){
    return dateTime.add(Duration(days: weeks * 7 + days, hours: hours, minutes: minutes));
  }

  static Duration getDurationFromNowTo(DateTime targetTime){
    Duration diff = targetTime.difference(DateTime.now());
    if(diff.isNegative)
      return const Duration();
    else {
      return diff;
    }
  }

}