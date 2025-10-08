import 'package:flutter/foundation.dart';
import 'dart:io';

class AdHelper {
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return kReleaseMode
          ? 'ca-app-pub-xxxxxxxxxxxxxxxx/android-real-banner'
          : 'ca-app-pub-3940256099942544/6300978111'; // Android 테스트 ID
    } else if (Platform.isIOS) {
      return kReleaseMode
          ? 'ca-app-pub-2770838096726003/6279101025'
          : 'ca-app-pub-3940256099942544/2934735716'; // iOS 테스트 ID
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
}
