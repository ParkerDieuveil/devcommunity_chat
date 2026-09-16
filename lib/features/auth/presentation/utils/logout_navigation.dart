import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_route_path.dart';
import '../../../../core/router/root_navigator_key.dart';
import '../providers/auth_controller.dart';

/// Déconnexion puis navigation vers login.
///
/// N'utilise pas le [BuildContext] de la page Plus/Profil : dès que Firebase
/// émet `user == null`, [HomePage] se reconstruit et ce contexte est démonté.
Future<void> logoutAndGoLogin(WidgetRef ref, BuildContext context) async {
  await ref.read(authControllerProvider.notifier).logout();

  void goLogin() {
    final navContext = rootNavigatorKey.currentContext;
    if (navContext != null) {
      GoRouter.of(navContext).go(AppRoutePath.loginPath);
      return;
    }
    if (context.mounted) {
      GoRouter.maybeOf(context)?.go(AppRoutePath.loginPath);
    }
  }

  // Microtask (pas Timer) : OK pour les widget tests, et laisse le stream auth
  // se propager avant la navigation.
  await Future<void>.microtask(goLogin);
}
