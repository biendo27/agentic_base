import 'package:agentic_base/src/modules/base_module.dart';
import 'package:agentic_base/src/modules/module_installer.dart';
import 'package:agentic_base/src/modules/project_context.dart';

/// Installs image_picker + image_cropper with an ImagePickerService contract.
class ImagePickerModule implements AgenticModule {
  const ImagePickerModule();

  @override
  String get name => 'image_picker';

  @override
  String get description =>
      'image_picker + image_cropper — pick and crop images from gallery or camera.';

  @override
  List<String> get dependencies => ['image_picker', 'image_cropper'];

  @override
  List<String> get devDependencies => [];

  @override
  List<String> get conflictsWith => [];

  @override
  List<String> get requiresModules => ['permissions'];

  @override
  List<String> get platformSteps => [
    'iOS: add NSPhotoLibraryUsageDescription and NSCameraUsageDescription to Info.plist.',
    'Android: add READ_EXTERNAL_STORAGE and CAMERA permissions to AndroidManifest.xml.',
    'Android: add UCropActivity to AndroidManifest.xml for image_cropper.',
  ];

  @override
  Future<void> install(ProjectContext ctx) async {
    ModuleInstaller(ctx)
      ..addDependencies(dependencies)
      ..writeFile(
        'lib/core/image_picker/image_picker_service.dart',
        _contractContent(ctx.projectName),
      )
      ..writeFile(
        'lib/core/image_picker/image_picker_service_impl.dart',
        _implContent(ctx.projectName),
      )
      ..markInstalled(name);
  }

  @override
  Future<void> uninstall(ProjectContext ctx) async {
    ModuleInstaller(ctx)
      ..removeDependencies(dependencies)
      ..deleteFile('lib/core/image_picker/image_picker_service.dart')
      ..deleteFile('lib/core/image_picker/image_picker_service_impl.dart')
      ..markUninstalled(name);
  }

  // ---------------------------------------------------------------------------
  // Templates
  // ---------------------------------------------------------------------------

  String _contractContent(String pkg) => '''
/// Image source selector.
enum ImageSourceType { gallery, camera }

/// Image picker service contract.
abstract class ImagePickerService {
  /// Pick an image from [source]. Returns the file path or null if cancelled.
  Future<String?> pickImage(ImageSourceType source, {double? maxWidth, double? maxHeight});

  /// Pick multiple images from the gallery. Returns file paths.
  Future<List<String>> pickMultipleImages();

  /// Crop an image at [filePath]. Returns the cropped file path or null if cancelled.
  Future<String?> cropImage(String filePath, {int? maxWidth, int? maxHeight});
}
''';

  String _implContent(String pkg) => '''
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:$pkg/core/image_picker/image_picker_service.dart';

/// image_picker + image_cropper implementation of [ImagePickerService].
class ImagePickerServiceImpl implements ImagePickerService {
  ImagePickerServiceImpl()
      : _picker = ImagePicker(),
        _cropper = ImageCropper();

  final ImagePicker _picker;
  final ImageCropper _cropper;

  @override
  Future<String?> pickImage(
    ImageSourceType source, {
    double? maxWidth,
    double? maxHeight,
  }) async {
    final src = source == ImageSourceType.camera
        ? ImageSource.camera
        : ImageSource.gallery;
    final file = await _picker.pickImage(
      source: src,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
    );
    return file?.path;
  }

  @override
  Future<List<String>> pickMultipleImages() async {
    final files = await _picker.pickMultiImage();
    return files.map((f) => f.path).toList();
  }

  @override
  Future<String?> cropImage(
    String filePath, {
    int? maxWidth,
    int? maxHeight,
  }) async {
    final cropped = await _cropper.cropImage(
      sourcePath: filePath,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
    );
    return cropped?.path;
  }
}
''';
}
