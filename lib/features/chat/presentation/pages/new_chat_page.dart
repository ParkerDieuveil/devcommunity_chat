import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/locale/app_strings.dart';
import '../../../../core/router/app_route_path.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../profile/domain/entities/profile.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../providers/chat_provider.dart';

const _headerBlue = Color(0xFF1565C0);

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
          ColoredBox(
            color: _headerBlue,
            child: SafeArea(
              bottom: false,
              child: SizedBox(
                height: 56,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white24,
                      ),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    Expanded(
                      child: Text(
                        s.addContact,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
            ),
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
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            'assets/logo/Card Search.svg',
                            width: 220,
                            height: 220,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            s.searchEmailPrompt,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final users = profiles
                    .where((p) => p.id != currentUser.id)
                    .where(_matchesSearch)
                    .toList();

                if (users.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            'assets/logo/Card Search.svg',
                            width: 180,
                            height: 180,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            s.noUsersFound(_searchQuery),
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: users.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final profile = users[index];
                    return _UserTile(
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

class _UserTile extends StatelessWidget {
  const _UserTile({
    required this.displayName,
    required this.email,
    required this.photoUrl,
    required this.loading,
    required this.startChatTooltip,
    required this.onTap,
  });

  final String displayName;
  final String email;
  final String photoUrl;
  final bool loading;
  final String startChatTooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final name = displayName.trim().isEmpty ? email : displayName;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: CircleAvatar(
        radius: 24,
        backgroundImage:
            photoUrl.trim().isNotEmpty ? NetworkImage(photoUrl) : null,
        child: photoUrl.trim().isEmpty
            ? Text(
                _initial(name),
                style: const TextStyle(fontWeight: FontWeight.bold),
              )
            : null,
      ),
      title: Text(
        name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w600),
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
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : IconButton(
              onPressed: onTap,
              tooltip: startChatTooltip,
              icon: SvgPicture.asset(
                'assets/logo/User Plus.svg',
                width: 24,
                height: 24,
              ),
            ),
      onTap: loading ? null : onTap,
    );
  }

  String _initial(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    return trimmed[0].toUpperCase();
  }
}
