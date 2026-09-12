import 'package:flutter_test/flutter_test.dart';
import 'package:devcommunitychat/core/router/app_route_path.dart';

void main() {
  group('AppRoutePath', () {
    test('expose les chemins de routes attendus', () {
      expect(AppRoutePath.root, '/');
      expect(AppRoutePath.loginPath, '/login');
      expect(AppRoutePath.registerPath, '/register');
      expect(AppRoutePath.homePath, '/home');
      expect(AppRoutePath.chatsPath, '/chats');
      expect(AppRoutePath.chatDetailPath, '/chats/:chatId');
    });

    test('les chemins de routes statiques sont uniques', () {
      final paths = [
        AppRoutePath.root,
        AppRoutePath.loginPath,
        AppRoutePath.registerPath,
        AppRoutePath.homePath,
        AppRoutePath.chatsPath,
        AppRoutePath.chatDetailPath,
      ];

      expect(paths.toSet().length, paths.length);
    });

    test('chatDetail construit le chemin avec le bon identifiant', () {
      expect(AppRoutePath.chatDetail('abc123'), '/chats/abc123');
    });

    test('isAuthRoute reconnaît les routes publiques', () {
      expect(AppRoutePath.isAuthRoute(AppRoutePath.root), isTrue);
      expect(AppRoutePath.isAuthRoute(AppRoutePath.loginPath), isTrue);
      expect(AppRoutePath.isAuthRoute(AppRoutePath.registerPath), isTrue);
    });

    test('isAuthRoute rejette les routes protégées', () {
      expect(AppRoutePath.isAuthRoute(AppRoutePath.homePath), isFalse);
      expect(AppRoutePath.isAuthRoute(AppRoutePath.chatsPath), isFalse);
      expect(
        AppRoutePath.isAuthRoute(AppRoutePath.chatDetail('abc123')),
        isFalse,
      );
    });
  });
}
