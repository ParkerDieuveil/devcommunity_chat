import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:devcommunitychat/core/preferences/shared_preferences_provider.dart';
import 'package:devcommunitychat/features/auth/domain/entities/app_user.dart';
import 'package:devcommunitychat/features/auth/presentation/providers/auth_provider.dart';
import 'package:devcommunitychat/features/profile/domain/entities/profile.dart';
import 'package:devcommunitychat/features/profile/presentation/pages/profile_page.dart';
import 'package:devcommunitychat/features/profile/presentation/providers/profile_provider.dart';

import '../../fakes/fake_profile_repository.dart';

void main() {
  testWidgets('ProfilePage affiche les données de l utilisateur connecté', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    const user = AppUser(
      id: 'user-123',
      email: 'alex@example.com',
      displayName: 'Alexandre',
      photoUrl: null,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          authStateProvider.overrideWith((ref) => Stream.value(user)),
          profileRepositoryProvider.overrideWithValue(
            FakeProfileRepository(
              profile: const ProfileEntity(
                id: 'user-123',
                displayname: 'Alexandre',
                email: 'alex@example.com',
                bio: '',
                photoUrl: '',
              ),
            ),
          ),
          profileSalonCountProvider.overrideWith((ref) => const AsyncData(0)),
        ],
        child: const MaterialApp(
          home: ProfilePage(avatarImage: AssetImage('assets/images/dev.png')),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Alexandre'), findsOneWidget);
    expect(find.text('alex@example.com'), findsOneWidget);
    expect(find.text('@alex'), findsOneWidget);
    expect(find.text('Modifier mon profil'), findsOneWidget);
    expect(find.text('Déconnexion'), findsOneWidget);
  });
}
