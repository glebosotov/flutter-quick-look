import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:quick_look/quick_look.dart';

void main() => runApp(const _App());

class _App extends StatelessWidget {
  const _App();

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(colorSchemeSeed: Colors.indigo),
    home: const _Screen(),
  );
}

class _Screen extends StatefulWidget {
  const _Screen();

  @override
  State<_Screen> createState() => _ScreenState();
}

class _ScreenState extends State<_Screen> {
  bool _busy = false;
  bool _isDismissable = true;
  String _status = 'Choose a file to preview.';

  Future<void> _preview(List<String> assets, {int initialIndex = 0}) async {
    setState(() {
      _busy = true;
      _status = 'Preparing files…';
    });
    try {
      final directory = Directory.systemTemp;
      final paths = <String>[];
      for (final asset in assets) {
        final data = await rootBundle.load('assets/$asset');
        // Exercise spaces, Unicode and reserved URL characters in real paths.
        final file = File('${directory.path}/Пример #100% $asset');
        await file.writeAsBytes(
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
        );
        paths.add(file.path);
      }
      if (!mounted) return;
      final canOpen = await QuickLook.canOpenURL(paths[initialIndex]);
      if (!mounted) return;
      if (!canOpen) {
        setState(() => _status = 'Quick Look cannot preview this file.');
        return;
      }
      setState(() => _status = 'Waiting for the native preview to close…');
      final opened = paths.length == 1
          ? await QuickLook.openURL(paths.single, isDismissable: _isDismissable)
          : await QuickLook.openURLs(
              resourceURLs: paths,
              initialIndex: initialIndex,
              isDismissable: _isDismissable,
            );
      if (!mounted) return;
      setState(
        () => _status = opened
            ? 'Preview closed; the future completed.'
            : 'Preview could not be presented.',
      );
    } catch (error) {
      if (mounted) setState(() => _status = 'Preview failed: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Quick Look for iOS')),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          FilledButton(
            onPressed: _busy ? null : () => _preview(['lorem_ipsum.pdf']),
            child: const Text('Preview PDF'),
          ),
          FilledButton(
            onPressed: _busy
                ? null
                : () => _preview([
                    'lorem_ipsum.pdf',
                    'image1.jpg',
                    'image2.jpg',
                  ], initialIndex: 2),
            child: const Text('Preview multiple files'),
          ),
          SwitchListTile(
            title: const Text('Allow swipe to dismiss'),
            value: _isDismissable,
            onChanged: _busy
                ? null
                : (value) => setState(() => _isDismissable = value),
          ),
          const SizedBox(height: 24),
          Text(_status, textAlign: TextAlign.center),
          const SizedBox(height: 48),
          const Text(
            'Photos: unsplash.com/photos/QeVmJxZOv3k and unsplash.com/photos/Yh2Y8avvPec',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}
