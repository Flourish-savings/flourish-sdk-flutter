#import "FlourishFlutterSdkPlugin.h"
#if __has_include(<flourish_flutter_sdk/flourish_flutter_sdk-Swift.h>)
#import <flourish_flutter_sdk/flourish_flutter_sdk-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flourish_flutter_sdk-Swift.h"
#endif

@implementation FlourishFlutterSdkPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlourishFlutterSdkPlugin registerWithRegistrar:registrar];
}
@end
