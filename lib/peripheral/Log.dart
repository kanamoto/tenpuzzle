import 'dart:core' as dartcore;
import 'package:flutter/foundation.dart';
import 'package:stack_trace/stack_trace.dart';

class Log {

  static void print(dartcore.String message)
  {
    if (kReleaseMode == true){
      return;
    }
//    dartcore.List<Frame> frames = Trace.current().frames;
    Frame frame = Trace.current().frames[1];
    dartcore.String memberStr = frame.member ?? "";
    dartcore.int lineVal = frame.line ?? 0;

    dartcore.print("$memberStr:($lineVal) $message");
  }

}