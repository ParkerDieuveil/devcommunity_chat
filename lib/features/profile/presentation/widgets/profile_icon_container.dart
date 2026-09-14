import 'package:flutter/material.dart';

class ProfileIconContainer extends StatelessWidget {
  final IconData icon;

  const ProfileIconContainer(this.icon, {super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: colors.primary, size: 20),
    );
  }
}
