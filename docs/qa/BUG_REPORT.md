# Rapport de bugs — DevCommunity Chat

État vérifié sur `develop` au 12/09/2026, après merge de `feature/firebase-auth`, `feature/auth-ui`, `feature/state-management`, `feat/firestore-chat` et `feature/chat-ui`.

## Bugs trouvés et corrigés (côté tests)

1. **Test obsolète après changement de design (corrigé)** — Le commit `fb4d4c6` ("feat: improve login and register screens adding a logo") a remplacé le texte "DevCommunity Chat" par un logo image sur `LoginPage`, mais `test/features/auth/presentation/pages/login_page_test.dart` et `test/widget_test.dart` continuaient à chercher ce texte, faisant échouer 2 tests. Ce n'est pas un bug produit (le changement de design est intentionnel) mais un test resté désynchronisé de l'UI. **Corrigé** : les assertions vérifient maintenant la présence du logo (`find.byType(Image)`) et du sous-titre "Connectez-vous à votre communauté."

## Bugs bloquants

Aucun bug bloquant identifié à ce jour.

## Constats (gaps de couverture de tests, pas des bugs)

1. **Déconnexion non testée** — le bouton logout sur `HomePage` (`AuthController.logout()`) n'a pas de test automatisé.
2. **Chat non testé au-delà de `MessageBubble`** — `ChatsPage`, `ChatMessagesPage`, `MessageComposer`, ainsi que les use cases `SendMessageUseCase`/`WatchMessagesUseCase`/`WatchUserChatsUseCase` n'ont pas de test. Nécessite des mocks Firestore (aucune librairie de mock — ex. `mocktail` — n'est présente dans `pubspec.yaml`).
3. **Profil toujours vide** — `features/profile/presentation` ne contient qu'un `.gitkeep` ; rien à tester pour l'instant.
4. **Pas de test sur les appels Firebase réels** (login/register/logout) — seules les validations de formulaire côté UI sont testées, pas l'intégration avec `FirebaseAuth`.
5. **États loading/error** — gérés dans le code (`AsyncLoading`/`AsyncError` dans `AuthController`) mais non couverts par des tests automatisés.

## Suivi

Prochaine étape recommandée : introduire `mocktail` en `dev_dependencies` pour pouvoir tester les repositories/use cases et les pages de chat sans dépendre de Firebase/Firestore réels.
