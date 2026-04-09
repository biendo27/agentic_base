import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:my_app/app/app.dart';
import 'package:my_app/app/flavors.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('app launches successfully', (tester) async {
    FlavorConfig.init(Flavor.dev);
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();
    expect(find.byType(App), findsOneWidget);
  });
}
