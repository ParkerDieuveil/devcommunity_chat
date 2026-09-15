import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:devcommunitychat/core/preferences/shared_preferences_provider.dart';
import 'package:devcommunitychat/features/auth/domain/entities/app_user.dart';
import 'package:devcommunitychat/features/auth/presentation/providers/auth_provider.dart';
import 'package:devcommunitychat/main.dart';

void main() {
  testWidgets(
    "DevCommunity Chat démarre sur la page de connexion quand aucun utilisateur n'est connecté",
    (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues(const {});
      final prefs = await SharedPreferences.getInstance();

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
      await tester.pumpAndSettle();

      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Mot de passe'), findsOneWidget);
      expect(find.text('Se connecter'), findsOneWidget);
    },
  );
}
