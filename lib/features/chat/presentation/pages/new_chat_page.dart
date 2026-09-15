import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/locale/app_strings.dart';
import '../../../../core/router/app_route_path.dart';
import '../../../../core/widgets/app_secondary_header.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../profile/domain/entities/profile.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../providers/chat_provider.dart';
import '../widgets/chat_list_tile.dart';
import '../widgets/user_contact_tile.dart';

/// Recherche d'un contact par email (ou nom) pour démarrer un chat 1:1.
class NewChatPage extends ConsumerStatefulWidget {
  const NewChatPage({super.key});

  @override
  ConsumerState<NewChatPage> createState() => _NewChatPageState();
}

class _NewChatPageState extends ConsumerState<NewChatPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _creatingChatFor;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _matchesSearch(ProfileEntity profile) {
    if (_searchQuery.isEmpty) return false;
    final name = profile.displayname.toLowerCase();
    final email = profile.email.toLowerCase();
    return email.contains(_searchQuery) || name.contains(_searchQuery);
  }

  Future<void> _createChat(String currentUserId, String otherUserId) async {
    if (_creatingChatFor != null) return;

    setState(() => _creatingChatFor = otherUserId);

    try {
      final chatId = await ref.read(createChatUseCaseProvider).call([
        currentUserId,
        otherUserId,
      ]);
      if (!mounted) return;
      context.push(AppRoutePath.chatDetail(chatId));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Impossible de créer la conversation : $error'),
        ),
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
      return Scaffold(
        body: Center(child: Text(s.sessionRequired)),
      );
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
                suffixIcon: _searchQuery.isNotEmpty
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
                    'Impossible de charger les utilisateurs.\n\n$error',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              data: (profiles) {
                if (_searchQuery.isEmpty) {
                  return SearchEmptyIllustration(
                    message: s.searchEmailPrompt,
                    size: 220,
                  );
                }

                final users = profiles
                    .where((p) => p.id != currentUser.id)
                    .where(_matchesSearch)
                    .toList();

                if (users.isEmpty) {
                  return SearchEmptyIllustration(
                    message: s.noUsersFound(_searchQuery),
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
                      loading: _creatingChatFor == profile.id,
                      startChatTooltip: s.startChat,
                      onTap: () => _createChat(currentUser.id, profile.id),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
