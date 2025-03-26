import 'dart:io';

class AdHelper {

  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111'; // TEST
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/6300978111'; // TEST
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
}