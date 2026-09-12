import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:devcommunitychat/features/chat/domain/entities/chat_message.dart';
import 'package:devcommunitychat/features/chat/presentation/widgets/message_bubble.dart';

Future<void> _pumpBubble(WidgetTester tester, ChatMessage message) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: MessageBubble(message: message),
      ),
    ),
  );
}

void main() {
  group('MessageBubble', () {
    testWidgets('affiche le texte, l\'heure et le nom pour un message reçu', (
      tester,
    ) async {
      final message = ChatMessage(
        id: '1',
        text: 'Salut, comment avance le projet ?',
        senderName: 'Alice',
        timestamp: DateTime(2026, 1, 1, 9, 5),
        isMine: false,
      );

      await _pumpBubble(tester, message);

      expect(find.text('Salut, comment avance le projet ?'), findsOneWidget);
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('09:05'), findsOneWidget);
      expect(find.byType(CircleAvatar), findsOneWidget);
      expect(find.byIcon(Icons.done_all), findsNothing);
    });

    testWidgets('n\'affiche ni nom ni avatar pour un message envoyé (isMine)', (
      tester,
    ) async {
      final message = ChatMessage(
        id: '2',
        text: 'Ca avance bien !',
        senderName: 'Moi',
        timestamp: DateTime(2026, 1, 1, 14, 30),
        isMine: true,
      );

      await _pumpBubble(tester, message);

      expect(find.text('Ca avance bien !'), findsOneWidget);
      expect(find.text('Moi'), findsNothing);
      expect(find.text('14:30'), findsOneWidget);
      expect(find.byType(CircleAvatar), findsNothing);
      expect(find.byIcon(Icons.done_all), findsOneWidget);
    });

    testWidgets('affiche l\'initiale de l\'expéditeur sans avatar', (
      tester,
    ) async {
      final message = ChatMessage(
        id: '3',
        text: 'Hello',
        senderName: 'bob',
        timestamp: DateTime(2026, 1, 1, 8, 0),
        isMine: false,
      );

      await _pumpBubble(tester, message);

      expect(find.text('B'), findsOneWidget);
    });
  });
}
