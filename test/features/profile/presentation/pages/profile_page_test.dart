import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:devcommunitychat/features/auth/domain/entities/app_user.dart';
import 'package:devcommunitychat/features/auth/presentation/providers/auth_provider.dart';
import 'package:devcommunitychat/features/profile/presentation/pages/profile_page.dart';

void main() {
  testWidgets('ProfilePage affiche les données de l utilisateur connecté', (
    tester,
  ) async {
    const user = AppUser(
      id: 'user-123',
      email: 'alex@example.com',
      displayName: 'Alexandre',
      photoUrl: null,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith((ref) => Stream.value(user)),
        ],
        child: const MaterialApp(
          home: ProfilePage(avatarImage: AssetImage('assets/images/dev.png')),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('Alexandre'), findsOneWidget);
    expect(find.text('alex@example.com'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is RichText && widget.text.toPlainText().contains('@alex'),
      ),
      findsOneWidget,
    );
    expect(find.text('Modifier mon profil'), findsOneWidget);
    expect(find.text('Déconnexion'), findsOneWidget);
  });
}
