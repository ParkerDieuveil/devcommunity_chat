import 'package:flutter/material.dart';

/// Couleurs de marque partagées (évite les hex dupliqués dans les pages).
abstract final class AppColors {
  static const brand = Color(0xFF03A9F4);
  static const brandLight = Color(0xFF40C4FF);
  static const headerBlue = Color(0xFF1565C0);
  static const danger = Color(0xFFE53935);
  static const dangerSurface = Color(0xFFFFEBEE);
  static const brandSurface = Color(0xFFE8F7FD);
  static const brandSurfaceAlt = Color(0xFFE3F2FD);
  static const sheetHandle = Color(0xFFBDBDBD);
  static const navBarDark = Color(0xFF121826);
  static const scaffoldDark = Color(0xFF0B0F19);
}
