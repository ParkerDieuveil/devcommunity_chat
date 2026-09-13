import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/router/navigation_provider.dart';

class HomeContent extends ConsumerWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () {
          ref.read(mainTabProvider.notifier).selectTab(MainTab.chat);
        },
        icon: const Icon(Icons.chat_outlined),
        label: const Text('Ouvrir le chat'),
      ),
    );
  }
}
