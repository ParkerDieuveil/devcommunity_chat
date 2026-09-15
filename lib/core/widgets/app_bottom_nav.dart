import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../locale/app_strings.dart';
import '../router/navigation_provider.dart';
import '../theme/app_colors.dart';

class AppBottomNav extends ConsumerWidget {
  const AppBottomNav({
    super.key,
    required this.selected,
    required this.onSelect,
    this.chatBadge = 0,
    this.groupsBadge = 0,
  });

  final MainTab selected;
  final ValueChanged<MainTab> onSelect;
  final int chatBadge;
  final int groupsBadge;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(appStringsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final barColor = isDark ? AppColors.navBarDark : Colors.white;
    final inactive = isDark ? const Color(0xFF78909C) : const Color(0xFF90A4AE);

    return Material(
      color: barColor,
      elevation: 8,
      shadowColor: Colors.black26,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Row(
            children: [
              for (final tab in MainTab.values)
                Expanded(
                  child: _NavItem(
                    tab: tab,
                    label: _labelFor(tab, s),
                    selected: tab == selected,
                    inactiveColor: inactive,
                    badgeCount: _badgeFor(tab),
                    onTap: () => onSelect(tab),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  int _badgeFor(MainTab tab) {
    return switch (tab) {
      MainTab.chat => chatBadge,
      MainTab.groups => groupsBadge,
      MainTab.profile || MainTab.more => 0,
    };
  }
}

String _labelFor(MainTab tab, AppStrings s) {
  return switch (tab) {
    MainTab.chat => s.navChats,
    MainTab.groups => s.navGroups,
    MainTab.profile => s.navProfile,
    MainTab.more => s.navMore,
  };
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.tab,
    required this.label,
    required this.selected,
    required this.inactiveColor,
    required this.badgeCount,
    required this.onTap,
  });

  final MainTab tab;
  final String label;
  final bool selected;
  final Color inactiveColor;
  final int badgeCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final icons = _iconsFor(tab);
    final badgeLabel = badgeCount > 99 ? '99+' : '$badgeCount';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        color: selected ? AppColors.brand : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      selected ? icons.selectedIcon : icons.icon,
                      size: 22,
                      color: selected ? Colors.white : inactiveColor,
                    ),
                    if (badgeCount > 0)
                      Positioned(
                        right: -10,
                        top: -6,
                        child: Container(
                          constraints: const BoxConstraints(minWidth: 16),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? Colors.white
                                : AppColors.brand,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            badgeLabel,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: selected
                                  ? AppColors.brand
                                  : Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    color: selected ? Colors.white : inactiveColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavIcons {
  const _NavIcons({
    required this.icon,
    required this.selectedIcon,
  });

  final IconData icon;
  final IconData selectedIcon;
}

_NavIcons _iconsFor(MainTab tab) {
  return switch (tab) {
    MainTab.chat => const _NavIcons(
        icon: Icons.chat_bubble_outline,
        selectedIcon: Icons.chat_bubble,
      ),
    MainTab.groups => const _NavIcons(
        icon: Icons.groups_outlined,
        selectedIcon: Icons.groups,
      ),
    MainTab.profile => const _NavIcons(
        icon: Icons.account_circle_outlined,
        selectedIcon: Icons.account_circle,
      ),
    MainTab.more => const _NavIcons(
        icon: Icons.menu,
        selectedIcon: Icons.menu,
      ),
  };
}
