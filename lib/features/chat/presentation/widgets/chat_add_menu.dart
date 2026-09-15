import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum ChatAddMenuAction { addFriend, createGroup }

/// Dialog « Ajouter un contact / Créer un groupe ».
Future<ChatAddMenuAction?> showChatAddMenu(
  BuildContext context, {
  required String addContactLabel,
  required String createGroupLabel,
}) {
  return showDialog<ChatAddMenuAction>(
    context: context,
    barrierColor: Colors.black54,
    builder: (dialogContext) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: SvgPicture.asset(
                  'assets/logo/User Plus.svg',
                  width: 24,
                  height: 24,
                ),
                title: Text(
                  addContactLabel,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                onTap: () => Navigator.pop(
                  dialogContext,
                  ChatAddMenuAction.addFriend,
                ),
              ),
              ListTile(
                leading: const Icon(
                  Icons.groups_outlined,
                  color: Color(0xFF616161),
                ),
                title: Text(
                  createGroupLabel,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                onTap: () => Navigator.pop(
                  dialogContext,
                  ChatAddMenuAction.createGroup,
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
