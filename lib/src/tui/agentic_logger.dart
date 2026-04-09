import 'package:mason_logger/mason_logger.dart';

/// Styled logger wrapping [Logger] with agentic_base branding.
class AgenticLogger {
  AgenticLogger({Logger? logger}) : _logger = logger ?? Logger();

  final Logger _logger;

  /// Access the underlying mason logger.
  Logger get raw => _logger;

  void info(String message) => _logger.info(message);
  void err(String message) => _logger.err(message);
  void warn(String message) => _logger.warn(message);
  void success(String message) => _logger.success(message);
  void detail(String message) => _logger.detail(message);

  Progress progress(String message) => _logger.progress(message);

  String prompt(String message, {String? defaultValue}) =>
      _logger.prompt(message, defaultValue: defaultValue);

  bool confirm(String message, {bool defaultValue = false}) =>
      _logger.confirm(message, defaultValue: defaultValue);

  String chooseOne(
    String message, {
    required List<String> choices,
    String? defaultValue,
  }) =>
      _logger.chooseOne(message, choices: choices, defaultValue: defaultValue);

  List<String> chooseAny(
    String message, {
    required List<String> choices,
    List<String>? defaultValues,
  }) =>
      _logger.chooseAny(
        message,
        choices: choices,
        defaultValues: defaultValues,
      );

  /// Print a branded header.
  void header(String title) {
    _logger
      ..info('')
      ..info(lightCyan.wrap('  $title') ?? title)
      ..info('');
  }
}
