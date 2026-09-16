import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/locale/app_strings.dart';
import '../../../../core/router/app_route_path.dart';
import '../providers/chat_provider.dart';
import '../widgets/chat_add_menu.dart';

/// Menu « + » : nouveau contact ou groupe.
Future<void> openChatComposeMenu(BuildContext context, WidgetRef ref) async {
  final s = ref.read(appStringsProvider);
  final action = await showChatAddMenu(
    context,
    addContactLabel: s.addContact,
    createGroupLabel: s.createGroup,
  );

  if (!context.mounted || action == null) return;

  switch (action) {
    case ChatAddMenuAction.addFriend:
      context.push(AppRoutePath.newChatPath);
    case ChatAddMenuAction.createGroup:
      context.push(AppRoutePath.createGroupPath);
  }
}

/// Ouvre le chat 1-1 existant, ou le crée s'il n'existe pas encore.
Future<void> openOrCreateDirectChat({
  required BuildContext context,
  required WidgetRef ref,
  required String currentUserId,
  required String otherUserId,
}) async {
  final s = ref.read(appStringsProvider);

  try {
    final chatId = await ref.read(createChatUseCaseProvider).call([
      currentUserId,
      otherUserId,
    ]);
    if (!context.mounted) return;
    context.push(AppRoutePath.chatDetail(chatId));
  } catch (error) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${s.createChatFailed} : $error')),
    );
  }
}
