import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_logo_header.dart';

/// Header Chats : logo + actions, ou champ recherche.
class ChatsHeader extends StatelessWidget {
  const ChatsHeader({
    super.key,
    required this.searching,
    required this.searchController,
    required this.searchHint,
    required this.searchTooltip,
    required this.addTooltip,
    required this.onToggleSearch,
    required this.onSearchChanged,
    required this.onAdd,
  });

  final bool searching;
  final TextEditingController searchController;
  final String searchHint;
  final String searchTooltip;
  final String addTooltip;
  final VoidCallback onToggleSearch;
  final VoidCallback onSearchChanged;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    if (!searching) {
      return AppLogoHeader(
        actions: [
          IconButton(
            tooltip: searchTooltip,
            onPressed: onToggleSearch,
            icon: const Icon(Icons.search, color: Colors.white),
          ),
          IconButton(
            tooltip: addTooltip,
            onPressed: onAdd,
            icon: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      );
    }

    return ColoredBox(
      color: AppColors.headerBlue,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 56,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    autofocus: true,
                    onChanged: (_) => onSearchChanged(),
                    style: const TextStyle(fontSize: 15),
                    decoration: InputDecoration(
                      hintText: searchHint,
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 0,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: onToggleSearch,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white24,
                  ),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
