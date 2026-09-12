import 'app_user.dart';

class Message {
  final String id;
  final String content;
  final AppUser sender;
  final DateTime timestamp;

  const Message({
    required this.id,
    required this.content,
    required this.sender,
    required this.timestamp,
  });
}