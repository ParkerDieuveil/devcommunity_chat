import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

import '../../../../core/locale/app_strings.dart';
import '../../../../core/utils/date_format.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../profile/domain/entities/profile.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../../domain/entities/chat_media_image.dart';
import '../../domain/entities/message_entity.dart';
import '../providers/chat_provider.dart';

const _accentBlue = Color(0xFF03A9F4);

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
      builder: (_) => _VoiceRecordSheet(strings: s),
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

  List<ProfileEntity> _otherProfiles({
    required String currentUserId,
    required List<String> participantIds,
    required List<ProfileEntity> profiles,
  }) {
    final result = <ProfileEntity>[];
    for (final id in participantIds) {
      if (id == currentUserId) continue;
      for (final profile in profiles) {
        if (profile.id == id) {
          result.add(profile);
          break;
        }
      }
    }
    return result;
  }

  String _titleFor(List<ProfileEntity> others, AppStrings s) {
    if (others.isEmpty) return s.userFallback;
    if (others.length == 1) {
      final name = others.first.displayname.trim();
      if (name.isNotEmpty) return name;
      final email = others.first.email.trim();
      return email.isNotEmpty ? email : s.userFallback;
    }
    final names = others
        .map((p) {
          final name = p.displayname.trim();
          return name.isNotEmpty ? name : p.email.split('@').first;
        })
        .where((n) => n.isNotEmpty)
        .take(3)
        .join(', ');
    return names.isEmpty ? s.groupFallback : names;
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
          data: (profiles) => _otherProfiles(
            currentUserId: user.id,
            participantIds: chat.participantIds,
            profiles: profiles,
          ),
          orElse: () => <ProfileEntity>[],
        );
      },
      orElse: () => <ProfileEntity>[],
    );

    final title = _titleFor(others, s);
    final subtitle = _subtitleFor(others, s);
    final photoUrl = others.length == 1 ? others.first.photoUrl : '';
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final chatBg =
        isDark ? const Color(0xFF0F1520) : const Color(0xFFF5F7FA);
    final inputBarBg = isDark ? const Color(0xFF121826) : Colors.white;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
                  child: Row(
                    children: [
                      _RoundIconButton(
                        icon: Icons.arrow_back,
                        onTap: () => context.pop(),
                      ),
                      Expanded(
                        child: Text(
                          s.messagesTitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: colors.onSurface,
                          ),
                        ),
                      ),
                      _RoundIconButton(
                        icon: Icons.more_horiz,
                        onTap: () {
                          showModalBottomSheet<void>(
                            context: context,
                            showDragHandle: true,
                            builder: (sheetContext) {
                              return SafeArea(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      leading: const Icon(Icons.info_outline),
                                      title: Text(title),
                                      subtitle: subtitle.isEmpty
                                          ? null
                                          : Text(subtitle),
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.close),
                                      title: Text(s.close),
                                      onTap: () =>
                                          Navigator.pop(sheetContext),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundImage: photoUrl.trim().isNotEmpty
                            ? NetworkImage(photoUrl)
                            : null,
                        child: photoUrl.trim().isEmpty
                            ? Text(
                                title.isNotEmpty
                                    ? title[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: colors.onSurface,
                              ),
                            ),
                            if (subtitle.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                subtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: colors.outlineVariant),
              ],
            ),
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
                      return _MessageBubble(
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
            _AttachmentPanel(
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
          SafeArea(
            top: false,
            child: Container(
              color: inputBarBg,
              padding: const EdgeInsets.fromLTRB(8, 10, 12, 10),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _sending
                        ? null
                        : () => setState(
                              () => _attachmentsOpen = !_attachmentsOpen,
                            ),
                    tooltip: s.attachments,
                    icon: Icon(
                      _attachmentsOpen ? Icons.close : Icons.add,
                      color: _accentBlue,
                      size: 28,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      enabled: !_sending,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendText(),
                      onTap: () {
                        if (_attachmentsOpen) {
                          setState(() => _attachmentsOpen = false);
                        }
                      },
                      decoration: InputDecoration(
                        hintText: s.messageHint,
                        hintStyle: TextStyle(color: colors.onSurfaceVariant),
                        filled: true,
                        fillColor: isDark
                            ? const Color(0xFF1A2233)
                            : const Color(0xFFF0F2F5),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(28),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: _sending ? null : _sendText,
                    child: SizedBox(
                      width: 52,
                      height: 52,
                      child: _sending
                          ? const Center(
                              child: SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: _accentBlue,
                                ),
                              ),
                            )
                          : SvgPicture.asset(
                              'assets/logo/Button Md.svg',
                              width: 52,
                              height: 52,
                            ),
                    ),
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

class _AttachmentPanel extends StatelessWidget {
  const _AttachmentPanel({
    required this.enabled,
    required this.cameraLabel,
    required this.recordLabel,
    required this.contactLabel,
    required this.galleryLabel,
    required this.locationLabel,
    required this.documentLabel,
    required this.onCamera,
    required this.onRecord,
    required this.onContact,
    required this.onGallery,
    required this.onLocation,
    required this.onDocument,
  });

  final bool enabled;
  final String cameraLabel;
  final String recordLabel;
  final String contactLabel;
  final String galleryLabel;
  final String locationLabel;
  final String documentLabel;
  final VoidCallback onCamera;
  final VoidCallback onRecord;
  final VoidCallback onContact;
  final VoidCallback onGallery;
  final VoidCallback onLocation;
  final VoidCallback onDocument;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final panelBg = isDark ? const Color(0xFF121826) : Colors.white;
    final tileBg = isDark
        ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.18)
        : const Color(0xFFE8F7FD);
    final labelColor = Theme.of(context).colorScheme.onSurfaceVariant;

    final items = <({IconData icon, String label, VoidCallback onTap})>[
      (icon: Icons.photo_camera_outlined, label: cameraLabel, onTap: onCamera),
      (icon: Icons.mic_none_rounded, label: recordLabel, onTap: onRecord),
      (icon: Icons.person_outline, label: contactLabel, onTap: onContact),
      (icon: Icons.image_outlined, label: galleryLabel, onTap: onGallery),
      (
        icon: Icons.location_on_outlined,
        label: locationLabel,
        onTap: onLocation,
      ),
      (
        icon: Icons.description_outlined,
        label: documentLabel,
        onTap: onDocument,
      ),
    ];

    return Container(
      width: double.infinity,
      color: panelBg,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: panelBg,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, -2),
            ),
          ],
          border: Border.all(
            color: isDark ? const Color(0xFF263041) : const Color(0xFFEEF1F5),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: 14,
            crossAxisSpacing: 8,
            childAspectRatio: 1.05,
            children: [
              for (final item in items)
                InkWell(
                  onTap: enabled ? item.onTap : null,
                  borderRadius: BorderRadius.circular(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: tileBg,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(item.icon, color: _accentBlue, size: 26),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: labelColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VoiceRecordSheet extends StatefulWidget {
  const _VoiceRecordSheet({required this.strings});

  final AppStrings strings;

  @override
  State<_VoiceRecordSheet> createState() => _VoiceRecordSheetState();
}

class _VoiceRecordSheetState extends State<_VoiceRecordSheet> {
  AudioRecorder? _recorder;
  Timer? _timer;
  var _seconds = 0;
  var _recording = false;
  var _busy = false;
  String? _error;

  AppStrings get _s => widget.strings;

  AudioRecorder _requireRecorder() {
    return _recorder ??= AudioRecorder();
  }

  @override
  void dispose() {
    _timer?.cancel();
    final recorder = _recorder;
    if (recorder != null) {
      unawaited(recorder.dispose());
    }
    super.dispose();
  }

  String get _clock {
    final m = (_seconds ~/ 60).toString().padLeft(2, '0');
    final s = (_seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _toggleRecord() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      final recorder = _requireRecorder();
      if (_recording) {
        _timer?.cancel();
        final path = await recorder.stop();
        if (!mounted) return;
        setState(() => _recording = false);
        if (path == null || _seconds < 1) {
          setState(() => _error = _s.voiceTooShort);
          return;
        }
        Navigator.pop(context, path);
        return;
      }

      final mic = await Permission.microphone.request();
      if (!mic.isGranted) {
        setState(() => _error = _s.micPermissionRequired);
        return;
      }

      if (!await recorder.hasPermission()) {
        setState(() => _error = _s.micUnavailable);
        return;
      }

      final dir = await getTemporaryDirectory();
      final path =
          '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await recorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: path,
      );

      _seconds = 0;
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        setState(() => _seconds += 1);
      });
      setState(() => _recording = true);
    } on MissingPluginException {
      setState(() => _error = _s.micPluginMissing);
    } catch (error) {
      setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _cancel() async {
    _timer?.cancel();
    final recorder = _recorder;
    if (recorder != null && await recorder.isRecording()) {
      final path = await recorder.stop();
      if (path != null) {
        try {
          await File(path).delete();
        } catch (_) {}
      }
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _s.voiceMessage,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _recording ? _s.voiceTapToSend : _s.voiceTapToRecord,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _clock,
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red.shade700, fontSize: 13),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: _busy ? null : _cancel,
                  child: Text(_s.cancel),
                ),
                Material(
                  color: _recording ? Colors.redAccent : _accentBlue,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: _busy ? null : _toggleRecord,
                    child: SizedBox(
                      width: 72,
                      height: 72,
                      child: Icon(
                        _recording ? Icons.stop_rounded : Icons.mic,
                        color: Colors.white,
                        size: 34,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 72),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1E2738) : Colors.white;
    final iconColor = Theme.of(context).colorScheme.onSurface;

    return Material(
      color: bg,
      elevation: 2,
      shadowColor: Colors.black26,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(icon, size: 22, color: iconColor),
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.mine,
    required this.imageUnavailable,
    required this.voiceMessageLabel,
  });

  final MessageEntity message;
  final bool mine;
  final String imageUnavailable;
  final String voiceMessageLabel;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasImage =
        message.imageUrl != null && message.imageUrl!.trim().isNotEmpty;
    final hasAudio =
        message.audioUrl != null && message.audioUrl!.trim().isNotEmpty;
    final caption = message.text?.trim();
    final time = formatMessageTime(message.timestamp);

    final bubbleColor = mine
        ? _accentBlue
        : (isDark ? const Color(0xFF1E2738) : Colors.white);
    final textColor = mine ? Colors.white : colors.onSurface;
    final metaColor = mine
        ? Colors.white.withValues(alpha: 0.85)
        : colors.onSurfaceVariant;

    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.78,
        ),
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(mine ? 16 : 4),
            bottomRight: Radius.circular(mine ? 4 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (hasAudio)
              _AudioMessagePlayer(
                url: message.audioUrl!,
                mine: mine,
              ),
            if (hasImage)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
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
                          color: mine ? Colors.white : _accentBlue,
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
                      imageUnavailable,
                      style: TextStyle(color: textColor),
                    ),
                  ),
                ),
              ),
            if (caption != null && caption.isNotEmpty) ...[
              if (hasImage || hasAudio) const SizedBox(height: 6),
              Text(
                caption,
                style: TextStyle(
                  color: textColor,
                  fontSize: 15,
                  height: 1.35,
                ),
              ),
            ],
            if (!hasAudio &&
                !hasImage &&
                (caption == null || caption.isEmpty) &&
                message.type == MessageType.audio)
              Text(
                voiceMessageLabel,
                style: TextStyle(color: textColor, fontSize: 15),
              ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time,
                  style: TextStyle(color: metaColor, fontSize: 11),
                ),
                if (mine) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message.isRead ? Icons.done_all : Icons.done,
                    size: 14,
                    color: metaColor,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AudioMessagePlayer extends StatefulWidget {
  const _AudioMessagePlayer({
    required this.url,
    required this.mine,
  });

  final String url;
  final bool mine;

  @override
  State<_AudioMessagePlayer> createState() => _AudioMessagePlayerState();
}

class _AudioMessagePlayerState extends State<_AudioMessagePlayer> {
  late final AudioPlayer _player;
  var _playing = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _player.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() => _playing = state == PlayerState.playing);
    });
    _player.onDurationChanged.listen((d) {
      if (!mounted) return;
      setState(() => _duration = d);
    });
    _player.onPositionChanged.listen((p) {
      if (!mounted) return;
      setState(() => _position = p);
    });
    _player.onPlayerComplete.listen((_) {
      if (!mounted) return;
      setState(() {
        _playing = false;
        _position = Duration.zero;
      });
    });
  }

  @override
  void dispose() {
    unawaited(_player.dispose());
    super.dispose();
  }

  Future<void> _toggle() async {
    if (_playing) {
      await _player.pause();
      return;
    }
    if (_position > Duration.zero && _position < _duration) {
      await _player.resume();
      return;
    }
    await _player.play(UrlSource(widget.url));
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = widget.mine ? Colors.white : _accentBlue;
    final trackColor = widget.mine
        ? Colors.white.withValues(alpha: 0.35)
        : Colors.grey.shade300;
    final progress = _duration.inMilliseconds == 0
        ? 0.0
        : (_position.inMilliseconds / _duration.inMilliseconds).clamp(0.0, 1.0);

    return SizedBox(
      width: 180,
      child: Row(
        children: [
          InkWell(
            onTap: _toggle,
            customBorder: const CircleBorder(),
            child: Icon(
              _playing ? Icons.pause_circle_filled : Icons.play_circle_filled,
              color: iconColor,
              size: 36,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 4,
                    backgroundColor: trackColor,
                    color: iconColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_fmt(_position)} / ${_fmt(_duration)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: widget.mine
                        ? Colors.white.withValues(alpha: 0.9)
                        : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
