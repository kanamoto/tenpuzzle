import 'dart:core' as dartcore;
import 'package:flutter/foundation.dart';
import 'package:stack_trace/stack_trace.dart';
import 'package:intl/intl.dart'; // 日時のフォーマットに使用

class Log {

  static void print(dartcore.String message)
  {
    if (kReleaseMode == true){
      return;
    }

    // 現在の日時を取得しフォーマット
    dartcore.DateTime now = dartcore.DateTime.now();
    dartcore.String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss.SSS').format(now);

//    dartcore.List<Frame> frames = Trace.current().frames;
    Frame frame = Trace.current().frames[1];
    dartcore.String memberStr = frame.member ?? "";
    dartcore.int lineVal = frame.line ?? 0;

    dartcore.print("[$formattedDate] $memberStr:($lineVal) $message");
  }

}