# Profile providers

| Provider | Type | Rôle |
|---|---|---|
| `currentUserProfileProvider` | `StreamProvider<ProfileEntity?>` | doc Firestore `users/{uid}` |
| `profileSalonCountProvider` | `Provider<AsyncValue<int>>` | nb de salons |
| `profilesProvider` | `StreamProvider<List<ProfileEntity>>` | tous les profils |
| `updateProfileProvider` | `Provider<UpdateProfile>` | maj nom / titre / bio |
| `updatePushNotificationsProvider` | `Provider<UpdatePushNotifications>` | préférence notifs |
| `updateProfileAvatarProvider` | `Provider<UpdateProfileAvatar>` | pipeline avatar |
| `profileAvatarControllerProvider` | `NotifierProvider` | loading / erreur UI |

## Avatar pipeline

```text
LoadPreviousPhoto → Pick → Validate → Process(JPEG) → Upload Storage
  → Persist Firestore photoUrl → Cleanup ancien → Sync Auth (best-effort)
```

Storage path : `users/{uid}/avatar/profile.jpg`  
Rules : `storage.rules` à la racine (à déployer).

## Thème (core)

| Provider | Type | Rôle |
|---|---|---|
| `themeModeProvider` | `NotifierProvider` | thème + SharedPreferences |
| `sharedPreferencesProvider` | `Provider` | bootstrap `main.dart` |
