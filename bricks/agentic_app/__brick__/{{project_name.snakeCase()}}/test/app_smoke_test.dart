@Tags(<String>['app-smoke'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:{{project_name.snakeCase()}}/app/app.dart';
import 'package:{{project_name.snakeCase()}}/app/bootstrap.dart';
import 'package:{{project_name.snakeCase()}}/app/flavors.dart';

void main() {
  testWidgets('boots the generated app shell', (tester) async {
    FlavorConfig.init(Flavor.dev);

    await bootstrap(() => const App());
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
