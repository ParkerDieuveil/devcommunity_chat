import 'package:flutter/material.dart';
import '../widgets/profile_liste_tile.dart';
import '../widgets/profile_icon_container.dart';
import '../widgets/profile_theme_option.dart';
import '../widgets/profile_stat_tile.dart';

class ProfileScreen extends StatefulWidget {
  final ImageProvider<Object> avatarImage;

  const ProfileScreen({
    super.key,
    this.avatarImage = const NetworkImage('https://i.pravatar.cc/300'),
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool pushNotifications = true;
  String selectedTheme = 'Sombre';

  @override
  Widget build(BuildContext context) {
    const cardBgColor = Color(0xFF0F172A);
    const innerCardBg = Color(0xFF0B1120);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Container(
            decoration: BoxDecoration(
              color: cardBgColor,
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
          // settings icon
          IconButton(
            onPressed: () {},
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: cardBgColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.tune, size: 18),
            ),
          ),
          // help icon
          IconButton(
            onPressed: () {},
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: cardBgColor,
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
            // --- CARTE PROFIL ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardBgColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  // Photo avec bordure et icône d'édition
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
                          padding: EdgeInsets.all(4.0),
                          child: CircleAvatar(
                            backgroundImage: widget.avatarImage,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: cardBgColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey.shade700),
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
                  // Nom + Badge vérifié
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'Alexandre Vasseur',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(Icons.verified, color: Colors.cyan, size: 18),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Pseudo + Poste
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: innerCardBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(fontSize: 12),
                        children: [
                          TextSpan(
                            text: '@alex_dev',
                            style: TextStyle(
                              color: Colors.cyanAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
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
                      color: innerCardBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.email_outlined,
                          size: 14,
                          color: Colors.white54,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'alex.dev@example.com',
                          style: TextStyle(
                            color: Colors.cyanAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Bio
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
                  // Statistiques
                  Row(
                    children: [
                      buildStatTile('24', 'Salons', innerCardBg),
                      const SizedBox(width: 8),
                      buildStatTile(
                        '142',
                        'Contributions',
                        innerCardBg,
                        valueColor: Colors.cyanAccent,
                      ),
                      const SizedBox(width: 8),
                      buildStatTile(
                        '99.8%',
                        'Uptime',
                        innerCardBg,
                        valueColor: Colors.greenAccent,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Bouton Modifier
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: const Text('Modifier mon profil'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: innerCardBg,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- TITRE SECTION ---
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

            // --- CARTE PARAMÈTRES ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBgColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  // Switch Notifications
                  Row(
                    children: [
                      buildIconContainer(Icons.notifications_outlined),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Notifications push',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
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
                        onChanged: (val) =>
                            setState(() => pushNotifications = val),
                      ),
                    ],
                  ),
                  const Divider(height: 24, color: Colors.white10),

                  // Thème de l'application
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildIconContainer(Icons.palette_outlined),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Thème de l\'application',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const Text(
                              'Palette Obsidian & High-Contrast',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Selecteur de thème
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: innerCardBg,
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
                                    onSelected: () =>
                                        setState(() => selectedTheme = 'Clair'),
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
                  // À propos
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
                        color: innerCardBg,
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

            // --- BOUTON DÉCONNEXION ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {},
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // --- FOOTER ---
            const Center(
              child: Text(
                'Session chiffrée active depuis Paris, FR',
                style: TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
