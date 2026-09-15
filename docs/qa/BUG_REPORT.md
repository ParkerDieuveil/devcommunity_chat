# Rapport de bugs — DevCommunity Chat

État vérifié sur `develop` au 14/09/2026, après merge de `feature/firebase-auth`, `feature/auth-ui`, `feature/state-management`, `feat/firestore-chat`, `feature/chat-ui` et `feature/profil-navigation`.

## Bugs trouvés et corrigés

1. **Icônes de navigation incohérentes avec leurs labels (corrigé)** — Dans `HomePage`, la barre de navigation affichait l'icône "chat" sur l'onglet "Home" et l'icône "personne" sur l'onglet "Chat" (les deux premières destinations étaient décalées/dupliquées). **Corrigé** : `Icons.home_outlined`/`Icons.home` pour "Home", `Icons.chat_outlined`/`Icons.chat` pour "Chat". Test de non-régression ajouté (`home_page_navigation_test.dart`, vérifie la cohérence icône/label pour chaque destination).
2. **Imports et variable inutilisés (corrigé)** — `home_page.dart` importait `go_router`/`app_route_path` et déclarait une variable `user` non utilisés après le passage à la navigation par onglets (merge `feature/profil-navigation`). Faisait échouer `flutter analyze` (3 warnings). **Corrigé**.
3. **Test obsolète après changement de design (corrigé le 12/09)** — Le commit `fb4d4c6` a remplacé le texte "DevCommunity Chat" par un logo sur `LoginPage`, sans mise à jour du test correspondant. Corrigé : assertions basées sur `find.byType(Image)`.

## Bugs bloquants

Aucun bug bloquant identifié à ce jour.

## ⚠️ Point d'architecture à corriger avant ce soir

<<<<<<< HEAD
1. **Le tab "Chat" de la navigation principale n'est pas branché sur Firestore** — `HomePage` affiche `ChatPage`, qui utilise un `ChatNotifier` **local en mémoire** (`lib/features/chat/presentation/pages/chat_provider.dart`), au lieu de la vraie implémentation Firestore Clean Architecture (`ChatsPage`/`ChatMessagesPage`, `lib/features/chat/presentation/providers/chat_provider.dart`, qui passe par `ChatRepository` → `ChatRemoteDataSource` → Firestore, comme prévu dans le compte-rendu d'architecture du groupe).
   - **Conséquence** : un message envoyé depuis l'onglet "Chat" de la navigation principale n'est ni persisté ni synchronisé entre utilisateurs — c'est un chat factice, local à l'appareil.
   - **Ce qu'il manque pour respecter l'architecture prévue** : dans `HomePage`, remplacer `ChatPage` (chat local) par le vrai flux `ChatsPage` → `ChatMessagesPage` (liste de conversations réelles, sélection d'une conversation, puis messages Firestore en temps réel). Actuellement les deux systèmes coexistent en parallèle dans le code.
   - **Responsable suggéré** : équipe chat / state-management (Benitdiyavanga, Andassaramananandro, David).

## Constats (gaps de couverture, pas des bugs)

1. ~~Pas de test sur les appels Firebase réels~~ — **corrigé, en réalité déjà couvert** : `integration_test/auth_firebase_test.dart` (Dieuveil) teste bien les vrais appels `FirebaseAuth` (création de compte, connexion, déconnexion, utilisateur courant, changements de session, erreurs de mot de passe/format). Ce n'est pas lancé avec `flutter test` (nécessite un appareil/émulateur + réseau vers le vrai projet Firebase — voir `flutter test integration_test/`). Non exécuté depuis cet environnement pour éviter de créer/supprimer des comptes réels sur le projet partagé sans validation de l'équipe — à lancer en local ou en CI avant la livraison finale.
2. **`ProfileEntity`/`GetProfile` confirmés morts (code inutilisé)** — recherche confirmée : `GetProfile` n'a même pas de provider Riverpod (absent de `profile_provider.dart`), donc injoignable depuis l'UI. `ProfileEntity` n'est utilisé qu'en interne par `UpdateProfile`/`ProfileRepositoryImpl`, jamais exposé à `ProfilePage` (qui n'affiche que `AppUser`). À noter aussi : le module `chat` définit sa **propre** entité `UserProfileEntity` (pour synchroniser nom/avatar dans Firestore pour l'affichage des messages) — donc il existe maintenant 3 notions de "profil" dans le code (`AppUser`, `ProfileEntity` mort, `UserProfileEntity` du chat). À clarifier avec Hien : `GetProfile`/`ProfileEntity` prévu pour une future fonctionnalité (profil enrichi distinct du compte Firebase Auth), ou à supprimer ?

## Suivi

Déconnexion, modification de profil, et chat Firestore (liste, envoi, réception temps réel) sont désormais testés grâce à des fakes en mémoire (`FakeAuthRepository`, `FakeProfileRepository`, `FakeChatRepository`) qui implémentent directement les interfaces du domaine — pas besoin d'ajouter `mocktail`. Les vrais appels Firebase Auth sont couverts par un test d'intégration existant (à exécuter en local/CI). **Reste à traiter avant ce soir** : brancher le tab Chat de la navigation principale sur la vraie implémentation Firestore (seul point qui s'écarte de l'architecture Clean Architecture définie en réunion d'équipe).
=======
1. ~~**Le tab "Chat" de la navigation principale n'est pas branché sur Firestore**~~ — **Résolu** (PR #22 : `HomePage` → `ChatsPage`). Code mort associé (`ChatPage` / `ChatNotifier` mémoire) retiré dans `chore/remove-dead-chat-notifier`.
2. **Modification de profil non testée en profondeur** — l'ouverture et le pré-remplissage de la boîte de dialogue sont testés, mais pas l'appel réel à `UpdateProfile` → Firestore.
3. **Pas de test sur les appels Firebase réels** (login/register/logout) — seules la logique métier (via fakes) et les validations de formulaire côté UI sont testées, pas l'intégration avec `FirebaseAuth`/Firestore eux-mêmes.
4. **`ProfileEntity`/`GetProfile` non utilisés** — le domaine `profile` définit une entité et un usecase `GetProfile` distincts de `AppUser`, mais `ProfilePage` n'utilise que `AppUser` (via `authStateProvider`) ; `GetProfile` semble mort. À clarifier avec l'auteur (Hien) — fusion prévue avec `AppUser` ou usage futur ?

## Suivi

Déconnexion, chat Firestore (liste, envoi, réception temps réel) sont testés via fakes. Tab Chat branché Firestore. Reste : tests profil → Firestore en profondeur, IT Firebase.
>>>>>>> develop
