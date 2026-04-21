import 'package:agentic_base/src/modules/firebase_runtime_template.dart';
import 'package:test/test.dart';

void main() {
  group('firebase runtime template', () {
    test('shares cold-start initialization across concurrent callers', () {
      final runtime = firebaseRuntimeFileContent(packageName: 'demo_app');

      expect(
        runtime,
        contains('Future<FirebaseRuntimeState>? _pendingFirebaseState;'),
      );
      expect(runtime, contains('final pending = _pendingFirebaseState;'));
      expect(runtime, contains('if (pending != null)'));
      expect(
        runtime,
        contains(
          'return _pendingFirebaseState = _resolveFirebaseRuntimeState()',
        ),
      );
      expect(runtime, contains('_pendingFirebaseState = null'));
      expect(
        runtime,
        contains('Future<FirebaseRuntimeState> _resolveFirebaseRuntimeState()'),
      );
    });
  });
}
