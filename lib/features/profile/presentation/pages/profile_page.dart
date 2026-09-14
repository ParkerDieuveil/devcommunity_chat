import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_info.dart';
import '../../../../core/theme/theme_mode_controller.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/profile.dart';
import '../../domain/services/avatar_image_source.dart';
import '../providers/profile_provider.dart';
import '../widgets/profile_icon_container.dart';
import '../widgets/profile_liste_tile.dart';
import '../widgets/profile_stat_tile.dart';
import '../widgets/profile_theme_option.dart';

class ProfilePage extends ConsumerWidget {
  final ImageProvider<Object> avatarImage;

  const ProfilePage({
    super.key,
    this.avatarImage = const AssetImage('assets/images/photo_profile.jpg'),
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        body: Center(child: Text('Erreur : $error')),
      ),
      data: (user) {
        if (user == null) {
          return const Scaffold(
            body: Center(child: Text('Aucun utilisateur connecté')),
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

  const _ProfileBody({
    required this.user,
    required this.avatarImage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final profileAsync = ref.watch(currentUserProfileProvider);
    final salonCountAsync = ref.watch(profileSalonCountProvider);
    final themeMode = ref.watch(themeModeProvider);
    final authControllerState = ref.watch(authControllerProvider);

    final profile = profileAsync.asData?.value;
    final displayName = _resolveDisplayName(user, profile);
    final username = user.email.split('@').first;
    final bio = profile?.bio.trim().isNotEmpty == true
        ? profile!.bio.trim()
        : 'Aucune bio pour le moment.';
    final title = profile?.title.trim().isNotEmpty == true
        ? profile!.title.trim()
        : 'Membre DevCommunity';
    final pushEnabled = profile?.pushNotificationsEnabled ?? true;
    final ImageProvider<Object> imageProvider;
    if (profile?.photoUrl.trim().isNotEmpty == true) {
      imageProvider = NetworkImage(profile!.photoUrl);
    } else if (user.photoUrl != null && user.photoUrl!.trim().isNotEmpty) {
      imageProvider = NetworkImage(user.photoUrl!);
    } else {
      imageProvider = avatarImage;
    }

    final salonLabel = salonCountAsync.when(
      data: (count) => '$count',
      loading: () => '…',
      error: (_, _) => '—',
    );
    final memberSince = _formatMemberSince(profile?.createdAt);
    final statusLabel = profile?.isOnline == true ? 'En ligne' : 'Hors ligne';
    final statusColor =
        profile?.isOnline == true ? Colors.greenAccent.shade400 : colors.outline;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(12),
          child: Container(
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.badge_outlined,
              color: colors.primary,
              size: 20,
            ),
          ),
        ),
        title: const Text(
          'Mon Profil',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Center(
              child: Column(
                children: [
                  _ProfileAvatar(
                    imageProvider: imageProvider,
                    isUploading: ref.watch(profileAvatarControllerProvider).isLoading,
                    onTap: () => _onChangeAvatar(context, ref),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          displayName,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (profile?.isOnline == true) ...[
                        const SizedBox(width: 6),
                        Icon(
                          Icons.verified,
                          color: colors.primary,
                          size: 18,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  _Chip(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '@$username',
                            style: TextStyle(
                              color: colors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          TextSpan(
                            text: ' • $title',
                            style: TextStyle(
                              color: colors.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  _Chip(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.email_outlined,
                          size: 14,
                          color: colors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            user.email,
                            style: TextStyle(
                              color: colors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (profileAsync.isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  else
                    Text(
                      bio,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      ProfileStatTile(value: salonLabel, label: 'Salons'),
                      const SizedBox(width: 8),
                      ProfileStatTile(
                        value: memberSince,
                        label: 'Membre',
                        valueColor: colors.primary,
                      ),
                      const SizedBox(width: 8),
                      ProfileStatTile(
                        value: statusLabel,
                        label: 'Statut',
                        valueColor: statusColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showEditProfileDialog(
                        context,
                        user: user,
                        profile: profile,
                      ),
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: const Text('Modifier mon profil'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'PARAMÈTRES & PRÉFÉRENCES',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const ProfileIconContainer(Icons.notifications_outlined),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Notifications push',
                              style: theme.textTheme.bodyMedium,
                            ),
                            Text(
                              'Alertes mentions et DM directs',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: pushEnabled,
                        onChanged: profileAsync.isLoading
                            ? null
                            : (value) => _onPushNotificationsChanged(
                                  ref,
                                  userId: user.id,
                                  enabled: value,
                                  context: context,
                                ),
                      ),
                    ],
                  ),
                  Divider(height: 24, color: colors.outlineVariant),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const ProfileIconContainer(Icons.palette_outlined),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Thème de l\'application',
                              style: theme.textTheme.bodyMedium,
                            ),
                            Text(
                              'Appliqué à toute l\'application',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: colors.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  ProfileThemeOption(
                                    title: 'Sombre',
                                    icon: Icons.nightlight_round,
                                    isSelected: themeMode == ThemeMode.dark,
                                    onSelected: () => ref
                                        .read(themeModeProvider.notifier)
                                        .setThemeMode(ThemeMode.dark),
                                  ),
                                  ProfileThemeOption(
                                    title: 'Clair',
                                    icon: Icons.wb_sunny_outlined,
                                    isSelected: themeMode == ThemeMode.light,
                                    onSelected: () => ref
                                        .read(themeModeProvider.notifier)
                                        .setThemeMode(ThemeMode.light),
                                  ),
                                  ProfileThemeOption(
                                    title: 'Système',
                                    icon: Icons.settings_outlined,
                                    isSelected: themeMode == ThemeMode.system,
                                    onSelected: () => ref
                                        .read(themeModeProvider.notifier)
                                        .setThemeMode(ThemeMode.system),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Divider(height: 24, color: colors.outlineVariant),
                  ProfileListTile(
                    icon: Icons.info_outline,
                    title: 'À propos de DevCommunity',
                    subtitle: AppInfo.buildLabel,
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        AppInfo.versionLabel,
                        style: TextStyle(
                          color: colors.primary,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: authControllerState.isLoading
                    ? null
                    : () => ref.read(authControllerProvider.notifier).logout(),
                icon: Icon(
                  Icons.logout,
                  color: colors.error,
                  size: 18,
                ),
                label: Text(
                  'Déconnexion',
                  style: TextStyle(
                    color: colors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.errorContainer,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Session chiffrée active • ${DateTime.now().year} ${AppInfo.name}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant.withValues(alpha: 0.7),
                  fontSize: 11,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
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

  static String _formatMemberSince(DateTime? createdAt) {
    if (createdAt == null) return '—';
    const months = <String>[
      'janv.',
      'févr.',
      'mars',
      'avr.',
      'mai',
      'juin',
      'juil.',
      'août',
      'sept.',
      'oct.',
      'nov.',
      'déc.',
    ];
    return '${months[createdAt.month - 1]} ${createdAt.year}';
  }

  Future<void> _onPushNotificationsChanged(
    WidgetRef ref, {
    required String userId,
    required bool enabled,
    required BuildContext context,
  }) async {
    try {
      await ref.read(updatePushNotificationsProvider).call(
            userId: userId,
            enabled: enabled,
          );
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Impossible de sauver la préférence : $error')),
        );
      }
    }
  }

  Future<void> _onChangeAvatar(BuildContext context, WidgetRef ref) async {
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
                title: const Text('Choisir depuis la galerie'),
                onTap: () => Navigator.pop(
                  sheetContext,
                  AvatarPickSource.gallery,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Prendre une photo'),
                onTap: () => Navigator.pop(
                  sheetContext,
                  AvatarPickSource.camera,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.close),
                title: const Text('Annuler'),
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
        const SnackBar(content: Text('Photo de profil mise à jour.')),
      );
    }
  }

  Future<void> _showEditProfileDialog(
    BuildContext context, {
    required AppUser user,
    required ProfileEntity? profile,
  }) {
    return showDialog<void>(
      context: context,
      builder: (_) => _EditProfileDialog(user: user, profile: profile),
    );
  }
}

class _Chip extends StatelessWidget {
  final Widget child;

  const _Chip({required this.child});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
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
    final colors = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: isUploading ? null : onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 104,
            height: 104,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: colors.primary, width: 2),
            ),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: CircleAvatar(
                radius: 48,
                backgroundImage: imageProvider,
              ),
            ),
          ),
          if (isUploading)
            Container(
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.scrim.withValues(alpha: 0.45),
              ),
              child: const Center(
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
              ),
            )
          else
            Positioned(
              right: 4,
              bottom: 4,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.outlineVariant),
                ),
                child: Icon(
                  Icons.camera_alt_outlined,
                  size: 16,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _EditProfileDialog extends ConsumerStatefulWidget {
  final AppUser user;
  final ProfileEntity? profile;

  const _EditProfileDialog({
    required this.user,
    required this.profile,
  });

  @override
  ConsumerState<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends ConsumerState<_EditProfileDialog> {
  late final TextEditingController nameController;
  late final TextEditingController titleController;
  late final TextEditingController bioController;
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
  }

  @override
  void dispose() {
    nameController.dispose();
    titleController.dispose();
    bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Modifier mon profil'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Nom'),
            ),
            TextField(
              controller: titleController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Titre',
                hintText: 'ex. Mobile Engineer',
              ),
            ),
            TextField(
              controller: bioController,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Bio'),
            ),
            const SizedBox(height: 12),
            Text(
              'Email (lecture seule) : ${widget.user.email}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Enregistrer'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    final name = nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le nom est obligatoire.')),
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
          const SnackBar(content: Text('Profil mis à jour.')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Échec de la mise à jour : $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }
}
