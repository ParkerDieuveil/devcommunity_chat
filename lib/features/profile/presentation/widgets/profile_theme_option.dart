import 'package:flutter/material.dart';

class ProfileThemeOption extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onSelected;

  const ProfileThemeOption({
    super.key,
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Expanded(
      child: GestureDetector(
        onTap: onSelected,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? colors.primary.withValues(alpha: 0.18)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isSelected ? colors.primary : Colors.transparent,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 14,
                color: isSelected ? colors.primary : colors.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color:
                        isSelected ? colors.primary : colors.onSurfaceVariant,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
