#import "QuickLookPlugin.h"
#if __has_include(<quick_look/quick_look-Swift.h>)
#import <quick_look/quick_look-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "quick_look-Swift.h"
#endif

@implementation QuickLookPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftQuickLookPlugin registerWithRegistrar:registrar];
}
@end
