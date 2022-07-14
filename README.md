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
final String directory =
    (await getApplicationDocumentsDirectory()).path;
final tempFile = await File('$directory/$path').writeAsBytes(
    byteData.buffer.asUint8List(
        byteData.offsetInBytes, byteData.lengthInBytes));
await QuickLook.openURL(tempFile.path);
```

### To see, which kind of files you can open, see [Apple Documentation](https://developer.apple.com/documentation/quicklook)
