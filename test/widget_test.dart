import 'package:flutter_test/flutter_test.dart';

import 'package:devcommunitychat/main.dart';

void main() {
  testWidgets('DevCommunity Chat démarre correctement', (WidgetTester tester) async {
    await tester.pumpWidget(const DevCommunityChatApp());

    expect(find.text('DevCommunity Chat'), findsOneWidget);
    expect(find.text('Firebase connect 🚀'), findsOneWidget);
  });
}