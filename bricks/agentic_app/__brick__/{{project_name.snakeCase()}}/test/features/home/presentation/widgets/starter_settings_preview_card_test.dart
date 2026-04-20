import 'package:flutter_test/flutter_test.dart';
import 'package:{{project_name.snakeCase()}}/features/home/presentation/widgets/starter_settings_preview_card.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  testWidgets('renders the trustworthy starter defaults copy', (tester) async {
    await tester.pumpApp(
      const StarterSettingsPreviewCard(
        subtitle: 'Preview theme mode and locale behavior safely.',
      ),
    );

    expect(find.text('Trustworthy starter defaults'), findsOneWidget);
    expect(
      find.textContaining('theme and locale previews honest'),
      findsOneWidget,
    );
  });
}
