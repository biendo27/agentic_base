import 'package:mason/mason.dart';

void run(HookContext context) {
  final name = context.vars['project_name'] as String?;
  if (name == null || name.isEmpty) {
    throw Exception('project_name is required');
  }
  // Enforce snake_case: lowercase letters, digits, underscores; must start
  // with a letter (aligns with Dart package naming rules).
  if (!RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(name)) {
    throw Exception(
      'project_name must be snake_case (e.g. my_app). '
      'Got: "$name"',
    );
  }
}
