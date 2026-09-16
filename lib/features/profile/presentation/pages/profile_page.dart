import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/locale/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_logo_header.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/utils/logout_navigation.dart';
import '../../domain/entities/profile.dart';
import '../../domain/services/avatar_image_source.dart';
import '../providers/profile_provider.dart';
import '../widgets/edit_profile_sheet.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/profile_info_row.dart';

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
          return Scaffold(body: Center(child: Text(s.noUserLoggedIn)));
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
    final statusLabel = profile?.isEffectivelyOnline == true
        ? s.statusOnline
        : s.statusOffline;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          const AppLogoHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
              child: Column(
                children: [
                  ProfileAvatar(
                    imageProvider: imageProvider,
                    isUploading: ref
                        .watch(profileAvatarControllerProvider)
                        .isLoading,
                    onTap: () => _onChangeAvatar(context, ref),
                    isOnline: profile?.isEffectivelyOnline == true,
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
                    ProfileInfoRow(
                      label: s.labelUsername,
                      value: '@$username',
                      onCopy: () => _copy(context, ref, '@$username'),
                    ),
                    ProfileInfoRow(
                      label: s.labelEmail,
                      value: user.email,
                      onCopy: () => _copy(context, ref, user.email),
                    ),
                    ProfileInfoRow(
                      label: s.labelTitle,
                      value: title,
                      onCopy: () => _copy(context, ref, title),
                    ),
                    ProfileInfoRow(
                      label: s.labelBio,
                      value: bio,
                      onCopy: () => _copy(context, ref, bio),
                    ),
                    ProfileInfoRow(
                      label: s.labelStatus,
                      value: statusLabel,
                      valueColor: profile?.isEffectivelyOnline == true
                          ? AppColors.online
                          : null,
                      onCopy: () => _copy(context, ref, statusLabel),
                    ),
                    if (memberSince != '—')
                      ProfileInfoRow(
                        label: s.labelMemberSince,
                        value: memberSince,
                        onCopy: () => _copy(context, ref, memberSince),
                      ),
                    if (salonCount != null)
                      ProfileInfoRow(
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
                        backgroundColor: AppColors.brand,
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
                          : () => logoutAndGoLogin(ref, context),
                      icon: const Icon(Icons.logout, size: 18),
                      label: Text(
                        s.logout,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.dangerSurface,
                        foregroundColor: AppColors.danger,
                        disabledForegroundColor: AppColors.danger.withValues(
                          alpha: 0.5,
                        ),
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${state.error}')));
      return;
    }

    if (changed) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(s.avatarUpdated)));
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
      builder: (_) => EditProfileSheet(user: user, profile: profile),
    );
  }
}
