import 'package:agentic_base/src/modules/base_module.dart';
import 'package:agentic_base/src/modules/module_installer.dart';
import 'package:agentic_base/src/modules/project_context.dart';

/// Installs mobile_scanner with a QrScannerService contract.
class QrScannerModule implements AgenticModule {
  const QrScannerModule();

  @override
  String get name => 'qr_scanner';

  @override
  String get description =>
      'mobile_scanner — fast QR code and barcode scanning via camera.';

  @override
  List<String> get dependencies => ['mobile_scanner'];

  @override
  List<String> get devDependencies => [];

  @override
  List<String> get conflictsWith => [];

  @override
  List<String> get requiresModules => ['permissions'];

  @override
  List<String> get platformSteps => [
        'iOS: add NSCameraUsageDescription to Info.plist.',
        'Android: add CAMERA permission to AndroidManifest.xml.',
      ];

  @override
  Future<void> install(ProjectContext ctx) async {
    ModuleInstaller(ctx)
      ..addDependencies(dependencies)
      ..writeFile(
        'lib/core/qr_scanner/qr_scanner_service.dart',
        _contractContent(ctx.projectName),
      )
      ..writeFile(
        'lib/core/qr_scanner/mobile_scanner_service.dart',
        _implContent(ctx.projectName),
      )
      ..markInstalled(name);
  }

  @override
  Future<void> uninstall(ProjectContext ctx) async {
    ModuleInstaller(ctx)
      ..removeDependencies(dependencies)
      ..deleteFile('lib/core/qr_scanner/qr_scanner_service.dart')
      ..deleteFile('lib/core/qr_scanner/mobile_scanner_service.dart')
      ..markUninstalled(name);
  }

  // ---------------------------------------------------------------------------
  // Templates
  // ---------------------------------------------------------------------------

  String _contractContent(String pkg) => '''
/// Barcode format types.
enum BarcodeFormat {
  qrCode,
  ean13,
  ean8,
  code128,
  code39,
  dataMatrix,
  pdf417,
  aztec,
  unknown,
}

/// Result of a single scan.
class ScanResult {
  const ScanResult({required this.value, required this.format});

  final String value;
  final BarcodeFormat format;
}

/// QR / barcode scanner service contract.
///
/// Embed [MobileScanner] widget directly for live preview. Use
/// [QrScannerService] for programmatic control and result handling.
abstract class QrScannerService {
  /// Stream of decoded scan results from the live camera feed.
  Stream<ScanResult> get scanStream;

  /// Scan a static image at [imagePath] and return results.
  Future<List<ScanResult>> scanImage(String imagePath);
}
''';

  String _implContent(String pkg) => '''
import 'dart:async';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:$pkg/core/qr_scanner/qr_scanner_service.dart';

/// mobile_scanner implementation of [QrScannerService].
///
/// Pass [onDetect] callback to [MobileScanner] widget, which calls
/// [handleDetection] to push results onto [scanStream].
class MobileScannerService implements QrScannerService {
  final _controller = StreamController<ScanResult>.broadcast();

  /// Call this from MobileScanner(onDetect:) to feed results into [scanStream].
  void handleDetection(BarcodeCapture capture) {
    for (final barcode in capture.barcodes) {
      final value = barcode.rawValue;
      if (value == null) continue;
      _controller.add(ScanResult(
        value: value,
        format: _mapFormat(barcode.format),
      ));
    }
  }

  @override
  Stream<ScanResult> get scanStream => _controller.stream;

  @override
  Future<List<ScanResult>> scanImage(String imagePath) async {
    final controller = MobileScannerController();
    final results = await controller.analyzeImage(imagePath);
    await controller.dispose();
    if (results == null) return [];
    return results.barcodes
        .where((b) => b.rawValue != null)
        .map((b) => ScanResult(value: b.rawValue!, format: _mapFormat(b.format)))
        .toList();
  }

  BarcodeFormat _mapFormat(BarcodeFormat format) => format;

  void dispose() => _controller.close();
}
''';
}
