import 'package:flutter_test/flutter_test.dart';
import 'package:devcommunitychat/core/router/app_route_path.dart';

void main() {
  group('AppRoutePath', () {
    test('expose les chemins de routes attendus', () {
      expect(AppRoutePath.root, '/');
      expect(AppRoutePath.loginPath, '/login');
      expect(AppRoutePath.homePath, '/home');
    });

    test('les chemins de routes sont uniques', () {
      final paths = [
        AppRoutePath.root,
        AppRoutePath.loginPath,
        AppRoutePath.homePath,
      ];

      expect(paths.toSet().length, paths.length);
    });
  });
}
