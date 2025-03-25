import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:quick_look/quick_look.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Timer? _timer;
  bool? _canOpenFileType;
  int secondsPassedSinceLastOpen = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: Scaffold(
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
                  onPressed: () async {
                    const path = 'lorem_ipsum.pdf';
                    final byteData = await rootBundle.load('assets/$path');
                    final String directory =
                        (await getApplicationDocumentsDirectory()).path;
                    final tempFile = await File('$directory/$path')
                        .writeAsBytes(byteData.buffer.asUint8List(
                            byteData.offsetInBytes, byteData.lengthInBytes));
                    final bool canOpenUrl =
                        await QuickLook.canOpenURL(tempFile.path);
                    setState(() {
                      _canOpenFileType = canOpenUrl;
                    });
                  },
                  child: const Text('Check if can open .pdf',
                      style: TextStyle(fontSize: 24),
                      textAlign: TextAlign.center),
                ),
                const SizedBox(height: 12),
                Text(
                  'Can open filetype: $_canOpenFileType',
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    const path = 'lorem_ipsum.pdf';
                    final byteData = await rootBundle.load('assets/$path');
                    setState(() {
                      secondsPassedSinceLastOpen = 0;
                    });
                    _timer =
                        Timer.periodic(const Duration(seconds: 1), (timer) {
                      setState(() {
                        secondsPassedSinceLastOpen++;
                      });
                    });
                    final String directory =
                        (await getApplicationDocumentsDirectory()).path;
                    final tempFile = await File('$directory/$path')
                        .writeAsBytes(byteData.buffer.asUint8List(
                            byteData.offsetInBytes, byteData.lengthInBytes));
                    await QuickLook.openURL(tempFile.path);
                    _timer?.cancel();
                  },
                  child: const Text('Open single demo PDF',
                      style: TextStyle(fontSize: 24),
                      textAlign: TextAlign.center),
                ),
                ElevatedButton(
                  onPressed: () async {
                    const paths = [
                      'lorem_ipsum.pdf',
                      'image1.jpg',
                      'image2.jpg'
                    ];
                    final String directory =
                        (await getApplicationDocumentsDirectory()).path;
                    var finalPaths = <String>[];
                    setState(() {
                      secondsPassedSinceLastOpen = 0;
                    });
                    _timer =
                        Timer.periodic(const Duration(seconds: 1), (timer) {
                      setState(() {
                        secondsPassedSinceLastOpen++;
                      });
                    });
                    for (final path in paths) {
                      final byteData = await rootBundle.load('assets/$path');
                      final tempFile = await File('$directory/$path')
                          .writeAsBytes(byteData.buffer.asUint8List(
                              byteData.offsetInBytes, byteData.lengthInBytes));
                      finalPaths.add(tempFile.path);
                    }
                    await QuickLook.openURLs(
                      resourceURLs: finalPaths,
                      initialIndex: finalPaths.length - 1,
                      isDismissable: false,
                    );
                    _timer?.cancel();
                  },
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
      ),
    );
  }
}
