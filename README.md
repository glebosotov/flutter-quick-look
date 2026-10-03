# quick_look

Preview local files with Apple's native iOS Quick Look (`QLPreviewController`).
Supports single files, a swipeable collection, capability checks, and control over
swipe dismissal.

## Requirements

- Flutter **3.44+** and Dart **3.12+**.
- iOS **13+**, or the higher minimum required by your Flutter SDK. The example
  targets iOS 15 to match Flutter 3.47.
- **Swift Package Manager enabled. CocoaPods is no longer supported as of 0.3.0.**
- iOS only; calls on other platforms fail with a platform channel error.

## Migrating from CocoaPods

Flutter 3.44+ enables SwiftPM by default. If your app previously disabled it,
set this in the app's `pubspec.yaml`, then rebuild:

```yaml
flutter:
  config:
    enable-swift-package-manager: true
```

Flutter can still use CocoaPods for other plugins that require it. Once all your
app's plugins support SwiftPM, follow Flutter's
[CocoaPods removal guide](https://docs.flutter.dev/packages-and-plugins/swift-package-manager/for-app-developers#how-to-remove-cocoapods-integration)
to remove the app's remaining integration.

## Usage

Pass an **absolute local file path**, not a `file://` URL or an HTTP URL. Files can
live in documents, cache, or temporary storage; keep them readable until the
preview closes. Download remote files before previewing them.

```dart
import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:quick_look/quick_look.dart';

Future<void> previewAsset() async {
  final data = await rootBundle.load('assets/document.pdf');
  final directory = Directory.systemTemp;
  final file = await File('${directory.path}/document.pdf').writeAsBytes(
    data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
  );

  if (await QuickLook.canOpenURL(file.path)) {
    final dismissed = await QuickLook.openURL(file.path);
    // true after the preview closes, false if presentation was refused.
    print('Preview dismissed: $dismissed');
  }
}
```

To preview a collection:

```dart
final dismissed = await QuickLook.openURLs(
  resourceURLs: [pdfPath, imagePath],
  initialIndex: 1,
  isDismissable: false,
);
```

`isDismissable: false` disables the downward swipe gesture. The native Done button
remains available. Both open methods complete after the preview is dismissed.
They return `false` for invalid paths, missing/unreadable/unsupported files, an
empty list, an out-of-range index, a concurrent preview, or an unavailable active
presenter. Engine teardown also completes a pending preview with `false`.
Platform channel errors are propagated.

Supported file types and rendering depend on the iOS version and file contents;
`canOpenURL` checks file accessibility and Quick Look's capability, not whether the
file is uncorrupted. See [Apple's Quick Look documentation](https://developer.apple.com/documentation/quicklook/qlpreviewcontroller).
