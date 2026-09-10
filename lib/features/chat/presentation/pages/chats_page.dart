import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_route_path.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/chat_entity.dart';
import '../providers/chat_provider.dart';

class ChatsPage extends ConsumerWidget {
  const ChatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Session requise')),
      );
    }

    final chatsAsync = ref.watch(userChatsProvider(user.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversations'),
        actions: [
          IconButton(
            tooltip: 'Nouveau chat (outil de test)',
            onPressed: () => _openNewChatTestDialog(context, ref, user.id),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: chatsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              error.toString(),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (chats) {
          if (chats.isEmpty) {
            return const Center(
              child: Text('Aucune conversation'),
            );
          }

          return ListView.separated(
            itemCount: chats.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final chat = chats[index];
              return _ChatTile(chat: chat, currentUserId: user.id);
            },
          );
        },
      ),
    );
  }

  Future<void> _openNewChatTestDialog(
    BuildContext context,
    WidgetRef ref,
    String currentUserId,
  ) async {
    final controller = TextEditingController();

    final otherUid = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nouveau chat (test)'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Outil de test uniquement : colle le uid Firebase Auth du destinataire.',
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'uid destinataire',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: const Text('Créer'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (otherUid == null || otherUid.isEmpty || !context.mounted) {
      return;
    }

    try {
      final chatId = await ref.read(createChatUseCaseProvider).call([
        currentUserId,
        otherUid,
      ]);
      if (!context.mounted) return;
      context.push(AppRoutePath.chatDetail(chatId));
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }
}

class _ChatTile extends StatelessWidget {
  const _ChatTile({
    required this.chat,
    required this.currentUserId,
  });

  final ChatEntity chat;
  final String currentUserId;

  @override
  Widget build(BuildContext context) {
    final others = chat.participantIds
        .where((id) => id != currentUserId)
        .join(', ');

    return ListTile(
      title: Text(others.isEmpty ? chat.chatId : others),
      subtitle: Text(chat.lastMessage ?? 'Aucun message'),
      onTap: () => context.push(AppRoutePath.chatDetail(chat.chatId)),
    );
  }
}
