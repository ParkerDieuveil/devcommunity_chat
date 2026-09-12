# Chat / couche Firestore

Branche : `feat/firestore-chat`

Cette feature pose la couche data / domain de la messagerie et la synchro des profils dans Cloud Firestore. L’UI chat n’est pas dans ce lot (pages à brancher plus tard sur les providers).

Le pattern suit `features/auth/` : datasource → repository → use case → Riverpod.

---

## Périmètre

Ce qui est livré :

- lecture temps réel des conversations d’un user
- lecture temps réel des messages d’un chat
- envoi de message (texte / image via `imageUrl`)
- création (ou réutilisation) d’un chat entre participants
- document profil `users/{uid}` créé / mis à jour après login ou register
- règles de sécurité Firestore (`firestore.rules` à la racine)

Ce qui n’est pas livré :

- écrans liste de chats / conversation
- upload d’images (Storage) ; le modèle accepte déjà `imageUrl`
- présence “online” branchée sur le logout (la méthode `setUserOffline` existe côté repo)

---

## Structure

```text
lib/features/chat/
├── data/
│   ├── datasources/
│   │   ├── chat_remote_data_source.dart
│   │   └── user_profile_remote_data_source.dart
│   └── models/
│       ├── chat_model.dart
│       ├── message_model.dart
│       └── user_profile_model.dart
├── domain/
│   ├── entities/
│   ├── exceptions/
│   ├── repositories/
│   └── usecases/
└── presentation/
    └── providers/
        └── chat_provider.dart
```

Convention utile : le profil Firestore s’appelle `UserProfileEntity` / `UserProfileModel`. On ne réutilise pas `AppUser` / `UserModel` (réservés à l’auth).

---

## Collections Firestore

### `users/{uid}`

Profil applicatif (séparé de Firebase Auth).

| Champ         | Type      | Notes                                      |
|---------------|-----------|--------------------------------------------|
| uid           | string    | = doc id                                   |
| displayName   | string    | fallback = partie locale de l’email        |
| email         | string    |                                            |
| photoUrl      | string?   |                                            |
| createdAt     | timestamp | figé après la 1ère écriture (merge)        |
| lastSeen      | timestamp?|                                            |
| isOnline      | bool      | mis à `true` à la sync login/register      |

Écrit après un login / register réussi via `SyncUserProfileUseCase` (hook dans `AuthController`).

### `chats/{chatId}`

| Champ                | Type       | Notes                                              |
|----------------------|------------|----------------------------------------------------|
| participantIds       | string[]   | **toujours triés** avant écriture / recherche      |
| lastMessage          | string?    | preview                                            |
| lastMessageSenderId  | string?    |                                                    |
| lastMessageAt        | timestamp  | renseigné dès la création (nécessaire pour le tri) |
| createdAt            | timestamp  |                                                    |

`createChat` cherche d’abord un chat avec exactement le même `participantIds` (égalité de tableau). Sinon il en crée un.

### `chats/{chatId}/messages/{messageId}`

| Champ     | Type      | Notes                          |
|-----------|-----------|--------------------------------|
| senderId  | string    | doit = `request.auth.uid`      |
| text      | string?   |                                |
| imageUrl  | string?   |                                |
| type      | string    | `"text"` ou `"image"`          |
| timestamp | timestamp | `FieldValue.serverTimestamp()` |

L’envoi passe par un **batch** : doc message + update des champs `lastMessage*` du chat parent. Pas de moitié écrite si l’autre échoue.

---

## Flux côté app

```text
UI (à venir)
  → StreamProvider / UseCase
  → ChatRepository / UserProfileRepository
  → *RemoteDataSource
  → Cloud Firestore
```

Providers prêts dans `chat_provider.dart` :

| Provider | Rôle |
|----------|------|
| `userChatsProvider(userId)` | stream des chats du user |
| `chatMessagesProvider(chatId)` | stream des messages |
| `sendMessageUseCaseProvider` | envoi |
| `createChatUseCaseProvider` | create / get chat existant |
| `syncUserProfileUseCaseProvider` | déjà branché sur auth |

Les erreurs Firestore / réseau sont remontées en `ChatRepositoryException`. L’UI ne doit pas catcher de `FirebaseException` brute.

---

## Règles de sécurité

Fichier : `firestore.rules`

- **users** : lecture si authentifié, écriture uniquement sur son propre `uid`
- **chats** : read/update si l’uid est dans `participantIds` ; create si l’uid est dans les participants du nouveau doc ; pas de delete
- **messages** : read si participant du chat parent (`get()`) ; create si participant **et** `senderId == auth.uid` ; pas d’update / delete

Déploiement :

```bash
firebase deploy --only firestore:rules
```

Sans ces rules déployées, les écritures depuis l’app échoueront (ou resteront ouvertes en mode test console : à ne pas laisser en prod).

---

## Index

La query `watchUserChats` combine :

- `arrayContains` sur `participantIds`
- `orderBy` sur `lastMessageAt` desc

Firestore exige un **index composite**. Au premier run, la console loggue souvent un lien de création. Sinon : Firebase Console → Firestore → Indexes.

---

## Lien avec l’auth

Seul fichier auth touché pour ce feat : `auth_controller.dart`.

Après un login / register OK, on appelle la sync profil. Si Firestore échoue, l’auth reste valide (session Firebase Auth déjà ouverte). La sync est best-effort pour ne pas bloquer l’écran d’accueil.

Les mots de passe ne passent jamais par Firestore. Auth = Firebase Auth ; profil public / métier = collection `users`.

---

## Comment vérifier rapidement

1. Lancer l’app, s’inscrire ou se connecter.
2. Console Firebase → Authentication : le user apparaît.
3. Firestore → `users/{uid}` : le doc est créé / mis à jour.
4. (Plus tard, avec l’UI) créer un chat, envoyer un message, vérifier `chats` + sous-collection `messages` et le refresh live sans reload.

---

## Dépendance

```yaml
cloud_firestore: ^6.9.0
```

Alignée avec `firebase_core` / `firebase_auth` déjà dans le `pubspec`.

---

## Pour qui enchaîne sur l’UI

Tu peux partir directement de :

- `ref.watch(userChatsProvider(uid))`
- `ref.watch(chatMessagesProvider(chatId))`
- `ref.read(createChatUseCaseProvider).call([...])`
- `ref.read(sendMessageUseCaseProvider).call(...)`

Pas besoin de parler à Firestore depuis les pages.
