/// Verification depth for generated projects.
enum GeneratedVerificationMode {
  /// Run the full generated `tools/verify.sh` contract.
  full,

  /// Run verify with fast-loop skips for static/unit/native gates.
  fast,

  /// Skip generated verification because the caller runs an immediate gate.
  none,
}

const generatedVerificationModes = <String>['full', 'fast', 'none'];

extension GeneratedVerificationModeX on GeneratedVerificationMode {
  String get wireName => name;

  static GeneratedVerificationMode fromWireName(String? value) {
    final normalized =
        (value ?? GeneratedVerificationMode.full.name).trim().toLowerCase();
    for (final mode in GeneratedVerificationMode.values) {
      if (mode.name == normalized) {
        return mode;
      }
    }
    throw FormatException(
      'Invalid verification mode "$value". '
      'Allowed: ${generatedVerificationModes.join(', ')}.',
    );
  }
}
