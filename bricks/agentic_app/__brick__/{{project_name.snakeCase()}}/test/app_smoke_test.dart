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

    await bootstrap(() => const App(), initializeModules: false);
    await tester.pump();
    // The starter shell can keep short-lived progress indicators or route
    // transitions alive while bootstrap and home loading finish. For smoke
    // coverage we only need the app shell to become visible, not globally idle.
    for (var attempt = 0; attempt < 8; attempt++) {
      if (find.byType(Scaffold).evaluate().isNotEmpty) {
        break;
      }
      await tester.pump(const Duration(milliseconds: 250));
    }
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
