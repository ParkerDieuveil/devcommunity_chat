import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/profile_provider.dart';
import '../widgets/profile_icon_container.dart';
import '../widgets/profile_liste_tile.dart';
import '../widgets/profile_stat_tile.dart';
import '../widgets/profile_theme_option.dart';

class ProfilePage extends ConsumerStatefulWidget {
  final ImageProvider<Object> avatarImage;

  const ProfilePage({
    super.key,
    this.avatarImage = const NetworkImage('https://i.pravatar.cc/300'),
  });

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  bool pushNotifications = true;
  String selectedTheme = 'Sombre';

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final authControllerState = ref.watch(authControllerProvider);

    return authState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Erreur : $error')),
      data: (user) {
        if (user == null) {
          return const Center(child: Text('Aucun utilisateur connecté'));
        }

        final imageProvider =
            user.photoUrl != null && user.photoUrl!.trim().isNotEmpty
            ? NetworkImage(user.photoUrl!)
            : widget.avatarImage;
        final displayName = user.displayName ?? 'Utilisateur';
        final username = user.email.split('@').first;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.badge_outlined,
                  color: Colors.blueAccent,
                  size: 20,
                ),
              ),
            ),
            title: const Text(
              'Mon Profil',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            actions: [
              IconButton(
                onPressed: () {},
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFF0F172A),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.tune, size: 18),
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFF0F172A),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.help_outline, size: 18),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.cyanAccent,
                                width: 2,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: CircleAvatar(
                                backgroundImage: imageProvider,
                              ),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F172A),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.grey),
                              ),
                              child: const Icon(
                                Icons.camera_alt_outlined,
                                size: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            displayName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.verified,
                            color: Colors.cyan,
                            size: 18,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0B1120),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(fontSize: 12),
                            children: [
                              TextSpan(
                                text: '@$username',
                                style: const TextStyle(
                                  color: Colors.cyanAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const TextSpan(
                                text: ' • Senior Mobile Engineer (Flutter)',
                                style: TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0B1120),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.email_outlined,
                              size: 14,
                              color: Colors.white54,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              user.email,
                              style: const TextStyle(
                                color: Colors.cyanAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Bâtisseur d'applications Flutter fluides & fan d'architecture réactive Firebase. Toujours prêt pour un refacto propre.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          buildStatTile(
                            '24',
                            'Salons',
                            const Color(0xFF0B1120),
                          ),
                          const SizedBox(width: 8),
                          buildStatTile(
                            '142',
                            'Contributions',
                            const Color(0xFF0B1120),
                            valueColor: Colors.cyanAccent,
                          ),
                          const SizedBox(width: 8),
                          buildStatTile(
                            '99.8%',
                            'Uptime',
                            const Color(0xFF0B1120),
                            valueColor: Colors.greenAccent,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _showEditProfileDialog(user),
                          icon: const Icon(Icons.edit_outlined, size: 16),
                          label: const Text('Modifier mon profil'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'PARAMÈTRES & PRÉFÉRENCES',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          buildIconContainer(Icons.notifications_outlined),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Notifications push'),
                                Text(
                                  'Alertes mentions et DM directs',
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: pushNotifications,
                            activeThumbColor: Colors.cyan,
                            onChanged: (value) =>
                                setState(() => pushNotifications = value),
                          ),
                        ],
                      ),
                      const Divider(height: 24, color: Colors.white10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildIconContainer(Icons.palette_outlined),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Thème de l\'application'),
                                const Text(
                                  'Palette Obsidian & High-Contrast',
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0B1120),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      ProfileThemeOption(
                                        title: 'Sombre',
                                        icon: Icons.nightlight_round,
                                        isSelected: selectedTheme == 'Sombre',
                                        onSelected: () => setState(
                                          () => selectedTheme = 'Sombre',
                                        ),
                                      ),
                                      ProfileThemeOption(
                                        title: 'Clair',
                                        icon: Icons.wb_sunny_outlined,
                                        isSelected: selectedTheme == 'Clair',
                                        onSelected: () => setState(
                                          () => selectedTheme = 'Clair',
                                        ),
                                      ),
                                      ProfileThemeOption(
                                        title: 'Système',
                                        icon: Icons.settings_outlined,
                                        isSelected: selectedTheme == 'Système',
                                        onSelected: () => setState(
                                          () => selectedTheme = 'Système',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24, color: Colors.white10),
                      buildListTile(
                        icon: Icons.info_outline,
                        title: 'À propos de DevCommunity',
                        subtitle: 'Build 2024.11-rc3',
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0B1120),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'v2.4.0',
                            style: TextStyle(color: Colors.cyan, fontSize: 11),
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
                        : () => ref
                              .read(authControllerProvider.notifier)
                              .logout(),
                    icon: const Icon(
                      Icons.logout,
                      color: Colors.redAccent,
                      size: 18,
                    ),
                    label: const Text(
                      'Déconnexion',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2A1215),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    'Session chiffrée active • 2026 DevCommunity Chat',
                    style: TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showEditProfileDialog(AppUser user) {
    return showDialog<void>(
      context: context,
      builder: (_) => _EditProfileDialog(user: user),
    );
  }
}

class _EditProfileDialog extends ConsumerStatefulWidget {
  final AppUser user;

  const _EditProfileDialog({required this.user});

  @override
  ConsumerState<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends ConsumerState<_EditProfileDialog> {
  late final TextEditingController nameController;
  late final TextEditingController emailController;
  late final TextEditingController bioController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.user.displayName ?? '');
    emailController = TextEditingController(text: widget.user.email);
    bioController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
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
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nom'),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: bioController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Bio'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () async {
            try {
              await ref
                  .read(updateProfileProvider)
                  .call(
                    userId: widget.user.id,
                    name: nameController.text.trim(),
                    email: emailController.text.trim(),
                    bio: bioController.text.trim(),
                  );
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profil mis à jour.')),
                );
              }
            } catch (error) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Échec de la mise à jour : $error')),
                );
              }
            }
          },
          child: const Text('Enregistrer'),
        ),
      ],
    );
  }
}
