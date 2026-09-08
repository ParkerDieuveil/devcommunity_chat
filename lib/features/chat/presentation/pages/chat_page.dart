import 'package:flutter/material.dart';
import '../../domain/entities/chat_message.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_composer.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // Liste de messages de démonstration
  final List<ChatMessage> _messages = [
    ChatMessage(
      id: '1',
      text: 'Bienvenue sur le chat DevCommunity ! ',
      senderName: 'Alice',
      timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
      isMine: false,
    ),
    ChatMessage(
      id: '2',
      text: 'Super ! L\'interface au style Telegram prend forme.',
      senderName: 'Moi',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      isMine: true,
    ),
  ];

  void _handleSendMessage(String text) {
    setState(() {
      _messages.add(
        ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: text,
          senderName: 'Moi',
          timestamp: DateTime.now(),
          isMine: true,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'DevCommunity Chat',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '2 membres, 1 en ligne',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Liste des messages
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return MessageBubble(message: _messages[index]);
              },
            ),
          ),

          // Zone de saisie en bas de l'écran
          MessageComposer(
            onSubmitted: _handleSendMessage,
          ),
        ],
      ),
    );
  }
}