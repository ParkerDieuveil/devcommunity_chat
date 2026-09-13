import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:devcommunitychat/core/router/navigation_provider.dart';
import 'package:devcommunitychat/features/auth/presentation/pages/home_content.dart';

void main() {
  testWidgets('HomeContent ouvre le tab Chat', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: HomeContent())),
    );

    await tester.pump();

    expect(find.text('Ouvrir le chat'), findsOneWidget);

    await tester.tap(find.text('Ouvrir le chat'));
    await tester.pump();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(HomeContent)),
    );
    expect(container.read(mainTabProvider), MainTab.chat);
  });
}
