import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_info.dart';
import '../../../../core/locale/app_strings.dart';
import '../../../../core/locale/locale_controller.dart';
import '../../../../core/router/app_route_path.dart';
import '../../../../core/router/navigation_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_mode_controller.dart';
import '../../../../core/widgets/app_logo_header.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/utils/logout_navigation.dart';
import '../../../onboarding/presentation/providers/onboarding_provider.dart';
import '../../../profile/presentation/providers/profile_provider.dart';

/// Écran « Plus » — style Figma, limité au scope camp (auth / chat / prefs).
class MorePage extends ConsumerWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final s = ref.watch(appStringsProvider);
    final authAction = ref.watch(authControllerProvider);
    final user = ref.watch(currentUserProvider);
    final profileAsync = ref.watch(currentUserProfileProvider);
    final pushEnabled =
        profileAsync.asData?.value?.pushNotificationsEnabled ?? true;
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          const AppLogoHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(8, 16, 8, 28),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                  child: Text(
                    s.moreTitle,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.onSurface,
                    ),
                  ),
                ),
                _MoreLanguageRow(
                  label: s.language,
                  locale: locale,
                  languageLabel: s.languageLabel,
                  onChanged: (value) {
                    if (value == null) return;
                    ref.read(localeProvider.notifier).setLocale(value);
                  },
                ),
                _MoreSwitchRow(
                  icon: Icons.dark_mode_outlined,
                  label: s.darkMode,
                  value: isDark,
                  onChanged: (value) {
                    ref.read(themeModeProvider.notifier).setThemeMode(
                          value ? ThemeMode.dark : ThemeMode.light,
                        );
                  },
                ),
                _MoreSwitchRow(
                  icon: Icons.notifications_off_outlined,
                  label: s.muteNotifications,
                  value: !pushEnabled,
                  onChanged: user == null || profileAsync.isLoading
                      ? null
                      : (muted) async {
                          try {
                            await ref
                                .read(updatePushNotificationsProvider)
                                .call(
                                  userId: user.id,
                                  enabled: !muted,
                                );
                          } catch (error) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('$error')),
                            );
                          }
                        },
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Divider(height: 1, color: colors.outlineVariant),
                ),
                _MoreNavRow(
                  icon: Icons.groups_outlined,
                  label: s.joinedGroups,
                  onTap: () => ref
                      .read(mainTabProvider.notifier)
                      .selectTab(MainTab.groups),
                ),
                _MoreNavRow(
                  icon: Icons.info_outline,
                  label: s.aboutApp,
                  trailing: Text(
                    AppInfo.versionLabel,
                    style: TextStyle(
                      color: colors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: AppInfo.buildLabel,
                  onTap: null,
                ),
                _MoreNavRow(
                  icon: Icons.slideshow_outlined,
                  label: s.replayIntro,
                  onTap: () async {
                    await ref
                        .read(onboardingCompletedProvider.notifier)
                        .reset();
                    if (!context.mounted) return;
                    context.go(AppRoutePath.splashPath);
                  },
                ),
                const SizedBox(height: 8),
                ListTile(
                  enabled: !authAction.isLoading,
                  leading: const Icon(Icons.logout, color: AppColors.danger),
                  title: Text(
                    s.logout,
                    style: const TextStyle(
                      color: AppColors.danger,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: authAction.isLoading
                      ? null
                      : () => logoutAndGoLogin(ref, context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MoreLanguageRow extends StatelessWidget {
  const _MoreLanguageRow({
    required this.label,
    required this.locale,
    required this.languageLabel,
    required this.onChanged,
  });

  final String label;
  final Locale locale;
  final String Function(Locale) languageLabel;
  final ValueChanged<Locale?> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDark
              ? colors.primary.withValues(alpha: 0.18)
              : AppColors.brandSurface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            'A',
            style: TextStyle(
              color: colors.primary,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
        ),
      ),
      title: Text(label),
      trailing: DropdownButtonHideUnderline(
        child: DropdownButton<Locale>(
          value: locale,
          dropdownColor: Theme.of(context).cardColor,
          icon: Icon(Icons.keyboard_arrow_down, color: colors.onSurfaceVariant),
          items: [
            for (final value in LocaleController.supported)
              DropdownMenuItem(
                value: value,
                child: Text(languageLabel(value)),
              ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _MoreSwitchRow extends StatelessWidget {
  const _MoreSwitchRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}

class _MoreNavRow extends StatelessWidget {
  const _MoreNavRow({
    required this.icon,
    required this.label,
    this.subtitle,
    this.trailing,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: trailing ??
          (onTap == null
              ? null
              : Icon(Icons.chevron_right, color: colors.onSurfaceVariant)),
      onTap: onTap,
    );
  }
}
