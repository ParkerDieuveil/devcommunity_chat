import 'package:flutter/material.dart';

/// Bouton circulaire (retour / menu) pour les en-têtes de conversation.
class RoundIconButton extends StatelessWidget {
  const RoundIconButton({
    super.key,
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1E2738) : Colors.white;
    final iconColor = Theme.of(context).colorScheme.onSurface;

    return Material(
      color: bg,
      elevation: 2,
      shadowColor: Colors.black26,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(icon, size: 22, color: iconColor),
        ),
      ),
    );
  }
}
