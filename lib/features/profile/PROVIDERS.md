# Profile providers

| Provider | Type | Rôle |
|---|---|---|
| `currentUserProfileProvider` | `StreamProvider<ProfileEntity?>` | doc Firestore `users/{uid}` du user connecté |
| `profileSalonCountProvider` | `Provider<AsyncValue<int>>` | nb de salons via `userChatsProvider` |
| `profilesProvider` | `StreamProvider<List<ProfileEntity>>` | tous les profils (ex. résolution noms chat) |
| `updateProfileProvider` | `Provider<UpdateProfile>` | maj nom / titre / bio |
| `updatePushNotificationsProvider` | `Provider<UpdatePushNotifications>` | préférence notifs |

## Thème (core)

| Provider | Type | Rôle |
|---|---|---|
| `themeModeProvider` | `NotifierProvider<ThemeModeController, ThemeMode>` | thème global + persistence `SharedPreferences` |
| `sharedPreferencesProvider` | `Provider<SharedPreferences>` | bootstrap dans `main.dart` |

```dart
final profile = ref.watch(currentUserProfileProvider);
final themeMode = ref.watch(themeModeProvider);
await ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light);
```
