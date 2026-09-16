# Rapport de bugs — DevCommunity Chat

État vérifié sur `develop` au 15/09/2026, après merge complet (auth, chat, profil, temps réel, thème, avatar, envoi d'images).

## Bugs trouvés et corrigés

1. **Icônes de navigation incohérentes avec leurs labels (corrigé)** — Dans `HomePage`, la barre de navigation affichait l'icône "chat" sur l'onglet "Home" et l'icône "personne" sur l'onglet "Chat". **Corrigé** : `Icons.home_outlined`/`Icons.home` pour "Home", `Icons.chat_outlined`/`Icons.chat` pour "Chat". Test de non-régression ajouté (`home_page_navigation_test.dart`).
2. **Imports et variable inutilisés (corrigé)** — `home_page.dart` importait `go_router`/`app_route_path` et déclarait une variable `user` non utilisés. Faisait échouer `flutter analyze` (3 warnings). **Corrigé**.
3. **Test obsolète après changement de design (corrigé le 12/09)** — Le commit `fb4d4c6` a remplacé le texte "DevCommunity Chat" par un logo sur `LoginPage`, sans mise à jour du test correspondant. Corrigé : assertions basées sur `find.byType(Image)`.

## Bugs bloquants

Aucun bug bloquant identifié à ce jour.

## Point d'architecture — résolu

~~Le tab "Chat" de la navigation principale n'était pas branché sur Firestore~~ — **Résolu** (PR #22 : `HomePage` → `ChatsPage`). Le code mort associé (`ChatPage` / `ChatNotifier` en mémoire) a été retiré dans `chore/remove-dead-chat-notifier`. Le tab Chat utilise désormais la vraie implémentation Firestore de bout en bout.

## Constats (gaps mineurs, pas des bugs)

1. **`GetProfile` toujours inutilisé** — `getProfileProvider`/`GetProfile` existent dans `profile_provider.dart` mais ne sont lus nulle part ; l'app utilise `watchProfileProvider`/`currentUserProfileProvider` (équivalent en flux temps réel) à la place. `ProfileEntity`, en revanche, est maintenant pleinement utilisé (bio, titre, avatar, statut en ligne, etc.) — ce n'est donc plus du code mort dans son ensemble, seul `GetProfile` (variante ponctuelle non-stream) semble superflu. Mineur, à nettoyer à l'occasion.
2. **Test d'intégration Firebase existant mais non exécuté depuis cet environnement** — `integration_test/auth_firebase_test.dart` (Dieuveil) teste les vrais appels `FirebaseAuth` (création de compte, connexion, déconnexion, session, erreurs). Nécessite un appareil/émulateur + réseau vers le projet Firebase partagé (`flutter test integration_test/`). Non lancé ici pour éviter de créer/supprimer des comptes réels sans validation de l'équipe — à exécuter en local ou en CI avant la livraison finale.

## Suivi

Toutes les fonctionnalités MVP + bonus (auth, déconnexion, navigation, profil + modification + avatar, thème, chat + images + temps réel) sont testées via des fakes en mémoire (`FakeAuthRepository`, `FakeProfileRepository`, `FakeChatRepository`) qui implémentent directement les interfaces du domaine — pas besoin de `mocktail`. Rien de bloquant restant ; les deux constats ci-dessus sont mineurs et non urgents.
