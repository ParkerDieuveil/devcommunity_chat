import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_route_path.dart';
import '../providers/auth_controller.dart';
import '../providers/auth_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actionState = ref.watch(authControllerProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('DevCommunity Chat'),
        actions: [
          IconButton(
            onPressed: actionState.isLoading
                ? null
                : () {
                    ref.read(authControllerProvider.notifier).logout();
                  },
            icon: const Icon(Icons.logout),
            tooltip: 'Déconnexion',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              user == null
                  ? 'Bienvenue sur DevCommunity Chat'
                  : 'Bienvenue, ${user.displayName ?? user.email}',
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => context.go(AppRoutePath.chatsPath),
              child: const Text('Conversations'),
            ),
          ],
        ),
      ),
    );
  }
}
