import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/quick_look_messages.g.dart',
  dartOptions: DartOptions(),
  objcHeaderOut: 'ios/Classes/messages.g.h',
  objcSourceOut: 'ios/Classes/messages.g.m',
  objcOptions: ObjcOptions(prefix: 'QL'),
  dartPackageName: 'quick_look',
))
@HostApi()
abstract class QuickLookApi {
  /// Opens file saved at [url] in iOS QuickLook
  ///
  /// (iOS 13+) [isDismissable] configures whether QuickLook is dismissable by a swipe from top to bottom
  ///
  /// The file should be saved at the ApplicationDocumentsDirectory (check out the example at https://pub.dev/packages/quick_look/example)
  @async
  bool openURL(
    String url, {
    bool isDismissable = true,
  });

  /// Opens files saved at [resourceURLs] in iOS QuickLook (user can swipe between them)
  ///
  /// Sets the current item in view to [initialIndex]
  /// (iOS 13+) [isDismissable] configures whether QuickLook is dismissable by a swipe from top to bottom
  ///
  /// The files should be saved at the ApplicationDocumentsDirectory (check out the example at https://pub.dev/packages/quick_look/example)
  @async
  bool openURLs({
    required List<String> resourceURLs,
    int initialIndex = 0,
    bool isDismissable = true,
  });
}
