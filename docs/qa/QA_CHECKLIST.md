# Checklist QA — DevCommunity Chat

Basée sur l'Issue #8 (Tests & QA), état vérifié sur `develop` (merge `feature/chat-ui`, `feature/firebase-auth`, `feature/auth-ui`, `feature/state-management`, `feat/firestore-chat` inclus) au 12/09/2026.

Légende : ✅ testé et fonctionnel · ⏳ pas encore implémenté sur `develop` · ❌ bug bloquant

| Fonctionnalité | Statut | Détails |
|---|---|---|
| Démarrage de l'application | ✅ | L'app démarre sur `LoginPage` sans utilisateur connecté (`test/widget_test.dart`) |
| Inscription | ✅ | `RegisterPage` : rendu + validations (email vide/incorrect, mot de passe trop court, confirmation) testées (`test/features/auth/presentation/pages/register_page_test.dart`). Appel réel à Firebase Auth non testé (pas de mocks en place) |
| Connexion | ✅ | `LoginPage` : rendu + validations (email vide/incorrect, mot de passe vide) testées. Appel réel à Firebase Auth non testé |
| Déconnexion | ⏳ | Bouton présent sur `HomePage` (`AuthController.logout()`), mais aucun test automatisé dessus |
| Navigation | ✅ | Redirection selon l'état d'auth (`routerProvider`) couverte indirectement par le smoke test ; routes couvertes unitairement (`test/unit/app_route_path_test.dart`) |
| Affichage du profil | ⏳ | `features/profile/presentation` toujours vide (`.gitkeep` uniquement) |
| Affichage du Chat | ⏳ | `ChatsPage`, `ChatMessagesPage`, `ChatPage` existent sur `develop` mais aucun test automatisé |
| Envoi d'un message | ⏳ | `MessageComposer` et `SendMessageUseCase` existent mais aucun test automatisé |
| Réception temps réel | ⏳ | Couche Firestore (`ChatRepositoryImpl`, `watchMessagesUseCase`) en place mais aucun test automatisé (nécessite mocks Firestore) |
| Composant `MessageBubble` | ✅ | Rendu testé : message reçu/envoyé, avatar/initiale, icône de lecture (`test/features/chat/message_bubble_test.dart`) |
| États loading/error/empty | ⏳ | `AuthController` gère `AsyncLoading`/`AsyncError` (visible dans l'UI login/register) mais pas testé automatiquement |

## Résumé

Les parcours d'authentification (UI + validations) et le composant `MessageBubble` sont couverts par des tests automatisés. Le chat (envoi, réception temps réel, pages), le profil, la déconnexion et les appels réels à Firebase/Firestore restent à tester — cela nécessite l'introduction d'une librairie de mocks (ex. `mocktail`) pour isoler les tests des services externes.
