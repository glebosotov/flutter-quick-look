import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:quick_look/quick_look.dart';

void main() {
  runApp(const _App());
}

class _App extends StatelessWidget {
  const _App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
        ),
        home: const _Screen(),
      );
}

class _Screen extends StatefulWidget {
  const _Screen({Key? key}) : super(key: key);

  @override
  State<_Screen> createState() => _ScreenState();
}

class _ScreenState extends State<_Screen> {
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Timer? _timer;
  bool? _canOpenFileType;
  int secondsPassedSinceLastOpen = 0;
  bool isDismissable = false;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('QuickLook for iOS'),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                ElevatedButton(
                  onPressed: () => _openAssetsFile(path: 'lorem_ipsum.pdf'),
                  child: const Text(
                    'Open single demo PDF',
                    style: TextStyle(fontSize: 24),
                    textAlign: TextAlign.center,
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _openAssetsFile(path: 'example_1mb.rar'),
                  child: const Text(
                    'Try to open single demo RAR',
                    style: TextStyle(fontSize: 24),
                    textAlign: TextAlign.center,
                  ),
                ),
                ElevatedButton(
                  onPressed: _openImages,
                  child: const Text(
                    'Open multiple assets',
                    style: TextStyle(fontSize: 24),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Seconds since last open: $secondsPassedSinceLastOpen',
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const Text(
                  '(method awaits native modal close before resolving future)',
                  style: TextStyle(fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Can open file: $_canOpenFileType',
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Text('isDismissable'),
                  trailing: Switch(
                    value: isDismissable,
                    onChanged: _toggleDismissable,
                  ),
                ),
                const Spacer(),
                const Text(
                  'Photos from \nhttps://unsplash.com/photos/QeVmJxZOv3k\nhttps://unsplash.com/photos/Yh2Y8avvPec',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      );

  Future<void> _openAssetsFile({required String path}) async {
    final byteData = await rootBundle.load('assets/$path');
    _resetTimer();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _incrementTimer();
    });
    final directory = await getApplicationDocumentsDirectory();
    final directoryPath = directory.path;
    final tempFile = await File('$directoryPath/$path').writeAsBytes(
      byteData.buffer.asUint8List(
        byteData.offsetInBytes,
        byteData.lengthInBytes,
      ),
    );

    final canOpenUrl = await QuickLook.canOpenURL(tempFile.path);
    setState(() {
      _canOpenFileType = canOpenUrl;
    });
    if (canOpenUrl) {
      await QuickLook.openURL(
        tempFile.path,
        isDismissable: isDismissable,
      );
    }
    _resetTimer();
    _timer?.cancel();
  }

  Future<void> _openImages() async {
    const paths = ['lorem_ipsum.pdf', 'image1.jpg', 'image2.jpg'];
    final directory = await getApplicationDocumentsDirectory();
    final directoryPath = directory.path;
    final finalPaths = <String>[];
    _resetTimer();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _incrementTimer();
    });
    for (final path in paths) {
      final byteData = await rootBundle.load('assets/$path');
      final tempFile = await File(
        '$directoryPath/$path',
      ).writeAsBytes(
        byteData.buffer.asUint8List(
          byteData.offsetInBytes,
          byteData.lengthInBytes,
        ),
      );
      finalPaths.add(tempFile.path);
    }
    await QuickLook.openURLs(
      resourceURLs: finalPaths,
      initialIndex: finalPaths.length - 1,
      isDismissable: isDismissable,
    );
    _resetTimer();
    _timer?.cancel();
  }

  void _toggleDismissable(bool newValue) => setState(
        () => isDismissable = newValue,
      );

  void _resetTimer() => setState(() {
        secondsPassedSinceLastOpen = 0;
      });

  void _incrementTimer() => setState(() {
        secondsPassedSinceLastOpen++;
      });
}
