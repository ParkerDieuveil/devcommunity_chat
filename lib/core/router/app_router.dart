import 'package:devcommunitychat/features/profile/presentation/pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/home_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/chat/presentation/pages/chat_messages_page.dart';
import '../../features/chat/presentation/pages/chats_page.dart';
import '../../features/chat/presentation/pages/create_group_page.dart';
import '../../features/chat/presentation/pages/new_chat_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/onboarding/presentation/pages/splash_page.dart';
import '../../features/onboarding/presentation/providers/onboarding_provider.dart';
import 'app_route_path.dart';
import 'auth_router_refresh.dart';

final authRouterRefreshProvider = Provider<AuthRouterRefresh>((ref) {
  final refresh = AuthRouterRefresh();

  // Relance le redirect à chaque changement de session (pas seulement au boot).
  ref.listen(authStateProvider, (previous, next) => refresh.notify());
  ref.listen(onboardingCompletedProvider, (previous, next) => refresh.notify());

  ref.onDispose(refresh.dispose);
  return refresh;
});

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ref.watch(authRouterRefreshProvider);

  return GoRouter(
    initialLocation: AppRoutePath.splashPath,
    refreshListenable: refresh,
    redirect: (context, state) {
      // read (pas watch) : évite de recréer GoRouter à chaque tick auth.
      final user = ref.read(currentUserProvider);
      final onboardingDone = ref.read(onboardingCompletedProvider);
      final isLoggedIn = user != null;
      final currentPath = state.uri.path;

      if (currentPath == AppRoutePath.splashPath) {
        return null;
      }

      if (currentPath == AppRoutePath.bootContinuePath) {
        if (isLoggedIn) return AppRoutePath.homePath;
        if (!onboardingDone) return AppRoutePath.onboardingPath;
        return AppRoutePath.loginPath;
      }

      if (currentPath == AppRoutePath.onboardingPath) {
        if (isLoggedIn) return AppRoutePath.homePath;
        if (onboardingDone) return AppRoutePath.loginPath;
        return null;
      }

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
        path: AppRoutePath.splashPath,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutePath.bootContinuePath,
        builder: (context, state) => const SizedBox.shrink(),
      ),
      GoRoute(
        path: AppRoutePath.onboardingPath,
        builder: (context, state) => const OnboardingPage(),
      ),
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
      GoRoute(
        path: AppRoutePath.chatsPath,
        builder: (context, state) => const ChatsPage(),
      ),
      GoRoute(
        path: AppRoutePath.newChatPath,
        builder: (context, state) => const NewChatPage(),
      ),
      GoRoute(
        path: AppRoutePath.createGroupPath,
        builder: (context, state) => const CreateGroupPage(),
      ),
      GoRoute(
        path: AppRoutePath.chatDetailPath,
        builder: (context, state) {
          final chatId = state.pathParameters['chatId']!;
          return ChatMessagesPage(chatId: chatId);
        },
      ),
    ],
  );
});
