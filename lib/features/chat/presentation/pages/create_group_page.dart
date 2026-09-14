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
const _accentBlue = Color(0xFF03A9F4);

class CreateGroupPage extends ConsumerStatefulWidget {
  const CreateGroupPage({super.key});

  @override
  ConsumerState<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends ConsumerState<CreateGroupPage> {
  final _nameController = TextEditingController();
  final _selectedById = <String, ProfileEntity>{};
  var _creating = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickMembers(List<ProfileEntity> candidates) async {
    final s = ref.read(appStringsProvider);
    final picked = await showModalBottomSheet<Map<String, ProfileEntity>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return _AddMembersSheet(
          candidates: candidates,
          initiallySelectedIds: _selectedById.keys.toSet(),
          strings: s,
        );
      },
    );

    if (picked != null && mounted) {
      setState(() {
        _selectedById
          ..clear()
          ..addAll(picked);
      });
    }
  }

  Future<void> _createGroup() async {
    final user = ref.read(currentUserProvider);
    final s = ref.read(appStringsProvider);
    if (user == null || _creating) return;

    if (_selectedById.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.groupMinMembers)),
      );
      return;
    }

    setState(() => _creating = true);
    try {
      final participantIds = [
        user.id,
        ..._selectedById.keys,
      ];
      final chatId =
          await ref.read(createChatUseCaseProvider).call(participantIds);
      if (!mounted) return;
      context.push(AppRoutePath.chatDetail(chatId));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Impossible de créer le groupe : $error')),
      );
    } finally {
      if (mounted) setState(() => _creating = false);
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
                        s.createGroup,
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
          Expanded(
            child: profilesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('$error')),
              data: (profiles) {
                final candidates = profiles
                    .where((p) => p.id != currentUser.id)
                    .toList();

                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        s.groupNameLabel,
                        style: const TextStyle(color: Color(0xFF9E9E9E)),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: s.groupNameHint,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        s.membersLabel,
                        style: const TextStyle(color: Color(0xFF9E9E9E)),
                      ),
                      const SizedBox(height: 8),
                      Material(
                        color: const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => _pickMembers(candidates),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                  'assets/logo/User Plus.svg',
                                  width: 22,
                                  height: 22,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  s.addMembers,
                                  style: const TextStyle(
                                    color: _accentBlue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: _selectedById.isEmpty
                            ? Center(
                                child: Text(
                                  s.noMembersSelected,
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                              )
                            : ListView.separated(
                                itemCount: _selectedById.length,
                                separatorBuilder: (_, _) =>
                                    const Divider(height: 1),
                                itemBuilder: (context, index) {
                                  final profile =
                                      _selectedById.values.elementAt(index);
                                  final name = profile.displayname.trim().isEmpty
                                      ? profile.email
                                      : profile.displayname;
                                  return ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: CircleAvatar(
                                      backgroundImage: profile
                                              .photoUrl
                                              .trim()
                                              .isNotEmpty
                                          ? NetworkImage(profile.photoUrl)
                                          : null,
                                      child: profile.photoUrl.trim().isEmpty
                                          ? Text(name[0].toUpperCase())
                                          : null,
                                    ),
                                    title: Text(name),
                                    subtitle: Text(profile.email),
                                    trailing: IconButton(
                                      onPressed: () {
                                        setState(
                                          () => _selectedById.remove(profile.id),
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.close,
                                        color: Color(0xFFE53935),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 52,
                        child: FilledButton(
                          onPressed: _creating ? null : _createGroup,
                          style: FilledButton.styleFrom(
                            backgroundColor: _accentBlue,
                            shape: const StadiumBorder(),
                          ),
                          child: _creating
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  s.createGroupButton,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AddMembersSheet extends StatefulWidget {
  const _AddMembersSheet({
    required this.candidates,
    required this.initiallySelectedIds,
    required this.strings,
  });

  final List<ProfileEntity> candidates;
  final Set<String> initiallySelectedIds;
  final AppStrings strings;

  @override
  State<_AddMembersSheet> createState() => _AddMembersSheetState();
}

class _AddMembersSheetState extends State<_AddMembersSheet> {
  late final Set<String> _selectedIds;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedIds = {...widget.initiallySelectedIds};
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.strings;
    final query = _searchController.text.trim().toLowerCase();
    final filtered = widget.candidates.where((p) {
      if (query.isEmpty) return true;
      return p.email.toLowerCase().contains(query) ||
          p.displayname.toLowerCase().contains(query);
    }).toList();

    final height = MediaQuery.sizeOf(context).height * 0.75;

    return SizedBox(
      height: height,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFBDBDBD),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              s.addMembers,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: s.searchByEmail,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: SvgPicture.asset(
                        'assets/logo/Card Search.svg',
                        width: 160,
                        height: 160,
                      ),
                    )
                  : ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final profile = filtered[index];
                        final selected = _selectedIds.contains(profile.id);
                        final name = profile.displayname.trim().isEmpty
                            ? profile.email
                            : profile.displayname;
                        return CheckboxListTile(
                          value: selected,
                          activeColor: _accentBlue,
                          controlAffinity: ListTileControlAffinity.trailing,
                          secondary: CircleAvatar(
                            backgroundImage: profile.photoUrl.trim().isNotEmpty
                                ? NetworkImage(profile.photoUrl)
                                : null,
                            child: profile.photoUrl.trim().isEmpty
                                ? Text(name[0].toUpperCase())
                                : null,
                          ),
                          title: Text(
                            name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(profile.email),
                          onChanged: (value) {
                            setState(() {
                              if (value == true) {
                                _selectedIds.add(profile.id);
                              } else {
                                _selectedIds.remove(profile.id);
                              }
                            });
                          },
                        );
                      },
                    ),
            ),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFE3F2FD),
                      foregroundColor: _headerBlue,
                      shape: const StadiumBorder(),
                    ),
                    child: Text(s.cancel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      final selected = <String, ProfileEntity>{
                        for (final p in widget.candidates)
                          if (_selectedIds.contains(p.id)) p.id: p,
                      };
                      Navigator.pop(context, selected);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: _accentBlue,
                      shape: const StadiumBorder(),
                    ),
                    child: Text(s.add),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
