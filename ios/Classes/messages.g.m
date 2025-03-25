// Autogenerated from Pigeon (v25.1.0), do not edit directly.
// See also: https://pub.dev/packages/pigeon

#import "messages.g.h"

#if TARGET_OS_OSX
#import <FlutterMacOS/FlutterMacOS.h>
#else
#import <Flutter/Flutter.h>
#endif

#if !__has_feature(objc_arc)
#error File requires ARC to be enabled.
#endif

static NSArray<id> *wrapResult(id result, FlutterError *error) {
  if (error) {
    return @[
      error.code ?: [NSNull null], error.message ?: [NSNull null], error.details ?: [NSNull null]
    ];
  }
  return @[ result ?: [NSNull null] ];
}

static id GetNullableObjectAtIndex(NSArray<id> *array, NSInteger key) {
  id result = array[key];
  return (result == [NSNull null]) ? nil : result;
}

@interface QLMessagesPigeonCodecReader : FlutterStandardReader
@end
@implementation QLMessagesPigeonCodecReader
- (nullable id)readValueOfType:(UInt8)type {
  switch (type) {
    default:
      return [super readValueOfType:type];
  }
}
@end

@interface QLMessagesPigeonCodecWriter : FlutterStandardWriter
@end
@implementation QLMessagesPigeonCodecWriter
- (void)writeValue:(id)value {
  {
    [super writeValue:value];
  }
}
@end

@interface QLMessagesPigeonCodecReaderWriter : FlutterStandardReaderWriter
@end
@implementation QLMessagesPigeonCodecReaderWriter
- (FlutterStandardWriter *)writerWithData:(NSMutableData *)data {
  return [[QLMessagesPigeonCodecWriter alloc] initWithData:data];
}
- (FlutterStandardReader *)readerWithData:(NSData *)data {
  return [[QLMessagesPigeonCodecReader alloc] initWithData:data];
}
@end

NSObject<FlutterMessageCodec> *QLGetMessagesCodec(void) {
  static FlutterStandardMessageCodec *sSharedObject = nil;
  static dispatch_once_t sPred = 0;
  dispatch_once(&sPred, ^{
    QLMessagesPigeonCodecReaderWriter *readerWriter = [[QLMessagesPigeonCodecReaderWriter alloc] init];
    sSharedObject = [FlutterStandardMessageCodec codecWithReaderWriter:readerWriter];
  });
  return sSharedObject;
}
void SetUpQLQuickLookApi(id<FlutterBinaryMessenger> binaryMessenger, NSObject<QLQuickLookApi> *api) {
  SetUpQLQuickLookApiWithSuffix(binaryMessenger, api, @"");
}

void SetUpQLQuickLookApiWithSuffix(id<FlutterBinaryMessenger> binaryMessenger, NSObject<QLQuickLookApi> *api, NSString *messageChannelSuffix) {
  messageChannelSuffix = messageChannelSuffix.length > 0 ? [NSString stringWithFormat: @".%@", messageChannelSuffix] : @"";
  /// Opens file saved at [url] in iOS QuickLook
  ///
  /// (iOS 13+) [isDismissable] configures whether QuickLook is dismissable by a swipe from top to bottom
  ///
  /// The file should be saved at the ApplicationDocumentsDirectory (check out the example at https://pub.dev/packages/quick_look/example)
  {
    FlutterBasicMessageChannel *channel =
      [[FlutterBasicMessageChannel alloc]
        initWithName:[NSString stringWithFormat:@"%@%@", @"dev.flutter.pigeon.quick_look.QuickLookApi.openURL", messageChannelSuffix]
        binaryMessenger:binaryMessenger
        codec:QLGetMessagesCodec()];
    if (api) {
      NSCAssert([api respondsToSelector:@selector(openURLUrl:isDismissable:completion:)], @"QLQuickLookApi api (%@) doesn't respond to @selector(openURLUrl:isDismissable:completion:)", api);
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        NSArray<id> *args = message;
        NSString *arg_url = GetNullableObjectAtIndex(args, 0);
        BOOL arg_isDismissable = [GetNullableObjectAtIndex(args, 1) boolValue];
        [api openURLUrl:arg_url isDismissable:arg_isDismissable completion:^(NSNumber *_Nullable output, FlutterError *_Nullable error) {
          callback(wrapResult(output, error));
        }];
      }];
    } else {
      [channel setMessageHandler:nil];
    }
  }
  /// Opens files saved at [resourceURLs] in iOS QuickLook (user can swipe between them)
  ///
  /// Sets the current item in view to [initialIndex]
  /// (iOS 13+) [isDismissable] configures whether QuickLook is dismissable by a swipe from top to bottom
  ///
  /// The files should be saved at the ApplicationDocumentsDirectory (check out the example at https://pub.dev/packages/quick_look/example)
  {
    FlutterBasicMessageChannel *channel =
      [[FlutterBasicMessageChannel alloc]
        initWithName:[NSString stringWithFormat:@"%@%@", @"dev.flutter.pigeon.quick_look.QuickLookApi.openURLs", messageChannelSuffix]
        binaryMessenger:binaryMessenger
        codec:QLGetMessagesCodec()];
    if (api) {
      NSCAssert([api respondsToSelector:@selector(openURLsResourceURLs:initialIndex:isDismissable:completion:)], @"QLQuickLookApi api (%@) doesn't respond to @selector(openURLsResourceURLs:initialIndex:isDismissable:completion:)", api);
      [channel setMessageHandler:^(id _Nullable message, FlutterReply callback) {
        NSArray<id> *args = message;
        NSArray<NSString *> *arg_resourceURLs = GetNullableObjectAtIndex(args, 0);
        NSInteger arg_initialIndex = [GetNullableObjectAtIndex(args, 1) integerValue];
        BOOL arg_isDismissable = [GetNullableObjectAtIndex(args, 2) boolValue];
        [api openURLsResourceURLs:arg_resourceURLs initialIndex:arg_initialIndex isDismissable:arg_isDismissable completion:^(NSNumber *_Nullable output, FlutterError *_Nullable error) {
          callback(wrapResult(output, error));
        }];
      }];
    } else {
      [channel setMessageHandler:nil];
    }
  }
}
