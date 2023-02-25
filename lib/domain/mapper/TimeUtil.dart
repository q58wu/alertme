import 'package:intl/intl.dart';

class TimeUtil{

  //Format example: Fri, Jul 7, 2023
  static String convertDatetimeToYMMMED(DateTime dateTime){
    return DateFormat.yMMMEd().format(dateTime);
  }

  static String convertDatetimeToReadableString(DateTime dateTime){
    return DateFormat.yMMMMEEEEd().format(dateTime);
  }

}