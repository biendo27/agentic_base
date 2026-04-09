import 'package:agentic_base/src/modules/base_module.dart';
import 'package:agentic_base/src/modules/module_installer.dart';
import 'package:agentic_base/src/modules/project_context.dart';

/// Installs flutter_inappwebview with a WebViewService contract.
class WebViewModule implements AgenticModule {
  const WebViewModule();

  @override
  String get name => 'webview';

  @override
  String get description =>
      'flutter_inappwebview — embedded web views with JS bridge support.';

  @override
  List<String> get dependencies => ['flutter_inappwebview'];

  @override
  List<String> get devDependencies => [];

  @override
  List<String> get conflictsWith => [];

  @override
  List<String> get requiresModules => [];

  @override
  List<String> get platformSteps => [
    'iOS: set minimum deployment target to iOS 12 in Xcode.',
    'Android: set minSdkVersion to 19 in android/app/build.gradle.',
    'Android: add android:usesCleartextTraffic="true" if loading HTTP URLs.',
  ];

  @override
  Future<void> install(ProjectContext ctx) async {
    ModuleInstaller(ctx)
      ..addDependencies(dependencies)
      ..writeFile(
        'lib/core/webview/webview_service.dart',
        _contractContent(ctx.projectName),
      )
      ..writeFile(
        'lib/core/webview/inappwebview_service.dart',
        _implContent(ctx.projectName),
      )
      ..markInstalled(name);
  }

  @override
  Future<void> uninstall(ProjectContext ctx) async {
    ModuleInstaller(ctx)
      ..removeDependencies(dependencies)
      ..deleteFile('lib/core/webview/webview_service.dart')
      ..deleteFile('lib/core/webview/inappwebview_service.dart')
      ..markUninstalled(name);
  }

  // ---------------------------------------------------------------------------
  // Templates
  // ---------------------------------------------------------------------------

  String _contractContent(String pkg) => '''
/// WebView navigation event.
enum WebViewNavigationEvent { started, finished, failed }

/// WebView service contract — thin facade for programmatic control.
///
/// For rendering, embed [InAppWebView] widget directly. Attach the
/// [InAppWebViewController] to this service via the implementation's
/// [attachController] method.
abstract class WebViewService {
  /// Load [url] in the web view.
  Future<void> loadUrl(String url);

  /// Evaluate [javascript] and return the result as a string.
  Future<String?> evaluateJavascript(String javascript);

  /// Returns true if the web view can navigate back.
  Future<bool> canGoBack();

  /// Navigate back in the web view history.
  Future<void> goBack();

  /// Reload the current page.
  Future<void> reload();

  /// Returns the current URL, or null if not loaded.
  Future<String?> getCurrentUrl();
}
''';

  String _implContent(String pkg) => '''
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:$pkg/core/webview/webview_service.dart';

/// flutter_inappwebview implementation of [WebViewService].
///
/// Attach the controller from InAppWebView(onWebViewCreated:):
///
/// ```dart
/// InAppWebView(
///   onWebViewCreated: (controller) => service.attachController(controller),
/// )
/// ```
class InappwebviewService implements WebViewService {
  InAppWebViewController? _controller;

  /// Attach the native controller from [InAppWebView.onWebViewCreated].
  void attachController(InAppWebViewController controller) {
    _controller = controller;
  }

  @override
  Future<void> loadUrl(String url) async {
    await _controller?.loadUrl(
      urlRequest: URLRequest(url: WebUri(url)),
    );
  }

  @override
  Future<String?> evaluateJavascript(String javascript) async {
    final result = await _controller?.evaluateJavascript(source: javascript);
    return result?.toString();
  }

  @override
  Future<bool> canGoBack() async => _controller?.canGoBack() ?? Future.value(false);

  @override
  Future<void> goBack() async => _controller?.goBack();

  @override
  Future<void> reload() async => _controller?.reload();

  @override
  Future<String?> getCurrentUrl() async {
    final url = await _controller?.getUrl();
    return url?.toString();
  }
}
''';
}
