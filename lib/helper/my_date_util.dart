import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyDateUtil{
  static String getFormattedTime({required BuildContext context,required String time }){
    final date = DateTime.fromMillisecondsSinceEpoch(int.parse(time));

    return TimeOfDay.fromDateTime(date).format(context);
  }
  static String getLastMessageTime({required BuildContext context,required String time }){
    final DateTime sent = DateTime.fromMicrosecondsSinceEpoch(int.parse(time));
    final DateTime now = DateTime.now();
    if(now.day==sent.day&&now.month==sent.month&&now.year==sent.year){
      return TimeOfDay.fromDateTime(sent).format(context);
    }
    return '${sent.day} ${_getMonth(sent)}';
  }
  // String _getMonth(DateTime date){
  //
  // }
  // get month name from month no. or index
  static String _getMonth(DateTime date) {
    switch (date.month) {
      case 1:
        return 'Tháng 1';
      case 2:
        return 'Tháng 2';
      case 3:
        return 'Tháng 3';
      case 4:
        return 'Tháng 4';
      case 5:
        return 'Tháng 5';
      case 6:
        return 'Tháng 6';
      case 7:
        return 'Tháng 7';
      case 8:
        return 'Tháng 8';
      case 9:
        return 'Tháng 9';
      case 10:
        return 'Tháng 10';
      case 11:
        return 'Tháng 11';
      case 12:
        return 'Tháng 12';
    }
    return 'NA';
  }
}