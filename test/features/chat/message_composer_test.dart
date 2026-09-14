import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:devcommunitychat/features/chat/presentation/widgets/message_composer.dart';

void main() {
  group('MessageComposer', () {
    testWidgets('le bouton d\'envoi est désactivé tant que le champ est vide', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: MessageComposer(onSubmitted: (_) {})),
        ),
      );

      final button = tester.widget<IconButton>(find.byType(IconButton).last);
      expect(button.onPressed, isNull);
    });

    testWidgets(
      'appelle onSubmitted avec le texte saisi et vide le champ',
      (tester) async {
        String? submitted;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MessageComposer(onSubmitted: (text) => submitted = text),
            ),
          ),
        );

        await tester.enterText(find.byType(TextField), 'Hello team');
        await tester.pump();

        final button = tester.widget<IconButton>(find.byType(IconButton).last);
        expect(button.onPressed, isNotNull);

        await tester.tap(find.byType(IconButton).last);
        await tester.pump();

        expect(submitted, 'Hello team');
        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.controller?.text, isEmpty);
      },
    );
  });
}
