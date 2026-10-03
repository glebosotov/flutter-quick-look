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

## Development

Validated toolchain: Flutter **3.47.6**, Dart **3.13.5**, Pigeon **29.0.6**, and
Flutter lints **6.0.0** (maintenance review: October 2026).

```sh
flutter pub get
make pigeon  # regenerate both sides of the bridge using the pinned Pigeon version
make check   # formatting, analysis, Dart regression tests
cd example
flutter run
```

The example adopts Flutter's `UIScene` lifecycle. The plugin presents from the
view controller associated with its Flutter registrar, so it stays in the calling
engine's scene. `QLPreviewController` remains the modal preview API; Apple's
`QLPreviewSceneActivationConfiguration` is intended for separate preview windows
and does not replace this API's dismissal contract.

Flutter 3.47's SwiftPM example migration can report an identity mismatch when the
checkout directory differs from the package name. For native development, clone
into a directory named `quick_look`:

```sh
git clone https://github.com/glebosotov/flutter-quick-look.git quick_look
```

CI uses that directory name, tests the minimum and current Flutter versions, and
builds and runs native tests with SwiftPM. No CocoaPods installation is needed.

After building the example, run the native tests on an installed simulator:

```sh
xcodebuild test -workspace ios/Runner.xcworkspace -scheme Runner \
  -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 17' \
  -parallel-testing-enabled NO \
  -clonedSourcePackagesDirPath "$PWD/build/ios/SourcePackages" \
  BUILD_DIR="$PWD/build/ios" CODE_SIGNING_ALLOWED=NO
```

Before release, also check Done and swipe dismissal, cancelled swipes, the share
sheet, multiple previews and scene selection on an iPhone and iPad.

Migration references: [Flutter UIScene adoption](https://docs.flutter.dev/release/breaking-changes/uiscenedelegate),
[SwiftPM for plugin authors](https://docs.flutter.dev/packages-and-plugins/swift-package-manager/for-plugin-authors),
and [Flutter 3.47 release notes](https://docs.flutter.dev/release/release-notes/release-notes-3.47.0).
