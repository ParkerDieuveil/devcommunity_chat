import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/locale/app_strings.dart';
import '../../../../core/router/app_route_path.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/profile.dart';
import '../../domain/services/avatar_image_source.dart';
import '../providers/profile_provider.dart';

const _headerBlue = Color(0xFF1565C0);
const _accentBlue = Color(0xFF03A9F4);
const _accentBlueLight = Color(0xFF40C4FF);

class ProfilePage extends ConsumerWidget {
  final ImageProvider<Object> avatarImage;

  const ProfilePage({
    super.key,
    this.avatarImage = const AssetImage('assets/images/photo_profile.jpg'),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final s = ref.watch(appStringsProvider);

    return authState.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) =>
          Scaffold(body: Center(child: Text('Erreur : $error'))),
      data: (user) {
        if (user == null) {
          return Scaffold(
            body: Center(child: Text(s.noUserLoggedIn)),
          );
        }
        return _ProfileBody(user: user, avatarImage: avatarImage);
      },
    );
  }
}

class _ProfileBody extends ConsumerWidget {
  final AppUser user;
  final ImageProvider<Object> avatarImage;

  const _ProfileBody({required this.user, required this.avatarImage});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentUserProfileProvider);
    final salonCountAsync = ref.watch(profileSalonCountProvider);
    final authControllerState = ref.watch(authControllerProvider);
    final s = ref.watch(appStringsProvider);

    final profile = profileAsync.asData?.value;
    final displayName = _resolveDisplayName(user, profile);
    final username = user.email.split('@').first;
    final bio = profile?.bio.trim().isNotEmpty == true
        ? profile!.bio.trim()
        : s.noBioYet;
    final title = profile?.title.trim().isNotEmpty == true
        ? profile!.title.trim()
        : s.defaultMemberTitle;
    final ImageProvider<Object> imageProvider;
    if (profile?.photoUrl.trim().isNotEmpty == true) {
      imageProvider = NetworkImage(profile!.photoUrl);
    } else if (user.photoUrl != null && user.photoUrl!.trim().isNotEmpty) {
      imageProvider = NetworkImage(user.photoUrl!);
    } else {
      imageProvider = avatarImage;
    }

    final salonCount = salonCountAsync.asData?.value;
    final memberSince = _formatMemberSince(profile?.createdAt, s);
    final statusLabel =
        profile?.isOnline == true ? s.statusOnline : s.statusOffline;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          const _ProfileHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
              child: Column(
                children: [
                  _ProfileAvatar(
                    imageProvider: imageProvider,
                    isUploading:
                        ref.watch(profileAvatarControllerProvider).isLoading,
                    onTap: () => _onChangeAvatar(context, ref),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    displayName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (profileAsync.isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else ...[
                    _InfoRow(
                      label: s.labelUsername,
                      value: '@$username',
                      onCopy: () => _copy(context, ref, '@$username'),
                    ),
                    _InfoRow(
                      label: s.labelEmail,
                      value: user.email,
                      onCopy: () => _copy(context, ref, user.email),
                    ),
                    _InfoRow(
                      label: s.labelTitle,
                      value: title,
                      onCopy: () => _copy(context, ref, title),
                    ),
                    _InfoRow(
                      label: s.labelBio,
                      value: bio,
                      onCopy: () => _copy(context, ref, bio),
                    ),
                    _InfoRow(
                      label: s.labelStatus,
                      value: statusLabel,
                      onCopy: () => _copy(context, ref, statusLabel),
                    ),
                    if (memberSince != '—')
                      _InfoRow(
                        label: s.labelMemberSince,
                        value: memberSince,
                        onCopy: () => _copy(context, ref, memberSince),
                      ),
                    if (salonCount != null)
                      _InfoRow(
                        label: s.labelChats,
                        value: '$salonCount',
                        onCopy: () => _copy(context, ref, '$salonCount'),
                      ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton.icon(
                      onPressed: () => _showEditProfileSheet(
                        context,
                        user: user,
                        profile: profile,
                      ),
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: Text(
                        s.editProfile,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: _accentBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton.icon(
                      onPressed: authControllerState.isLoading
                          ? null
                          : () async {
                              await ref
                                  .read(authControllerProvider.notifier)
                                  .logout();
                              if (!context.mounted) return;
                              if (GoRouter.maybeOf(context) != null) {
                                context.go(AppRoutePath.loginPath);
                              }
                            },
                      icon: const Icon(Icons.logout, size: 18),
                      label: Text(
                        s.logout,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFFFEBEE),
                        foregroundColor: const Color(0xFFE53935),
                        disabledForegroundColor:
                            const Color(0xFFE53935).withValues(alpha: 0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Future<void> _copy(
    BuildContext context,
    WidgetRef ref,
    String value,
  ) async {
    final s = ref.read(appStringsProvider);
    await Clipboard.setData(ClipboardData(text: value));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(s.copiedToClipboard),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  static String _resolveDisplayName(AppUser user, ProfileEntity? profile) {
    final fromProfile = profile?.displayname.trim() ?? '';
    if (fromProfile.isNotEmpty) return fromProfile;
    final fromAuth = user.displayName?.trim() ?? '';
    if (fromAuth.isNotEmpty) return fromAuth;
    return user.email.split('@').first;
  }

  static String _formatMemberSince(DateTime? createdAt, AppStrings s) {
    if (createdAt == null) return '—';
    return '${s.monthShort(createdAt.month)} ${createdAt.year}';
  }

  Future<void> _onChangeAvatar(BuildContext context, WidgetRef ref) async {
    final s = ref.read(appStringsProvider);
    final source = await showModalBottomSheet<AvatarPickSource>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: Text(s.pickFromGallery),
                onTap: () =>
                    Navigator.pop(sheetContext, AvatarPickSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: Text(s.takePhoto),
                onTap: () =>
                    Navigator.pop(sheetContext, AvatarPickSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.close),
                title: Text(s.cancel),
                onTap: () => Navigator.pop(sheetContext),
              ),
            ],
          ),
        );
      },
    );

    if (source == null || !context.mounted) return;

    final changed = await ref
        .read(profileAvatarControllerProvider.notifier)
        .changeAvatar(source);

    if (!context.mounted) return;

    final state = ref.read(profileAvatarControllerProvider);
    if (state.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${state.error}')),
      );
      return;
    }

    if (changed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.avatarUpdated)),
      );
    }
  }

  Future<void> _showEditProfileSheet(
    BuildContext context, {
    required AppUser user,
    required ProfileEntity? profile,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _EditProfileSheet(user: user, profile: profile),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _headerBlue,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 56,
          width: double.infinity,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: SvgPicture.asset(
                'assets/logo/chat.svg',
                height: 36,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    required this.onCopy,
  });

  final String label;
  final String value;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                color: colors.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          InkWell(
            onTap: onCopy,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(
                Icons.copy_rounded,
                size: 18,
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  final ImageProvider<Object> imageProvider;
  final bool isUploading;
  final VoidCallback onTap;

  const _ProfileAvatar({
    required this.imageProvider,
    required this.isUploading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _accentBlueLight, width: 3),
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          if (isUploading)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: 0.45),
                ),
                child: const Center(
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            )
          else
            Positioned(
              top: 4,
              right: 4,
              child: Material(
                color: _accentBlue,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onTap,
                  child: const SizedBox(
                    width: 34,
                    height: 34,
                    child: Icon(
                      Icons.edit_outlined,
                      size: 16,
                      color: Colors.white,
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

class _EditProfileSheet extends ConsumerStatefulWidget {
  final AppUser user;
  final ProfileEntity? profile;

  const _EditProfileSheet({required this.user, required this.profile});

  @override
  ConsumerState<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends ConsumerState<_EditProfileSheet> {
  late final TextEditingController nameController;
  late final TextEditingController titleController;
  late final TextEditingController bioController;
  late final TextEditingController emailController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final profile = widget.profile;
    nameController = TextEditingController(
      text: profile?.displayname.trim().isNotEmpty == true
          ? profile!.displayname
          : (widget.user.displayName ?? ''),
    );
    titleController = TextEditingController(text: profile?.title ?? '');
    bioController = TextEditingController(text: profile?.bio ?? '');
    emailController = TextEditingController(text: widget.user.email);
  }

  @override
  void dispose() {
    nameController.dispose();
    titleController.dispose();
    bioController.dispose();
    emailController.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Theme.of(context).colorScheme.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _accentBlue, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final s = ref.watch(appStringsProvider);
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFBDBDBD),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                s.editProfileTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: onSurface,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                textCapitalization: TextCapitalization.words,
                decoration: _fieldDecoration(s.fieldName),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: titleController,
                textCapitalization: TextCapitalization.sentences,
                decoration: _fieldDecoration(s.fieldTitle),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: bioController,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: _fieldDecoration(s.fieldBio),
              ),
              const SizedBox(height: 14),
              TextField(
                enabled: false,
                controller: emailController,
                decoration: _fieldDecoration(s.fieldEmail),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: FilledButton(
                        onPressed:
                            _saving ? null : () => Navigator.of(context).pop(),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFE3F2FD),
                          foregroundColor: _headerBlue,
                          shape: const StadiumBorder(),
                        ),
                        child: Text(
                          s.cancel,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: FilledButton(
                        onPressed: _saving ? null : _save,
                        style: FilledButton.styleFrom(
                          backgroundColor: _accentBlue,
                          foregroundColor: Colors.white,
                          shape: const StadiumBorder(),
                        ),
                        child: _saving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                s.save,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    final s = ref.read(appStringsProvider);
    final name = nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.nameRequired)),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await ref.read(updateProfileProvider).call(
            userId: widget.user.id,
            name: name,
            email: widget.user.email,
            title: titleController.text.trim(),
            bio: bioController.text.trim(),
          );
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(s.profileUpdated)),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${s.profileUpdateFailed} : $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }
}
