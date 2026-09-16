import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/locale/app_strings.dart';
import '../../../../core/widgets/app_secondary_header.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../profile/domain/entities/profile.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../utils/chat_actions.dart';
import '../utils/chat_search.dart';
import '../widgets/chat_list_tile.dart';
import '../widgets/invite_not_registered_card.dart';
import '../widgets/user_contact_tile.dart';

/// Recherche d'un contact par email (ou nom) pour démarrer un chat 1:1.
class NewChatPage extends ConsumerStatefulWidget {
  const NewChatPage({super.key});

  @override
  ConsumerState<NewChatPage> createState() => _NewChatPageState();
}

class _NewChatPageState extends ConsumerState<NewChatPage> {
  final _searchController = TextEditingController();
  String _query = '';
  String? _creatingChatFor;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _startChat(String currentUserId, String otherUserId) async {
    if (_creatingChatFor != null) return;
    setState(() => _creatingChatFor = otherUserId);
    try {
      await openOrCreateDirectChat(
        context: context,
        ref: ref,
        currentUserId: currentUserId,
        otherUserId: otherUserId,
      );
    } finally {
      if (mounted) setState(() => _creatingChatFor = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final profilesAsync = ref.watch(profilesProvider);
    final s = ref.watch(appStringsProvider);

    if (currentUser == null) {
      return Scaffold(body: Center(child: Text(s.sessionRequired)));
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          AppSecondaryHeader(
            title: s.addContact,
            onBack: () => context.pop(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: TextField(
              controller: _searchController,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              decoration: InputDecoration(
                hintText: s.searchByEmail,
                prefixIcon: const Icon(Icons.email_outlined),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        onPressed: _searchController.clear,
                        icon: const Icon(Icons.clear),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          Expanded(
            child: profilesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    '${s.loadUsersFailed}.\n\n$error',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              data: (profiles) => _NewChatResults(
                query: _query,
                strings: s,
                users: profiles
                    .where((p) => p.id != currentUser.id)
                    .where((p) => _query.isNotEmpty && matchesProfile(p, _query))
                    .toList(),
                creatingChatFor: _creatingChatFor,
                onStartChat: (id) => _startChat(currentUser.id, id),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NewChatResults extends StatelessWidget {
  const _NewChatResults({
    required this.query,
    required this.strings,
    required this.users,
    required this.creatingChatFor,
    required this.onStartChat,
  });

  final String query;
  final AppStrings strings;
  final List<ProfileEntity> users;
  final String? creatingChatFor;
  final ValueChanged<String> onStartChat;

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) {
      return SearchEmptyIllustration(
        message: strings.searchEmailPrompt,
        size: 220,
      );
    }

    if (users.isEmpty) {
      if (looksLikeEmail(query)) {
        return InviteNotRegisteredCard(query: query, strings: strings);
      }
      return SearchEmptyIllustration(
        message: strings.noUsersFound(query),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: users.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final profile = users[index];
        return UserContactTile(
          displayName: profile.displayname,
          email: profile.email,
          photoUrl: profile.photoUrl,
          loading: creatingChatFor == profile.id,
          startChatTooltip: strings.startChat,
          onTap: () => onStartChat(profile.id),
        );
      },
    );
  }
}
