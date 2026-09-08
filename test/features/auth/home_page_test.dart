import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:devcommunitychat/features/auth/presentation/pages/home_page.dart';

void main() {
  group('HomePage', () {
    testWidgets('affiche le titre et le message de bienvenue', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: HomePage()));

      expect(find.text('DevCommunity Chat'), findsOneWidget);
      expect(find.text('Bienvenue sur DevCommunity Chat'), findsOneWidget);
    });
  });
}
