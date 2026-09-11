import 'package:devcommunitychat/features/profile/presentation/pages/profile_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/home_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import 'app_route_path.dart';
import 'auth_router_refresh.dart';

final authRouterRefreshProvider = Provider<AuthRouterRefresh>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return AuthRouterRefresh(auth);
});

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  final refresh = ref.watch(authRouterRefreshProvider);

  return GoRouter(
    initialLocation: AppRoutePath.loginPath,
    refreshListenable: refresh,
    redirect: (context, state) {
      final isLoggedIn = auth.currentUser != null;
      final currentPath = state.uri.path;

      final isAuthRoute = AppRoutePath.isAuthRoute(currentPath);

      if (!isLoggedIn && !isAuthRoute) {
        return AppRoutePath.loginPath;
      }

      if (isLoggedIn && isAuthRoute) {
        return AppRoutePath.homePath;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutePath.loginPath,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutePath.registerPath,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: AppRoutePath.homePath,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: AppRoutePath.profilePath,
        builder: (context, state) => const ProfilePage(),
      ),
    ],
  );
});
