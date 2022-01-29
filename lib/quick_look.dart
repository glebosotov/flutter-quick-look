import 'dart:async';

import 'package:flutter/services.dart';

class QuickLook {
  static const MethodChannel _channel = MethodChannel('quick_look');

  static Future<bool> openURL(String url) async {
    final success = await _channel.invokeMethod('openURL', url);
    return success;
  }

  static Future<bool> openURLs(List<String> urls) async {
    final success = await _channel.invokeMethod('openURLs', urls);
    return success;
  }
}
