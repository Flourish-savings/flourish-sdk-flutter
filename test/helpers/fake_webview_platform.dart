import 'package:flutter/widgets.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

/// A no-op [WebViewPlatform] so [WebviewContainer] can mount in widget tests
/// without a real native WebView engine. Only the methods the SDK actually
/// drives during `initState`/`build` are overridden; everything else inherits
/// the platform interface's default UnimplementedError.
class FakeWebViewPlatform extends WebViewPlatform {
  @override
  PlatformWebViewController createPlatformWebViewController(
          PlatformWebViewControllerCreationParams params) =>
      FakeWebViewController(params);

  @override
  PlatformNavigationDelegate createPlatformNavigationDelegate(
          PlatformNavigationDelegateCreationParams params) =>
      FakeNavigationDelegate(params);

  @override
  PlatformWebViewWidget createPlatformWebViewWidget(
          PlatformWebViewWidgetCreationParams params) =>
      FakeWebViewWidget(params);
}

class FakeWebViewController extends PlatformWebViewController
    with MockPlatformInterfaceMixin {
  FakeWebViewController(PlatformWebViewControllerCreationParams params)
      : super.implementation(params);

  @override
  Future<void> setBackgroundColor(Color color) async {}
  @override
  Future<void> setJavaScriptMode(JavaScriptMode javaScriptMode) async {}
  @override
  Future<void> addJavaScriptChannel(
      JavaScriptChannelParams javaScriptChannelParams) async {}
  @override
  Future<void> setPlatformNavigationDelegate(
      PlatformNavigationDelegate handler) async {}
  @override
  Future<void> loadRequest(LoadRequestParams params) async {}
}

class FakeNavigationDelegate extends PlatformNavigationDelegate
    with MockPlatformInterfaceMixin {
  FakeNavigationDelegate(PlatformNavigationDelegateCreationParams params)
      : super.implementation(params);

  @override
  Future<void> setOnNavigationRequest(NavigationRequestCallback c) async {}
  @override
  Future<void> setOnPageStarted(PageEventCallback c) async {}
  @override
  Future<void> setOnPageFinished(PageEventCallback c) async {}
  @override
  Future<void> setOnProgress(ProgressCallback c) async {}
  @override
  Future<void> setOnWebResourceError(WebResourceErrorCallback c) async {}
}

class FakeWebViewWidget extends PlatformWebViewWidget
    with MockPlatformInterfaceMixin {
  FakeWebViewWidget(PlatformWebViewWidgetCreationParams params)
      : super.implementation(params);

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
