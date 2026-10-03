import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/quick_look_messages.g.dart',
    dartOptions: DartOptions(),
    swiftOut: 'ios/quick_look/Sources/quick_look/messages.g.swift',
    swiftOptions: SwiftOptions(),
    dartPackageName: 'quick_look',
  ),
)
@HostApi()
abstract class QuickLookApi {
  /// Opens file saved at [url] in iOS QuickLook
  ///
  /// (iOS 13+) [isDismissable] configures whether QuickLook is dismissable
  /// by a swipe from top to bottom
  ///
  /// Pass an absolute local file path, not a URL string.
  @async
  bool openURL(String url, {bool isDismissable = true});

  /// Opens files saved at [resourceURLs] in iOS QuickLook
  /// (user can swipe between them)
  ///
  /// Sets the current item in view to [initialIndex]
  /// (iOS 13+) [isDismissable] configures whether QuickLook is dismissable
  /// by a swipe from top to bottom
  ///
  /// Pass absolute local file paths, not URL strings.
  @async
  bool openURLs({
    required List<String> resourceURLs,
    int initialIndex = 0,
    bool isDismissable = true,
  });

  /// Returns whether iOS QuickLook
  /// supports the saved at [url] file type (and can preview it) or not
  ///
  /// The list of supported file types varies depending on iOS version
  @async
  bool canOpenURL(String url);
}
