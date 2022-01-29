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
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('QuickLook for iOS'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextButton(
                  onPressed: () async {
                    const path = 'lorem_ipsum.pdf';
                    final byteData = await rootBundle.load('assets/$path');
                    final String directory =
                        (await getApplicationDocumentsDirectory()).path;
                    final tempFile = await File('$directory/$path')
                        .writeAsBytes(byteData.buffer.asUint8List(
                            byteData.offsetInBytes, byteData.lengthInBytes));
                    await QuickLook.openURL(tempFile.path);
                  },
                  child: const Text('Open single demo PDF',
                      style: TextStyle(fontSize: 36),
                      textAlign: TextAlign.center)),
              TextButton(
                  onPressed: () async {
                    const paths = [
                      'lorem_ipsum.pdf',
                      'image1.jpg',
                      'image2.jpg'
                    ];
                    final String directory =
                        (await getApplicationDocumentsDirectory()).path;
                    var finalPaths = <String>[];
                    for (final path in paths) {
                      final byteData = await rootBundle.load('assets/$path');
                      final tempFile = await File('$directory/$path')
                          .writeAsBytes(byteData.buffer.asUint8List(
                              byteData.offsetInBytes, byteData.lengthInBytes));
                      finalPaths.add(tempFile.path);
                    }
                    await QuickLook.openURLs(finalPaths);
                  },
                  child: const Text('Open multiple assets',
                      style: TextStyle(fontSize: 36),
                      textAlign: TextAlign.center)),
              Text(
                  "Photos from \nhttps://unsplash.com/photos/QeVmJxZOv3k\nhttps://unsplash.com/photos/Yh2Y8avvPec")
            ],
          ),
        ),
      ),
    );
  }
}
