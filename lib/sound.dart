import 'dart:async' show Future;
//import 'package:audioplayer/audioplayer.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;



///
/// @param filepath  sounds/xxxxx.mp3
///
Future<ByteData> loadAsset(String filepath) async {
  return await rootBundle.load(filepath);
}

// // FIXME: This code is not working.
// Future<void> playLocal( String filepath  ) async {
//
// //  AudioPlayer audioPlugin = AudioPlayer();
//
//   //ByteData byteData = await loadAsset(filepath);
//
// //    final file = new File('${(await getTemporaryDirectory()).path}/music.mp3');
// //   await file.writeAsBytes((await loadAsset()).buffer.asUint8List());
//  // await audioPlugin.play(filepath, isLocal: true);
// }