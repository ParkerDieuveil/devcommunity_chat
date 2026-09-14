import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'navigation_provider.dart';
import '../widgets/app_bottom_nav.dart';

class MainNavigationScreen extends ConsumerWidget {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(mainTabProvider);

    final pages = [
      for (final tab in MainTab.values)
        Center(child: Text(tab.name)),
    ];

    return Scaffold(
      body: IndexedStack(index: selectedTab.index, children: pages),
      bottomNavigationBar: AppBottomNav(
        selected: selectedTab,
        onSelect: (tab) {
          ref.read(mainTabProvider.notifier).selectTab(tab);
        },
      ),
    );
  }
}
