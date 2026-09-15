import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:devcommunitychat/core/preferences/shared_preferences_provider.dart';
import 'package:devcommunitychat/core/router/app_route_path.dart';
import 'package:devcommunitychat/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:devcommunitychat/features/onboarding/presentation/providers/onboarding_provider.dart';

void main() {
  testWidgets('Onboarding affiche le premier step et Skip termine', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final router = GoRouter(
      initialLocation: AppRoutePath.onboardingPath,
      routes: [
        GoRoute(
          path: AppRoutePath.onboardingPath,
          builder: (_, _) => const OnboardingPage(),
        ),
        GoRoute(
          path: AppRoutePath.loginPath,
          builder: (_, _) => const Scaffold(body: Text('Login stub')),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Discussions d’équipe'), findsOneWidget);
    expect(find.text('Commencer'), findsOneWidget);
    expect(find.text('Passer'), findsOneWidget);

    await tester.tap(find.text('Passer'));
    await tester.pumpAndSettle();

    expect(find.text('Login stub'), findsOneWidget);

    final container = ProviderScope.containerOf(
      tester.element(find.text('Login stub')),
    );
    expect(container.read(onboardingCompletedProvider), isTrue);
  });
}
