import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_format.dart';
import '../../domain/entities/message_entity.dart';

/// Bulle de message (texte / image / audio).
class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({
    super.key,
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
        ? AppColors.brand
        : (isDark ? AppColors.surfaceElevatedDark : Colors.white);
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
