# quick_look

This plugin lets us use Apple QuickLook (`QLPreviewController`).

## Getting Started

### In order to open the file, do the following

```dart
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:quick_look/quick_look.dart';

...

final byteData = await rootBundle.load('assets/$path');
final directory = await getApplicationDocumentsDirectory();
final String directoryPath = directory.path;
final tempFile = await File('$directory/$directoryPath').writeAsBytes(
        byteData.buffer.asUint8List(
        byteData.offsetInBytes,
        byteData.lengthInBytes,
    ),
);
final bool canOpenUrl = await QuickLook.canOpenURL(tempFile.path);
if (canOpenUrl) {
    await QuickLook.openURL(tempFile.path, isDismissable: true);
}
```

### Features

- Open a single file using QuickLook
- Open multiple files in a carousel using QuickLook
- Check if a file can be opened before passing it to the QLPreviewController
- Control whether QuickLook preview can be closed with a swipe

### To see, which kind of files you can open, see [Apple Documentation](https://developer.apple.com/documentation/quicklook)
