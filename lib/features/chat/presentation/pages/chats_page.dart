import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/locale/app_strings.dart';
import '../../../../core/widgets/empty_list_placeholder.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../profile/domain/entities/profile.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../../domain/entities/chat_entity.dart';
import '../providers/chat_provider.dart';
import '../utils/chat_actions.dart';
import '../utils/chat_search.dart';
import '../widgets/chats_body.dart';
import '../widgets/chats_header.dart';

class ChatsPage extends ConsumerStatefulWidget {
  const ChatsPage({super.key});

  @override
  ConsumerState<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends ConsumerState<ChatsPage> {
  var _searching = false;
  final _searchController = TextEditingController();
  String? _creatingChatFor;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _searching = !_searching;
      if (!_searching) _searchController.clear();
    });
  }

  Future<void> _openContact(String userId, String otherUserId) async {
    if (_creatingChatFor != null) return;
    setState(() => _creatingChatFor = otherUserId);
    try {
      await openOrCreateDirectChat(
        context: context,
        ref: ref,
        currentUserId: userId,
        otherUserId: otherUserId,
      );
    } finally {
      if (mounted) setState(() => _creatingChatFor = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final s = ref.watch(appStringsProvider);

    if (user == null) {
      return Scaffold(body: Center(child: Text(s.sessionRequired)));
    }

    final chatsAsync = ref.watch(userChatsProvider(user.id));
    final profilesAsync = ref.watch(profilesProvider);
    final query = _searchController.text.trim().toLowerCase();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          ChatsHeader(
            searching: _searching,
            searchController: _searchController,
            searchHint: s.search,
            searchTooltip: s.search,
            onToggleSearch: _toggleSearch,
            onSearchChanged: () => setState(() {}),
          ),
          Expanded(
            child: _FadeSlideBody(
              child: chatsAsync.when(
                loading: () => const _CenteredLoader(key: ValueKey('loading')),
                error: (e, _) => _CenteredError(e, key: const ValueKey('error')),
                data: (chats) => profilesAsync.when(
                  loading: () =>
                      const _CenteredLoader(key: ValueKey('profiles-loading')),
                  error: (e, _) =>
                      _CenteredError(e, key: const ValueKey('profiles-error')),
                  data: (profiles) => _ChatsContent(
                    key: ValueKey(query.isEmpty ? 'list' : 'search'),
                    chats: chats,
                    profiles: profiles,
                    userId: user.id,
                    query: query,
                    strings: s,
                    creatingChatFor: _creatingChatFor,
                    onCompose: () => openChatComposeMenu(context, ref),
                    onOpenContact: (id) => _openContact(user.id, id),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatsContent extends StatelessWidget {
  const _ChatsContent({
    super.key,
    required this.chats,
    required this.profiles,
    required this.userId,
    required this.query,
    required this.strings,
    required this.creatingChatFor,
    required this.onCompose,
    required this.onOpenContact,
  });

  final List<ChatEntity> chats;
  final List<ProfileEntity> profiles;
  final String userId;
  final String query;
  final AppStrings strings;
  final String? creatingChatFor;
  final VoidCallback onCompose;
  final ValueChanged<String> onOpenContact;

  @override
  Widget build(BuildContext context) {
    if (query.isNotEmpty) {
      return ChatsSearchResults(
        result: searchChatsAndContacts(
          chats: chats,
          profiles: profiles,
          userId: userId,
          query: query,
          userFallback: strings.userFallback,
          groupFallback: strings.groupFallback,
        ),
        profiles: profiles,
        userId: userId,
        query: query,
        strings: strings,
        creatingChatFor: creatingChatFor,
        onOpenContact: onOpenContact,
      );
    }

    if (chats.isEmpty) {
      return EmptyListPlaceholder(
        icon: Icons.forum_outlined,
        title: strings.emptyChatsTitle,
        subtitle: strings.emptyChatsSubtitle,
        buttonLabel: strings.newChat,
        onAction: onCompose,
      );
    }

    return ChatsConversationList(
      chats: chats,
      profiles: profiles,
      userId: userId,
      strings: strings,
    );
  }
}

class _FadeSlideBody extends StatelessWidget {
  const _FadeSlideBody({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.03),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class _CenteredLoader extends StatelessWidget {
  const _CenteredLoader({super.key});

  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator());
}

class _CenteredError extends StatelessWidget {
  const _CenteredError(this.error, {super.key});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text('$error', textAlign: TextAlign.center),
      ),
    );
  }
}
