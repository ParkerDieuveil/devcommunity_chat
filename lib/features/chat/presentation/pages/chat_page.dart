//import 'package:devcommunitychat/features/auth/presentation/providers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatPage extends ConsumerWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //final authState = ref.watch(authControllerProvider);

    return Scaffold(body: const Center(child: Text('Bienvenue dans le chat')));
  }
}
