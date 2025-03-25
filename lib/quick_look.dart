import 'dart:async';

import 'package:quick_look/quick_look_messages.g.dart';

class QuickLook {
  static final QuickLookApi _api = QuickLookApi();

  /// Opens file saved at [url] in iOS QuickLook
  ///
  /// (iOS 13+) [isDismissable] configures whether QuickLook is dismissable by a swipe from top to bottom
  ///
  /// The file should be saved at the ApplicationDocumentsDirectory (check out the example at https://pub.dev/packages/quick_look/example)
  static Future<bool> openURL(
    String url, {
    bool isDismissable = true,
  }) async {
    return _api.openURL(url, isDismissable: isDismissable);
  }

  /// Opens files saved at [resourceURLs] in iOS QuickLook (user can swipe between them)
  ///
  /// Sets the current item in view to [initialIndex]
  /// (iOS 13+) [isDismissable] configures whether QuickLook is dismissable by a swipe from top to bottom
  ///
  /// The files should be saved at the ApplicationDocumentsDirectory (check out the example at https://pub.dev/packages/quick_look/example)
  static Future<bool> openURLs({
    required List<String> resourceURLs,
    int initialIndex = 0,
    bool isDismissable = true,
  }) async {
    return _api.openURLs(
      resourceURLs: resourceURLs,
      initialIndex: initialIndex,
      isDismissable: isDismissable,
    );
  }

  /// Returns whether iOS QuickLook supports the saved at [url] file type (and can preview it) or not
  ///
  /// The list of supported file types varies depending on iOS version
  static Future<bool> canOpenURL(String url) {
    return _api.canOpenURL(url);
  }
}
