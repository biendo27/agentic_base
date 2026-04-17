import 'package:flutter_test/flutter_test.dart';
import 'package:{{project_name.snakeCase()}}/features/home/presentation/widgets/starter_journey_signal_card.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  testWidgets('renders the default profile and gate-pack summary', (
    tester,
  ) async {
    await tester.pumpApp(
      const StarterJourneySignalCard(
        headline: 'Build from a starter that teaches the right architecture.',
        body: 'This screen proves the generated app shell works.',
        journalBody: 'Move from diagnostics into product seams safely.',
      ),
    );

    expect(find.text('Build from a starter that teaches the right architecture.'), findsOneWidget);
    expect(find.text('This screen proves the generated app shell works.'), findsOneWidget);
    expect(find.textContaining('pack'), findsOneWidget);
  });
}
