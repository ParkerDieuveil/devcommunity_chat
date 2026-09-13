import 'package:flutter/material.dart';
import 'profile_icon_container.dart';

// Élement de liste réutilisable pour les paramètres
Widget buildListTile({
  required IconData icon,
  required String title,
  required String subtitle,
  required Widget trailing,
}) {
  return Row(
    children: [
      buildIconContainer(icon),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.white54, fontSize: 11),
            ),
          ],
        ),
      ),
      trailing,
    ],
  );
}
