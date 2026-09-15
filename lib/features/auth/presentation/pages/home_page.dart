import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:devcommunitychat/core/router/app_route_path.dart';
import 'package:devcommunitychat/core/router/navigation_provider.dart';
import 'package:devcommunitychat/core/router/root_navigator_key.dart';
import 'package:devcommunitychat/core/widgets/app_bottom_nav.dart';
import '../../../chat/presentation/pages/chats_page.dart';
import '../../../chat/presentation/pages/groups_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../providers/auth_provider.dart';
import 'more_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    // Session coupée (logout) : filet vers /login via la clé racine
    // (évite GoRouterState.of sur un contexte déjà hors route).
    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final navContext = rootNavigatorKey.currentContext;
        if (navContext == null) return;
        GoRouter.of(navContext).go(AppRoutePath.loginPath);
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final selectedTab = ref.watch(mainTabProvider);
    final selectedIndex = selectedTab.index;

    const pages = [
      ChatsPage(),
      GroupsPage(),
      ProfilePage(),
      MorePage(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: AppBottomNav(
        selected: selectedTab,
        onSelect: (tab) {
          ref.read(mainTabProvider.notifier).selectTab(tab);
        },
      ),
    );
  }
}
