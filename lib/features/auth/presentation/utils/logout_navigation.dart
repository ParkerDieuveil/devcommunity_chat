import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_route_path.dart';
import '../providers/auth_controller.dart';

/// Déconnexion puis navigation vers login (si un GoRouter est présent).
Future<void> logoutAndGoLogin(WidgetRef ref, BuildContext context) async {
  await ref.read(authControllerProvider.notifier).logout();
  if (!context.mounted) return;
  if (GoRouter.maybeOf(context) != null) {
    context.go(AppRoutePath.loginPath);
  }
}
