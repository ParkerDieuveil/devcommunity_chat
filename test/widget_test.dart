import 'package:flutter_test/flutter_test.dart';
import 'package:devcommunitychat/main.dart';

void main() {
  testWidgets(
    'DevCommunity Chat démarre correctement',
        (WidgetTester tester) async {
      await tester.pumpWidget(const DevCommunityChatApp());

      expect(find.text('Connexion'), findsOneWidget);
      expect(find.text('Continuer'), findsOneWidget);
    },
  );
}