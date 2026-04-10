import 'dart:io';

import 'package:path/path.dart' as p;

enum CiProvider { github, gitlab }

const CiProvider defaultCiProvider = CiProvider.github;
const List<String> supportedCiProviders = ['github', 'gitlab'];

CiProvider parseCiProvider(String rawValue) {
  final normalized = rawValue.trim().toLowerCase();
  for (final provider in CiProvider.values) {
    if (provider.name == normalized) {
      return provider;
    }
  }

  throw FormatException(
    'Invalid CI provider "$rawValue". '
    'Allowed: ${supportedCiProviders.join(', ')}.',
  );
}

CiProvider? inferCiProviderFromProjectFiles(String projectPath) {
  final hasGitHubWorkflows =
      Directory(p.join(projectPath, '.github', 'workflows')).existsSync();
  final hasGitLabConfig =
      File(p.join(projectPath, '.gitlab-ci.yml')).existsSync() ||
      Directory(p.join(projectPath, '.gitlab')).existsSync();

  if (hasGitHubWorkflows == hasGitLabConfig) {
    return null;
  }

  return hasGitHubWorkflows ? CiProvider.github : CiProvider.gitlab;
}

CiProvider resolveCiProviderFromConfig({
  required Map<String, dynamic> config,
  required String projectPath,
}) {
  final stored = config['ci_provider'];
  if (stored is String) {
    try {
      return parseCiProvider(stored);
    } on FormatException {
      // Fall back to inferred/default provider below.
    }
  }

  return inferCiProviderFromProjectFiles(projectPath) ?? defaultCiProvider;
}
