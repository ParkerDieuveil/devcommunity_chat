import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../../../../core/locale/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/widgets/online_avatar.dart';
import '../../../profile/domain/entities/profile.dart';
import '../../domain/entities/message_entity.dart';
import '../utils/chat_display.dart';

/// Bulle de message (texte / image / audio) style Messenger / WhatsApp.
class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({
    super.key,
    required this.message,
    required this.mine,
    required this.isGroup,
    required this.profiles,
    required this.strings,
    required this.imageUnavailable,
    required this.voiceMessageLabel,
    this.seenFaces = const [],
  });

  final MessageEntity message;
  final bool mine;
  final bool isGroup;
  final List<ProfileEntity> profiles;
  final AppStrings strings;
  final String imageUnavailable;
  final String voiceMessageLabel;

  /// Mini-avatars « vu par » (dernier message lu par chaque personne).
  final List<ProfileEntity> seenFaces;

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
    final seen = message.isRead;

    // Couleurs type messagerie : brand pour moi, surface douce pour les autres.
    final bubbleColor = mine
        ? (isDark ? const Color(0xFF0277BD) : AppColors.brand)
        : (isDark ? AppColors.surfaceElevatedDark : const Color(0xFFF0F2F5));
    final textColor = mine ? Colors.white : colors.onSurface;
    final metaColor = mine
        ? Colors.white.withValues(alpha: 0.8)
        : colors.onSurfaceVariant;
    final readCheckColor = mine
        ? (seen ? const Color(0xFF81D4FA) : metaColor)
        : colors.onSurfaceVariant;

    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onLongPress: mine ? () => _showReceiptsSheet(context) : null,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.sizeOf(context).width * 0.78,
              ),
              margin: EdgeInsets.only(
                top: 4,
                bottom: seenFaces.isEmpty ? 4 : 2,
              ),
              padding: const EdgeInsets.fromLTRB(12, 10, 10, 6),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(mine ? 18 : 4),
                  bottomRight: Radius.circular(mine ? 4 : 18),
                ),
                border: mine
                    ? null
                    : Border.all(
                        color: isDark
                            ? AppColors.borderDark
                            : AppColors.borderSubtle,
                        width: 0.6,
                      ),
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
                      borderRadius: BorderRadius.circular(12),
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
                                color: mine ? Colors.white : AppColors.brand,
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
                        fontSize: 15.5,
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
                          seen ? Icons.done_all : Icons.done,
                          size: 16,
                          color: readCheckColor,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (mine && seenFaces.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 2, bottom: 6),
              child: _SeenFacesRow(
                faces: seenFaces,
                onTap: () => _showReceiptsSheet(context),
              ),
            ),
        ],
      ),
    );
  }

  void _showReceiptsSheet(BuildContext context) {
    final seenIds = message.seenByOtherIds();
    final readers = <ProfileEntity>[];
    for (final id in seenIds) {
      for (final p in profiles) {
        if (p.id == id) {
          readers.add(p);
          break;
        }
      }
    }

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                  child: Text(
                    isGroup ? strings.seenByTitle : strings.messageSeen,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (!message.isRead)
                  ListTile(
                    leading: Icon(
                      Icons.done,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    title: Text(strings.notSeenYet),
                    subtitle: Text(strings.messageSent),
                  )
                else if (!isGroup)
                  ListTile(
                    leading: const Icon(
                      Icons.done_all,
                      color: AppColors.brand,
                    ),
                    title: Text(strings.messageSeen),
                    subtitle: Text(strings.messageDelivered),
                  )
                else if (readers.isEmpty)
                  ListTile(
                    leading: const Icon(
                      Icons.done_all,
                      color: AppColors.brand,
                    ),
                    title: Text(strings.messageSeen),
                    subtitle: Text('${seenIds.length}'),
                  )
                else
                  ...readers.map((profile) {
                    final name = profile.displayname.trim().isNotEmpty
                        ? profile.displayname
                        : profile.email;
                    final at = message.readBy[profile.id];
                    return ListTile(
                      leading: OnlineAvatar(
                        radius: 20,
                        photoUrl: profile.photoUrl,
                        initials: nameInitial(name),
                        isOnline: profile.isEffectivelyOnline,
                      ),
                      title: Text(name),
                      subtitle: at == null
                          ? null
                          : Text(formatMessageTime(at)),
                    );
                  }),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Mini-avatars style Messenger sous le dernier message lu.
class _SeenFacesRow extends StatelessWidget {
  const _SeenFacesRow({
    required this.faces,
    required this.onTap,
  });

  final List<ProfileEntity> faces;
  final VoidCallback onTap;

  static const _maxVisible = 3;

  @override
  Widget build(BuildContext context) {
    final visible = faces.take(_maxVisible).toList();
    final extra = faces.length - visible.length;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < visible.length; i++) ...[
              if (i > 0) const SizedBox(width: 2),
              OnlineAvatar(
                radius: 8,
                photoUrl: visible[i].photoUrl,
                initials: nameInitial(
                  visible[i].displayname.trim().isNotEmpty
                      ? visible[i].displayname
                      : visible[i].email,
                ),
                isOnline: visible[i].isEffectivelyOnline,
                showPresence: false,
              ),
            ],
            if (extra > 0) ...[
              const SizedBox(width: 4),
              Text(
                '+$extra',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
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
    final iconColor = widget.mine ? Colors.white : AppColors.brand;
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
