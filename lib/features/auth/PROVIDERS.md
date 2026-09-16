# Providers Auth

## Session (source de vérité)

| Provider | Type | Expose | Dépend de |
|----------|------|--------|-----------|
| `authStateProvider` | `StreamProvider<AppUser?>` | stream session Firebase Auth | `watchAuthStateUseCaseProvider` |
| `currentUserProvider` | `Provider<AppUser?>` | user courant (ou null) | `authStateProvider` |

Usage session :

```dart
final user = ref.watch(currentUserProvider);
```

Ne pas utiliser `FirebaseAuth.instance.currentUser` hors datasources / `firebaseAuthProvider`.

## Actions

| Provider | Type | Expose | Dépend de |
|----------|------|--------|-----------|
| `authControllerProvider` | `NotifierProvider<..., AsyncValue<AppUser?>>` | loading / data / error des actions login, register, logout | use cases auth + sync profil |

Usage formulaire :

```dart
ref.watch(authControllerProvider); // isLoading, error
ref.read(authControllerProvider.notifier).login(...);
```

`authControllerProvider` ne remplace pas `currentUserProvider` pour savoir qui est connecté.

## Infra (interne)

`firebaseAuthProvider`, `authRemoteDataSourceProvider`, `authRepositoryProvider`, use case providers : wiring Clean Architecture, pas destinés à l'UI.
