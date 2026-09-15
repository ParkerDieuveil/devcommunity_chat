import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/locale/app_strings.dart';
import '../../../../core/router/app_route_path.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_secondary_header.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../profile/domain/entities/profile.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../providers/chat_provider.dart';
import '../utils/chat_display.dart';
import '../widgets/add_members_sheet.dart';

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
        return AddMembersSheet(
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
          AppSecondaryHeader(
            title: s.createGroup,
            onBack: () => context.pop(),
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
                        color: AppColors.brandSurfaceAlt,
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
                                    color: AppColors.brand,
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
                                  final name =
                                      profile.displayname.trim().isEmpty
                                          ? profile.email
                                          : profile.displayname;
                                  return ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: CircleAvatar(
                                      backgroundImage: profile.photoUrl
                                              .trim()
                                              .isNotEmpty
                                          ? NetworkImage(profile.photoUrl)
                                          : null,
                                      child: profile.photoUrl.trim().isEmpty
                                          ? Text(nameInitial(name))
                                          : null,
                                    ),
                                    title: Text(name),
                                    subtitle: Text(profile.email),
                                    trailing: IconButton(
                                      onPressed: () {
                                        setState(
                                          () =>
                                              _selectedById.remove(profile.id),
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.close,
                                        color: AppColors.danger,
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
                            backgroundColor: AppColors.brand,
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
