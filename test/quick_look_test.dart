import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quick_look/quick_look.dart';
import 'package:quick_look/quick_look_messages.g.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  const methods = ['openURL', 'openURLs', 'canOpenURL'];

  BasicMessageChannel<Object?> channel(String method) =>
      BasicMessageChannel<Object?>(
        'dev.flutter.pigeon.quick_look.QuickLookApi.$method',
        QuickLookApi.pigeonChannelCodec,
      );

  tearDown(() {
    for (final method in methods) {
      messenger.setMockDecodedMessageHandler<Object?>(channel(method), null);
    }
  });

  test(
    'single preview preserves literal paths and waits for native dismissal',
    () async {
      const path = '/tmp/Пример #100% ? file.pdf';
      final dismissed = Completer<Object?>();
      messenger.setMockDecodedMessageHandler<Object?>(channel('openURL'), (
        message,
      ) {
        expect(message, [path, false]);
        return dismissed.future;
      });
      var completed = false;
      final result = QuickLook.openURL(path, isDismissable: false).then((
        value,
      ) {
        completed = true;
        return value;
      });
      await Future<void>.delayed(Duration.zero);
      expect(completed, isFalse);
      dismissed.complete([true]);
      expect(await result, isTrue);
    },
  );

  test(
    'multiple previews forward order, selected index and dismissal option',
    () async {
      messenger.setMockDecodedMessageHandler<Object?>(channel('openURLs'), (
        message,
      ) async {
        expect(message, [
          ['/tmp/first.pdf', '/tmp/second.jpg'],
          1,
          false,
        ]);
        return [true];
      });
      expect(
        await QuickLook.openURLs(
          resourceURLs: ['/tmp/first.pdf', '/tmp/second.jpg'],
          initialIndex: 1,
          isDismissable: false,
        ),
        isTrue,
      );
    },
  );

  test('default swipe dismissal and native refusal are preserved', () async {
    messenger.setMockDecodedMessageHandler<Object?>(channel('openURL'), (
      message,
    ) async {
      expect(message, ['/tmp/file.pdf', true]);
      return [false];
    });
    expect(await QuickLook.openURL('/tmp/file.pdf'), isFalse);
  });

  test('capability query returns the native result', () async {
    messenger.setMockDecodedMessageHandler<Object?>(channel('canOpenURL'), (
      message,
    ) async {
      expect(message, ['/tmp/file.pdf']);
      return [true];
    });
    expect(await QuickLook.canOpenURL('/tmp/file.pdf'), isTrue);
  });

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

  test('native errors are propagated', () async {
    messenger.setMockDecodedMessageHandler<Object?>(
      channel('openURL'),
      (_) async => ['native-error', 'Failed', null],
    );
    await expectLater(
      QuickLook.openURL('/tmp/file.pdf'),
      throwsA(
        isA<PlatformException>().having((e) => e.code, 'code', 'native-error'),
      ),
    );
  });

  test('an unavailable plugin reports a channel error', () async {
    await expectLater(
      QuickLook.canOpenURL('/tmp/file.pdf'),
      throwsA(
        isA<PlatformException>().having((e) => e.code, 'code', 'channel-error'),
      ),
    );
  });
}
