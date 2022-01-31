import 'dart:async';

import 'package:flutter/services.dart';

class QuickLook {
  static const MethodChannel _channel = MethodChannel('quick_look');

  /// Opens file saved at [url] in iOS QuickLook
  ///
  /// The file should be saved at the ApplicationDocumentsDirectory (check out the example at https://pub.dev/packages/quick_look/example)
  static Future<bool> openURL(String url) async {
    final success = await _channel.invokeMethod('openURL', url);
    return success;
  }

  /// Opens files saved at [urls] in iOS QuickLook (user can swipe between them)
  ///
  /// The files should be saved at the ApplicationDocumentsDirectory (check out the example at https://pub.dev/packages/quick_look/example)
  static Future<bool> openURLs(List<String> urls) async {
    final success = await _channel.invokeMethod('openURLs', urls);
    return success;
  }
}
