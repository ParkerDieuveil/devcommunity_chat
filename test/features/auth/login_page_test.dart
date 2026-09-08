import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:devcommunitychat/core/router/app_route_path.dart';
import 'package:devcommunitychat/features/auth/presentation/pages/home_page.dart';
import 'package:devcommunitychat/features/auth/presentation/pages/login_page.dart';

GoRouter _buildTestRouter() => GoRouter(
  initialLocation: AppRoutePath.loginPath,
  routes: [
    GoRoute(
      path: AppRoutePath.loginPath,
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: AppRoutePath.homePath,
      builder: (context, state) => const HomePage(),
    ),
  ],
);

void main() {
  group('LoginPage', () {
    testWidgets('affiche le titre et le bouton de connexion', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp.router(routerConfig: _buildTestRouter()));

      expect(find.text('Connexion'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Continuer'), findsOneWidget);
    });

    testWidgets('navigue vers HomePage après un tap sur Continuer', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp.router(routerConfig: _buildTestRouter()));

      await tester.tap(find.text('Continuer'));
      await tester.pumpAndSettle();

      expect(find.text('DevCommunity Chat'), findsOneWidget);
      expect(find.text('Bienvenue sur DevCommunity Chat'), findsOneWidget);
      expect(find.text('Connexion'), findsNothing);
    });
  });
}
