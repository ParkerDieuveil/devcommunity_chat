import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../locale/app_strings.dart';
import '../router/navigation_provider.dart';
import '../theme/app_colors.dart';

/// Barre du bas avec encoche centrale pour le FAB « + ».
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
    final inactive = isDark ? const Color(0xFF8A94A6) : const Color(0xFF9AA3AF);

    return BottomAppBar(
      color: barColor,
      elevation: 10,
      shadowColor: Colors.black26,
      shape: const CircularNotchedRectangle(),
      notchMargin: 7,
      padding: EdgeInsets.zero,
      height: 64,
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: _NavItem(
                tab: MainTab.chat,
                label: s.navChats,
                selected: selected == MainTab.chat,
                inactiveColor: inactive,
                badgeCount: chatBadge,
                onTap: () => onSelect(MainTab.chat),
              ),
            ),
            Expanded(
              child: _NavItem(
                tab: MainTab.groups,
                label: s.navGroups,
                selected: selected == MainTab.groups,
                inactiveColor: inactive,
                badgeCount: groupsBadge,
                onTap: () => onSelect(MainTab.groups),
              ),
            ),
            const SizedBox(width: 64),
            Expanded(
              child: _NavItem(
                tab: MainTab.profile,
                label: s.navProfile,
                selected: selected == MainTab.profile,
                inactiveColor: inactive,
                badgeCount: 0,
                onTap: () => onSelect(MainTab.profile),
              ),
            ),
            Expanded(
              child: _NavItem(
                tab: MainTab.more,
                label: s.navMore,
                selected: selected == MainTab.more,
                inactiveColor: inactive,
                badgeCount: 0,
                onTap: () => onSelect(MainTab.more),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// FAB « + » à brancher en `centerDocked` sur le Scaffold.
class ComposeFab extends StatelessWidget {
  const ComposeFab({
    super.key,
    required this.onPressed,
    required this.tooltip,
  });

  final VoidCallback onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: tooltip,
      elevation: 2,
      highlightElevation: 4,
      backgroundColor: isDark ? Colors.white : AppColors.brand,
      foregroundColor: isDark ? AppColors.headerBlue : Colors.white,
      shape: const CircleBorder(),
      child: const Icon(Icons.add, size: 28),
    );
  }
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
    final color = selected ? AppColors.brand : inactiveColor;
    final badgeLabel = badgeCount > 99 ? '99+' : '$badgeCount';

    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                selected ? icons.selectedIcon : icons.icon,
                size: 24,
                color: color,
              ),
              if (badgeCount > 0)
                Positioned(
                  right: -9,
                  top: -5,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 15),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.brand,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      badgeLabel,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: color,
            ),
          ),
        ],
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
