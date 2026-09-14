# Rapport de bugs — DevCommunity Chat

État vérifié sur `develop` au 14/09/2026, après merge de `feature/firebase-auth`, `feature/auth-ui`, `feature/state-management`, `feat/firestore-chat`, `feature/chat-ui` et `feature/profil-navigation`.

## Bugs trouvés et corrigés

1. **Icônes de navigation incohérentes avec leurs labels (corrigé)** — Dans `HomePage`, la barre de navigation affichait l'icône "chat" sur l'onglet "Home" et l'icône "personne" sur l'onglet "Chat" (les deux premières destinations étaient décalées/dupliquées). **Corrigé** : `Icons.home_outlined`/`Icons.home` pour "Home", `Icons.chat_outlined`/`Icons.chat` pour "Chat". Test de non-régression ajouté (`home_page_navigation_test.dart`, vérifie la cohérence icône/label pour chaque destination).
2. **Imports et variable inutilisés (corrigé)** — `home_page.dart` importait `go_router`/`app_route_path` et déclarait une variable `user` non utilisés après le passage à la navigation par onglets (merge `feature/profil-navigation`). Faisait échouer `flutter analyze` (3 warnings). **Corrigé**.
3. **Test obsolète après changement de design (corrigé le 12/09)** — Le commit `fb4d4c6` a remplacé le texte "DevCommunity Chat" par un logo sur `LoginPage`, sans mise à jour du test correspondant. Corrigé : assertions basées sur `find.byType(Image)`.

## Bugs bloquants

Aucun bug bloquant identifié à ce jour.

## Constats (gaps de couverture ou d'intégration, pas des bugs)

1. **Le tab "Chat" de la navigation principale n'est pas branché sur Firestore** — `HomePage` affiche `ChatPage`, qui utilise un `ChatNotifier` local en mémoire (`lib/features/chat/presentation/pages/chat_provider.dart`), différent de la vraie implémentation Firestore (`ChatsPage`/`ChatMessagesPage`, `lib/features/chat/presentation/providers/chat_provider.dart`). Un message envoyé depuis cet onglet n'est donc ni persisté ni synchronisé entre utilisateurs. À signaler à l'équipe chat/state-management.
2. **Déconnexion non testée** — le bouton logout sur `HomePage`/`ProfilePage` n'a pas de test automatisé.
3. **Modification de profil non testée en profondeur** — l'ouverture et le pré-remplissage de la boîte de dialogue sont testés, mais pas l'appel réel à `UpdateProfile` → Firestore.
4. **Chat Firestore non testé** — `ChatsPage`, `ChatMessagesPage`, `MessageComposer`, ainsi que les use cases `SendMessageUseCase`/`WatchMessagesUseCase`/`WatchUserChatsUseCase` n'ont pas de test. Nécessite des mocks Firestore (aucune librairie de mock — ex. `mocktail` — n'est présente dans `pubspec.yaml`).
5. **Pas de test sur les appels Firebase réels** (login/register/logout) — seules les validations de formulaire côté UI sont testées.
6. **`ProfileEntity`/`GetProfile` non utilisés** — le domaine `profile` définit une entité et un usecase `GetProfile` distincts de `AppUser`, mais `ProfilePage` n'utilise que `AppUser` (via `authStateProvider`) ; `GetProfile` semble mort. À clarifier avec l'auteur (Hien) — fusion prévue avec `AppUser` ou usage futur ?

## Suivi

Prochaine étape recommandée : introduire `mocktail` en `dev_dependencies` pour pouvoir tester les repositories/use cases et le chat Firestore sans dépendre de services réels ; clarifier avec l'équipe le branchement du tab Chat sur la vraie implémentation Firestore.
