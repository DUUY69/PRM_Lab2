import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:lab2/theme/app_theme.dart';
import 'package:lab2/viewmodels/app_navigation_viewmodel.dart';
import 'package:lab2/viewmodels/publication_viewmodel.dart';
import 'package:lab2/screens/main_shell.dart';

void main() {
  testWidgets('JournalAI shell smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => PublicationViewModel()),
          ChangeNotifierProvider(create: (_) => AppNavigationViewModel()),
        ],
        child: MaterialApp(
          theme: buildAppTheme(),
          home: const MainShell(),
        ),
      ),
    );

    expect(find.text('Overview'), findsWidgets);
    expect(find.text('JournalAI'), findsWidgets);
  });
}
