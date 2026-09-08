import 'package:devcommunitychat/core/router/app_router.dart';
import 'package:devcommunitychat/features/auth/presentation/pages/login_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:devcommunitychat/main.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets(
    'DevCommunity Chat démarre correctement',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            routerProvider.overrideWithValue(
              GoRouter(
                initialLocation: '/login',
                routes: [
                  GoRoute(
                    path: '/login',
                    builder: (context, state) => const LoginPage(),
                  ),
                ],
              ),
            ),
          ],
          child: const DevCommunityChatApp(),
        ),
      );

      expect(find.text('Connexion'), findsOneWidget);
      expect(find.text('Se connecter'), findsOneWidget);
    },
  );
}
