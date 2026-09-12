import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_route_path.dart';
import '../providers/auth_controller.dart';
import 'package:devcommunitychat/core/router/navigation_provider.dart';
import '../../../chat/presentation/pages/chat_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import 'home_content.dart';
import '../providers/auth_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actionState = ref.watch(authControllerProvider);
    final user = ref.watch(currentUserProvider);

    final selectedTab = ref.watch(mainTabProvider);
    final selectedIndex = selectedTab.index;

    const pages = [HomeContent(), ChatPage(), ProfilePage()];

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
      body: IndexedStack(index: selectedIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          ref.read(mainTabProvider.notifier).selectTab(MainTab.values[index]);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.chat_outlined),
            selectedIcon: Icon(Icons.chat),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Chat',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
