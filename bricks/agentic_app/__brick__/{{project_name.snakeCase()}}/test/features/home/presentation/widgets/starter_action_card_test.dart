import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:{{project_name.snakeCase()}}/features/home/presentation/widgets/starter_action_card.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  testWidgets('renders the starter CTA and reacts to taps', (tester) async {
    var tapped = false;

    await tester.pumpApp(
      StarterActionCard(
        icon: Icons.settings_outlined,
        title: 'Starter settings',
        description: 'Preview locale and theme behavior.',
        onTap: () => tapped = true,
      ),
    );

    expect(find.text('Starter settings'), findsOneWidget);
    expect(find.text('Preview locale and theme behavior.'), findsOneWidget);
    expect(find.text('Open'), findsOneWidget);

    await tester.tap(find.text('Starter settings'));

    expect(tapped, isTrue);
  });
}
