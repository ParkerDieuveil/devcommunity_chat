import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../profile/domain/entities/profile.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../../domain/entities/chat_media_image.dart';
import '../../domain/entities/message_entity.dart';
import '../providers/chat_provider.dart';

class ChatMessagesPage extends ConsumerStatefulWidget {
  const ChatMessagesPage({
    super.key,
    required this.chatId,
  });

  final String chatId;

  @override
  ConsumerState<ChatMessagesPage> createState() => _ChatMessagesPageState();
}

class _ChatMessagesPageState extends ConsumerState<ChatMessagesPage> {
  final _controller = TextEditingController();
  var _sending = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _markMessagesAsRead();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _markMessagesAsRead() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    try {
      await ref.read(markMessagesAsReadUseCaseProvider).call(
            chatId: widget.chatId,
            userId: user.id,
          );
    } catch (_) {}
  }

  Future<void> _sendText() async {
    final user = ref.read(currentUserProvider);
    final text = _controller.text.trim();
    if (user == null || text.isEmpty || _sending) return;

    setState(() => _sending = true);
    try {
      await ref.read(sendMessageUseCaseProvider).call(
            chatId: widget.chatId,
            senderId: user.id,
            text: text,
          );
      _controller.clear();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _pickAndSendImage() async {
    final user = ref.read(currentUserProvider);
    if (user == null || _sending) return;

    final source = await showModalBottomSheet<ChatMediaPickSource>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Galerie'),
                onTap: () => Navigator.pop(
                  sheetContext,
                  ChatMediaPickSource.gallery,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Caméra'),
                onTap: () => Navigator.pop(
                  sheetContext,
                  ChatMediaPickSource.camera,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.close),
                title: const Text('Annuler'),
                onTap: () => Navigator.pop(sheetContext),
              ),
            ],
          ),
        );
      },
    );

    if (source == null || !mounted) return;

    final caption = _controller.text.trim();
    setState(() => _sending = true);
    try {
      final sent = await ref.read(sendChatImageUseCaseProvider).call(
            chatId: widget.chatId,
            senderId: user.id,
            source: source,
            caption: caption.isEmpty ? null : caption,
          );
      if (sent && mounted) {
        _controller.clear();
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  String _getOtherUserId(String currentUserId, List<String> participantIds) {
    for (final participantId in participantIds) {
      if (participantId != currentUserId) return participantId;
    }
    return '';
  }

  ProfileEntity? _getOtherProfile({
    required String currentUserId,
    required List<String> participantIds,
    required List<ProfileEntity> profiles,
  }) {
    final otherUserId = _getOtherUserId(currentUserId, participantIds);
    if (otherUserId.isEmpty) return null;
    for (final profile in profiles) {
      if (profile.id == otherUserId) return profile;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final messagesAsync = ref.watch(chatMessagesProvider(widget.chatId));
    final profilesAsync = ref.watch(profilesProvider);
    final chatAsync = ref.watch(chatByIdProvider(widget.chatId));

    return Scaffold(
      appBar: AppBar(
        title: chatAsync.when(
          loading: () => const Text('Chat'),
          error: (_, _) => const Text('Chat'),
          data: (chat) {
            if (chat == null || user == null) return const Text('Chat');
            return profilesAsync.when(
              loading: () => const Text('Chat'),
              error: (_, _) => const Text('Chat'),
              data: (profiles) {
                final profile = _getOtherProfile(
                  currentUserId: user.id,
                  participantIds: chat.participantIds,
                  profiles: profiles,
                );
                return Text(
                  profile?.displayname.isNotEmpty == true
                      ? profile!.displayname
                      : profile?.email.isNotEmpty == true
                          ? profile!.email
                          : 'Utilisateur',
                );
              },
            );
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(error.toString(), textAlign: TextAlign.center),
                ),
              ),
              data: (messages) {
                if (messages.isEmpty) {
                  return const Center(child: Text('Aucun message'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return _MessageBubble(
                      message: message,
                      mine: message.senderId == user?.id,
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _sending ? null : _pickAndSendImage,
                    tooltip: 'Envoyer une image',
                    icon: const Icon(Icons.image_outlined),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      enabled: !_sending,
                      decoration: const InputDecoration(
                        hintText: 'Message ou légende',
                      ),
                      onSubmitted: (_) => _sendText(),
                    ),
                  ),
                  IconButton(
                    onPressed: _sending ? null : _sendText,
                    icon: _sending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.mine,
  });

  final MessageEntity message;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasImage =
        message.imageUrl != null && message.imageUrl!.trim().isNotEmpty;
    final caption = message.text?.trim();

    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.75,
        ),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: mine
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment:
              mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (hasImage)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  message.imageUrl!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return SizedBox(
                      height: 160,
                      child: Center(
                        child: CircularProgressIndicator(
                          value: progress.expectedTotalBytes != null
                              ? progress.cumulativeBytesLoaded /
                                  progress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (_, _, _) => Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      'Image indisponible',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ),
              ),
            if (caption != null && caption.isNotEmpty) ...[
              if (hasImage) const SizedBox(height: 6),
              Text(caption),
            ],
            if (mine) ...[
              const SizedBox(height: 4),
              Icon(
                message.isRead ? Icons.done_all : Icons.done,
                size: 16,
                color: message.isRead
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
