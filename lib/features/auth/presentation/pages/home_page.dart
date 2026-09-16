import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:devcommunitychat/core/locale/app_strings.dart';
import 'package:devcommunitychat/core/router/app_route_path.dart';
import 'package:devcommunitychat/core/router/navigation_provider.dart';
import 'package:devcommunitychat/core/router/root_navigator_key.dart';
import 'package:devcommunitychat/core/widgets/app_bottom_nav.dart';
import '../../../chat/presentation/pages/chats_page.dart';
import '../../../chat/presentation/pages/groups_page.dart';
import '../../../chat/presentation/providers/chat_provider.dart';
import '../../../chat/presentation/utils/chat_actions.dart';
import '../../../chat/presentation/utils/chat_search.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../providers/auth_provider.dart';
import 'more_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

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
    final s = ref.watch(appStringsProvider);
    final chats =
        ref.watch(userChatsProvider(user.id)).asData?.value ?? const [];

    return Scaffold(
      body: IndexedStack(
        index: selectedTab.index,
        children: const [
          ChatsPage(),
          GroupsPage(),
          ProfilePage(),
          MorePage(),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: ComposeFab(
        tooltip: s.add,
        onPressed: () => openChatComposeMenu(context, ref),
      ),
      bottomNavigationBar: AppBottomNav(
        selected: selectedTab,
        chatBadge: unreadTotal(chats, user.id, groupsOnly: false),
        groupsBadge: unreadTotal(chats, user.id, groupsOnly: true),
        onSelect: (tab) => ref.read(mainTabProvider.notifier).selectTab(tab),
      ),
    );
  }
}
