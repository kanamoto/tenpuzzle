import 'dart:core' as dartcore;
import 'package:stack_trace/stack_trace.dart';

class Log {

  static void print(dartcore.String message)
  {
//    dartcore.List<Frame> frames = Trace.current().frames;
    Frame frame = Trace.current().frames[1];
    dartcore.String memberStr = frame.member ?? "";
    dartcore.int lineVal = frame.line ?? 0;

    dartcore.print("$memberStr:($lineVal) $message");
  }

}