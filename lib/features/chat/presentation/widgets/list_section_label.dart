import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class ListSectionLabel extends StatelessWidget {
  const ListSectionLabel(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
          color: AppColors.brand.withValues(alpha: 0.9),
        ),
      ),
    );
  }
}
