import 'dart:typed_data';

import 'package:devcommunitychat/features/profile/presentation/widgets/profile_theme_option.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter/material.dart';
import 'package:devcommunitychat/features/profile/presentation/pages/profile_screen.dart';

void main() {
  final testAvatar = MemoryImage(
    Uint8List.fromList(<int>[
      137,
      80,
      78,
      71,
      13,
      10,
      26,
      10,
      0,
      0,
      0,
      13,
      73,
      72,
      68,
      82,
      0,
      0,
      0,
      1,
      0,
      0,
      0,
      1,
      8,
      6,
      0,
      0,
      0,
      31,
      21,
      196,
      137,
      0,
      0,
      0,
      13,
      73,
      68,
      65,
      84,
      8,
      215,
      99,
      248,
      207,
      192,
      240,
      31,
      0,
      5,
      0,
      1,
      255,
      137,
      153,
      61,
      29,
      0,
      0,
      0,
      0,
      73,
      69,
      78,
      68,
      174,
      66,
      96,
      130,
    ]),
  );

  Future<void> pumpProfileScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(home: ProfileScreen(avatarImage: testAvatar)),
    );
  }

  testWidgets('affiche les informations principales du profil', (
    WidgetTester tester,
  ) async {
    await pumpProfileScreen(tester);

    expect(find.text('Mon Profil'), findsOneWidget);
    expect(find.text('Alexandre Vasseur'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is RichText &&
            widget.text.toPlainText().contains('@alex_dev'),
      ),
      findsOneWidget,
    );
    expect(find.text('À propos de DevCommunity'), findsOneWidget);
  });

  testWidgets('bascule les notifications push', (WidgetTester tester) async {
    await pumpProfileScreen(tester);

    final switchFinder = find.byType(Switch);

    expect(tester.widget<Switch>(switchFinder).value, isTrue);

    await tester.scrollUntilVisible(switchFinder, 200);
    await tester.tap(switchFinder);
    await tester.pump();

    expect(tester.widget<Switch>(switchFinder).value, isFalse);
  });

  testWidgets('sélectionne le thème Clair', (WidgetTester tester) async {
    await pumpProfileScreen(tester);

    final clairFinder = find.text('Clair');
    final clairOptionFinder = find.ancestor(
      of: clairFinder,
      matching: find.byType(ProfileThemeOption),
    );

    expect(
      tester.widget<ProfileThemeOption>(clairOptionFinder).isSelected,
      isFalse,
    );

    await tester.scrollUntilVisible(clairFinder, 200);
    await tester.tap(clairFinder);
    await tester.pump();

    expect(
      tester.widget<ProfileThemeOption>(clairOptionFinder).isSelected,
      isTrue,
    );
  });
}
