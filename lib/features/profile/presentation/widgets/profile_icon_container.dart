import 'package:flutter/material.dart';

// Container de fond pour les icônes à gauche
Widget buildIconContainer(IconData icon) {
  return Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: const Color(0xFF0B1120),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Icon(icon, color: Colors.cyanAccent, size: 20),
  );
}
