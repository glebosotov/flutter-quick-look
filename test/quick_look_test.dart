import 'package:flutter_test/flutter_test.dart';
import 'package:quick_look/quick_look.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // No native handlers are installed: invalid input must return false before
  // invoking the platform channel, which would throw without a handler.
  test('invalid paths never reach the native channel', () async {
    for (final path in [
      '',
      'relative.pdf',
      'https://example.com/file.pdf',
      'file:///tmp/file.pdf',
      '/tmp/null\u0000.pdf',
    ]) {
      expect(await QuickLook.openURL(path), isFalse);
      expect(await QuickLook.canOpenURL(path), isFalse);
      expect(
        await QuickLook.openURLs(resourceURLs: ['/tmp/valid.pdf', path]),
        isFalse,
      );
    }
  });

  test(
    'empty lists and out-of-range indices never reach the native channel',
    () async {
      expect(await QuickLook.openURLs(resourceURLs: []), isFalse);
      for (final index in [-1, 1, 9223372036854775807]) {
        expect(
          await QuickLook.openURLs(
            resourceURLs: ['/tmp/file.pdf'],
            initialIndex: index,
          ),
          isFalse,
        );
      }
    },
  );
}
