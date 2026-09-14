import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_route_path.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../providers/chat_provider.dart';

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

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final profilesAsync = ref.watch(profilesProvider);

    if (currentUser == null) {
      return const Scaffold(
        body: Center(
          child: Text('Session requise'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouveau chat'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un développeur...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                  onPressed: _searchController.clear,
                  icon: const Icon(Icons.clear),
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          Expanded(
            child: profilesAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
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
                final users = profiles
                    .where((profile) => profile.id != currentUser.id)
                    .where(_matchesSearch)
                    .toList();

                if (users.isEmpty) {
                  return Center(
                    child: Text(
                      _searchQuery.isEmpty
                          ? 'Aucun autre utilisateur disponible'
                          : 'Aucun utilisateur trouvé',
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: users.length,
                  separatorBuilder: (_, _) => const Divider(
                    height: 1,
                  ),
                  itemBuilder: (context, index) {
                    final profile = users[index];

                    return _UserTile(
                      displayName: profile.displayname,
                      email: profile.email,
                      photoUrl: profile.photoUrl,
                      loading: _creatingChatFor == profile.id,
                      onTap: () => _createChat(
                        currentUser.id,
                        profile.id,
                      ),
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

  bool _matchesSearch(dynamic profile) {
    if (_searchQuery.isEmpty) {
      return true;
    }

    final name = profile.displayname.toLowerCase();
    final email = profile.email.toLowerCase();

    return name.contains(_searchQuery) ||
        email.contains(_searchQuery);
  }

  Future<void> _createChat(
      String currentUserId,
      String otherUserId,
      ) async {
    if (_creatingChatFor != null) {
      return;
    }

    setState(() {
      _creatingChatFor = otherUserId;
    });

    try {
      final chatId = await ref
          .read(createChatUseCaseProvider)
          .call([
        currentUserId,
        otherUserId,
      ]);

      if (!mounted) {
        return;
      }

      context.push(
        AppRoutePath.chatDetail(chatId),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Impossible de créer la conversation : $error',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _creatingChatFor = null;
        });
      }
    }
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile({
    required this.displayName,
    required this.email,
    required this.photoUrl,
    required this.loading,
    required this.onTap,
  });

  final String displayName;
  final String email;
  final String photoUrl;
  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final name = displayName.trim().isEmpty
        ? email
        : displayName;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 6,
      ),
      leading: CircleAvatar(
        radius: 24,
        backgroundImage: photoUrl.trim().isNotEmpty
            ? NetworkImage(photoUrl)
            : null,
        child: photoUrl.trim().isEmpty
            ? Text(
          _initial(name),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        )
            : null,
      ),
      title: Text(
        name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        email,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: loading
          ? const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
      )
          : const Icon(Icons.chat_outlined),
      onTap: loading ? null : onTap,
    );
  }

  String _initial(String name) {
    final trimmed = name.trim();

    if (trimmed.isEmpty) {
      return '?';
    }

    return trimmed[0].toUpperCase();
  }
}