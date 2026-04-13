import 'package:agentic_base/src/config/project_metadata.dart';

const canonicalContextDocs = <String>[
  'README.md',
  'docs/01-architecture.md',
  'docs/02-coding-standards.md',
  'docs/03-state-management.md',
  'docs/04-network-layer.md',
  'docs/05-theming-guide.md',
  'docs/06-testing-guide.md',
];

const thinAdapterFiles = <String>['AGENTS.md', 'CLAUDE.md'];

const deterministicExecutionScripts = <String, String>{
  'setup': './tools/setup.sh',
  'run': './tools/run-dev.sh',
  'verify': './tools/verify.sh',
  'build': './tools/build.sh',
  'release_preflight': './tools/release-preflight.sh',
  'release': './tools/release.sh',
};

const generatorOwnedPaths = <String>[
  'AGENTS.md',
  'CLAUDE.md',
  'README.md',
  'Makefile',
  'docs/',
  'tools/',
  '.github/',
  '.gitlab-ci.yml',
  '.gitlab/ci/',
  'android/fastlane/',
  'ios/fastlane/',
];

const humanOwnedPaths = <String>[
  'lib/features/',
  'lib/shared/',
  'env/*.env',
  'android/app/google-services.json',
  'ios/Runner/GoogleService-Info.plist',
];

Map<String, dynamic> buildAgentReadyConfigMap(ProjectMetadata metadata) {
  return <String, dynamic>{
    'context': <String, dynamic>{
      'canonical_docs': canonicalContextDocs,
      'thin_adapters': thinAdapterFiles,
      'state_runtime': metadata.stateManagement,
      'ci_provider': metadata.ciProvider.name,
    },
    'execution': <String, dynamic>{
      ...deterministicExecutionScripts,
      'default_run_flavor': 'dev',
    },
    'checkpoints': <String, dynamic>{
      'requires_human': <String>[
        'product-decisions',
        'credential-setup',
        'final-store-publish-approval',
      ],
      'release_human_boundary':
          'Agents prepare and upload; humans approve the final store publish.',
    },
    'ownership': <String, dynamic>{
      'generator_owned': generatorOwnedPaths,
      'human_owned': humanOwnedPaths,
    },
  };
}
