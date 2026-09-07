import 'package:devcommunitychat/features/auth/presentation/pages/login_page.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/home_page.dart';
import 'app_route_path.dart';

class AppRouter {
  static final GoRouter _routerBase = GoRouter(
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

  static GoRouter get routerBase => _routerBase;
}




