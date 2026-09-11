import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_controller.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('DevCommunity Chat'),
        actions: [
          IconButton(
            onPressed: authState.isLoading
                ? null
                : () {
              ref
                  .read(authControllerProvider.notifier)
                  .logout();
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Déconnexion',
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Bienvenue sur DevCommunity Chat',
        ),
      ),
    );
  }
}