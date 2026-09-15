import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/locale/app_strings.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../profile/domain/entities/profile.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../../domain/entities/chat_media_image.dart';
import '../providers/chat_provider.dart';
import '../utils/chat_display.dart';
import '../widgets/chat_attachment_panel.dart';
import '../widgets/chat_conversation_header.dart';
import '../widgets/chat_message_bubble.dart';
import '../widgets/chat_message_input_bar.dart';
import '../widgets/voice_record_sheet.dart';

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
  final _scrollController = ScrollController();
  var _sending = false;
  var _attachmentsOpen = false;
  int? _lastMessageCount;

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
    _scrollController.dispose();
    super.dispose();
  }

  /// Aligné Figma : messages en haut ; on scrolle en bas seulement pour
  /// afficher le dernier message quand la liste dépasse l’écran.
  void _ensureLatestVisible(int messageCount) {
    final shouldFollow =
        _lastMessageCount == null || messageCount > _lastMessageCount!;
    _lastMessageCount = messageCount;
    if (!shouldFollow) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      final max = _scrollController.position.maxScrollExtent;
      if (max <= 0) return;
      _scrollController.jumpTo(max);
    });
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

    setState(() {
      _sending = true;
      _attachmentsOpen = false;
    });
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

  Future<void> _sendImage(ChatMediaPickSource source) async {
    final user = ref.read(currentUserProvider);
    if (user == null || _sending) return;

    final caption = _controller.text.trim();
    setState(() {
      _sending = true;
      _attachmentsOpen = false;
    });
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

  Future<void> _openVoiceRecorder() async {
    setState(() => _attachmentsOpen = false);
    final s = ref.read(appStringsProvider);
    final path = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => VoiceRecordSheet(strings: s),
    );
    if (path == null || !mounted) return;

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() => _sending = true);
    try {
      await ref.read(sendChatAudioUseCaseProvider).call(
            chatId: widget.chatId,
            senderId: user.id,
            localPath: path,
          );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
      try {
        await File(path).delete();
      } catch (_) {}
    }
  }

  void _showComingSoon(String label) {
    final s = ref.read(appStringsProvider);
    setState(() => _attachmentsOpen = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label — ${s.comingSoon}')),
    );
  }

  String _subtitleFor(List<ProfileEntity> others, AppStrings s) {
    if (others.isEmpty) return '';
    if (others.length == 1) return others.first.email;
    return s.participantsCount(others.length + 1);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final s = ref.watch(appStringsProvider);
    final messagesAsync = ref.watch(chatMessagesProvider(widget.chatId));
    final profilesAsync = ref.watch(profilesProvider);
    final chatAsync = ref.watch(chatByIdProvider(widget.chatId));

    ref.listen(chatMessagesProvider(widget.chatId), (previous, next) {
      next.whenData((messages) => _ensureLatestVisible(messages.length));
    });

    final others = chatAsync.maybeWhen(
      data: (chat) {
        if (chat == null || user == null) return <ProfileEntity>[];
        return profilesAsync.maybeWhen(
          data: (profiles) => findOtherProfiles(
            participantIds: chat.participantIds,
            currentUserId: user.id,
            profiles: profiles,
          ),
          orElse: () => <ProfileEntity>[],
        );
      },
      orElse: () => <ProfileEntity>[],
    );

    final title = chatDisplayTitle(
      others,
      emptyFallback: s.userFallback,
      multiFallback: s.groupFallback,
    );
    final subtitle = _subtitleFor(others, s);
    final photoUrl = others.length == 1 ? others.first.photoUrl : '';
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final chatBg =
        isDark ? const Color(0xFF0F1520) : const Color(0xFFF5F7FA);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          ChatConversationHeader(
            pageTitle: s.messagesTitle,
            peerTitle: title,
            peerSubtitle: subtitle,
            photoUrl: photoUrl,
            closeLabel: s.close,
            onBack: () => context.pop(),
          ),
          Expanded(
            child: ColoredBox(
              color: chatBg,
              child: messagesAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(error.toString(), textAlign: TextAlign.center),
                  ),
                ),
                data: (messages) {
                  if (messages.isEmpty) {
                    return Center(
                      child: Text(
                        s.emptyChatPrompt,
                        style: TextStyle(color: colors.onSurfaceVariant),
                      ),
                    );
                  }
                  if (_lastMessageCount == null) {
                    _ensureLatestVisible(messages.length);
                  }
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      return ChatMessageBubble(
                        message: message,
                        mine: message.senderId == user?.id,
                        imageUnavailable: s.imageUnavailable,
                        voiceMessageLabel: s.voiceMessage,
                      );
                    },
                  );
                },
              ),
            ),
          ),
          if (_attachmentsOpen)
            ChatAttachmentPanel(
              enabled: !_sending,
              cameraLabel: s.attachCamera,
              recordLabel: s.attachRecord,
              contactLabel: s.attachContact,
              galleryLabel: s.attachGallery,
              locationLabel: s.attachLocation,
              documentLabel: s.attachDocument,
              onCamera: () => _sendImage(ChatMediaPickSource.camera),
              onRecord: _openVoiceRecorder,
              onContact: () => _showComingSoon(s.attachContact),
              onGallery: () => _sendImage(ChatMediaPickSource.gallery),
              onLocation: () => _showComingSoon(s.attachLocation),
              onDocument: () => _showComingSoon(s.attachDocument),
            ),
          ChatMessageInputBar(
            controller: _controller,
            sending: _sending,
            attachmentsOpen: _attachmentsOpen,
            messageHint: s.messageHint,
            attachmentsTooltip: s.attachments,
            onToggleAttachments: () =>
                setState(() => _attachmentsOpen = !_attachmentsOpen),
            onSend: _sendText,
            onFieldTap: () {
              if (_attachmentsOpen) {
                setState(() => _attachmentsOpen = false);
              }
            },
          ),
        ],
      ),
    );
  }
}
