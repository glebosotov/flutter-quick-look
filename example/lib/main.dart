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
          child: TextButton(
              onPressed: () async {
                const path = 'lorem_ipsum.pdf';
                final byteData = await rootBundle.load('assets/$path');
                final String directory =
                    (await getApplicationDocumentsDirectory()).path;
                final tempFile = await File('$directory/$path').writeAsBytes(
                    byteData.buffer.asUint8List(
                        byteData.offsetInBytes, byteData.lengthInBytes));
                await QuickLook.openURL(tempFile.path);
              },
              child:
                  const Text('Open demo PDF', style: TextStyle(fontSize: 40))),
        ),
      ),
    );
  }
}
