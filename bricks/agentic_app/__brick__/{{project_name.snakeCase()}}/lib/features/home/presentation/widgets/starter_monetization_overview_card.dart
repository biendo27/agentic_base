import 'package:flutter/material.dart';
import 'package:{{project_name.snakeCase()}}/core/starter/starter_runtime_profile.dart';
import 'package:{{project_name.snakeCase()}}/features/home/domain/entities/starter_paywall_snapshot.dart';

class StarterMonetizationOverviewCard extends StatelessWidget {
  const StarterMonetizationOverviewCard({
    required this.snapshot,
    required this.subtitle,
    super.key,
  });

  final StarterPaywallSnapshot snapshot;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Starter commerce seams',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(subtitle),
            const SizedBox(height: 20),
            _SeamRow(
              label: 'Payments',
              value: StarterRuntimeProfile.paymentProviderLabel,
            ),
            _SeamRow(
              label: 'Entitlements',
              value: StarterRuntimeProfile.entitlementProviderLabel,
            ),
            _SeamRow(
              label: 'Consent',
              value: StarterRuntimeProfile.consentLabel,
            ),
            _SeamRow(
              label: 'Ads status',
              value: StarterRuntimeProfile.adsLabel,
            ),
            _SeamRow(
              label: 'Rollout control',
              value: StarterRuntimeProfile.configLabel,
            ),
            const SizedBox(height: 16),
            Text(
              snapshot.supportNote,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _SeamRow extends StatelessWidget {
  const _SeamRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
