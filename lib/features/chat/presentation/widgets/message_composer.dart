import 'package:flutter/material.dart';

class MessageComposer extends StatefulWidget {
  final Function(String) onSubmitted;

  const MessageComposer({
    super.key,
    required this.onSubmitted,
  });

  @override
  State<MessageComposer> createState() => _MessageComposerState();
}

class _MessageComposerState extends State<MessageComposer> {
  final _controller = TextEditingController();
  bool _isComposing = false;

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      widget.onSubmitted(text);
      _controller.clear();
      setState(() {
        _isComposing = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      color: theme.colorScheme.surface,
      child: SafeArea(
        child: Row(
          children: [
            // 📎 Bouton pièce jointe
            IconButton(
              icon: const Icon(Icons.attach_file),
              color: theme.colorScheme.outline,
              onPressed: () {},
            ),

            //  Champ de texte principal
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _controller,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: 'Message...',
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                  onChanged: (text) {
                    setState(() {
                      _isComposing = text.trim().isNotEmpty;
                    });
                  },
                  onSubmitted: (_) => _handleSend(),
                ),
              ),
            ),

            const SizedBox(width: 6),

            //  Bouton d'envoi
            IconButton.filled(
              icon: const Icon(Icons.send, size: 18),
              onPressed: _isComposing ? _handleSend : null,
            ),
          ],
        ),
      ),
    );
  }
}