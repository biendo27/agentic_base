import 'dart:io';

import 'package:agentic_base/src/config/agentic_config.dart';
import 'package:agentic_base/src/config/flutter_sdk_contract.dart';
import 'package:agentic_base/src/config/harness_metadata.dart';
import 'package:agentic_base/src/config/harness_profile.dart';
import 'package:agentic_base/src/config/profile_preset.dart';
import 'package:agentic_base/src/generators/agentic_app_surface_synchronizer.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('profile gate contract rendering', () {
    test(
      'subscription-commerce renders the required starter commerce gate',
      () async {
        final tempDir = await Directory.systemTemp.createTemp(
          'profile-gate-contract-subscription-',
        );
        addTearDown(() => tempDir.delete(recursive: true));

        final preset = resolveProfilePreset(
          appProfile: HarnessAppProfile.subscriptionCommerceApp,
        );
        final outputDirectory = p.join(tempDir.path, 'demo_app');

        await const AgenticAppSurfaceSynchronizer().overlay(
          outputDirectory: outputDirectory,
          metadata: AgenticConfig.buildInitialMetadata(
            projectName: 'demo_app',
            org: 'com.example',
            stateManagement: 'cubit',
            platforms: const ['android', 'ios', 'web'],
            flavors: const ['dev', 'staging', 'prod'],
            toolVersion: 'test',
            modules: preset.effectiveModules,
            harness: HarnessMetadata.defaultFor(
              appProfile: HarnessAppProfile.subscriptionCommerceApp,
              capabilities: preset.effectiveModules,
              providers: preset.providers,
              sdk: const FlutterSdkContract(
                manager: FlutterSdkManager.system,
                channel: 'stable',
                version: '3.41.6',
                policy: FlutterVersionPolicy.newestTested,
              ),
            ),
          ),
        );

        final verifyScript =
            File(
              p.join(outputDirectory, 'tools', 'verify.sh'),
            ).readAsStringSync();
        expect(verifyScript, contains('starter-commerce'));
        expect(
          verifyScript,
          contains(
            'test/features/home/presentation/widgets/starter_monetization_overview_card_test.dart',
          ),
        );
      },
    );

    test('tier2 profiles render advisory-only starter checks', () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'profile-gate-contract-tier2-',
      );
      addTearDown(() => tempDir.delete(recursive: true));

      final outputDirectory = p.join(tempDir.path, 'demo_app');

      await const AgenticAppSurfaceSynchronizer().overlay(
        outputDirectory: outputDirectory,
        metadata: AgenticConfig.buildInitialMetadata(
          projectName: 'demo_app',
          org: 'com.example',
          stateManagement: 'cubit',
          platforms: const ['android', 'ios', 'web'],
          flavors: const ['dev', 'staging', 'prod'],
          toolVersion: 'test',
          harness: HarnessMetadata.defaultFor(
            appProfile: HarnessAppProfile.contentCommunityApp,
            sdk: const FlutterSdkContract(
              manager: FlutterSdkManager.system,
              channel: 'stable',
              version: '3.41.6',
              policy: FlutterVersionPolicy.newestTested,
            ),
          ),
        ),
      );

      final verifyScript =
          File(
            p.join(outputDirectory, 'tools', 'verify.sh'),
          ).readAsStringSync();
      expect(verifyScript, contains('profile-advisory'));
      expect(verifyScript, isNot(contains('starter-commerce')));
    });
  });
}
