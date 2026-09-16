import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:devcommunitychat/core/preferences/shared_preferences_provider.dart';
import 'package:devcommunitychat/features/auth/domain/entities/app_user.dart';
import 'package:devcommunitychat/features/auth/presentation/providers/auth_provider.dart';
import 'package:devcommunitychat/main.dart';

import 'helpers/test_prefs.dart';

void main() {
  testWidgets(
    "DevCommunity Chat démarre sur la page de connexion quand aucun utilisateur n'est connecté",
    (WidgetTester tester) async {
      final prefs = await mockSharedPreferences({'onboarding_done': true});

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            authStateProvider.overrideWith(
              (ref) => Stream<AppUser?>.value(null),
            ),
          ],
          child: const DevCommunityChatApp(),
        ),
      );

      // Passe le splash (~2.6s) puis arrive sur /login.
      await tester.pump();
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();

      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Mot de passe'), findsOneWidget);
      expect(find.text('Se connecter'), findsOneWidget);
    },
  );
}
