# Checklist QA — DevCommunity Chat

Basée sur l'Issue #8 (Tests & QA), état vérifié sur `develop` (merge `feature/chat-ui`, `feature/firebase-auth`, `feature/auth-ui`, `feature/state-management`, `feat/firestore-chat`, `feature/profil-navigation` inclus) au 14/09/2026.

Légende : ✅ testé et fonctionnel · ⏳ pas encore implémenté sur `develop` · ❌ bug bloquant

| Fonctionnalité | Statut | Détails |
|---|---|---|
| Démarrage de l'application | ✅ | L'app démarre sur `LoginPage` sans utilisateur connecté (`test/widget_test.dart`) |
| Inscription | ✅ | `RegisterPage` : rendu + validations testées. Appel réel à Firebase Auth non testé (pas de mocks en place) |
| Connexion | ✅ | `LoginPage` : rendu + validations testées. Appel réel à Firebase Auth non testé |
| Déconnexion | ⏳ | Bouton présent sur `HomePage` et `ProfilePage` (`AuthController.logout()`), mais aucun test automatisé dessus |
| Navigation | ✅ | Redirection selon l'état d'auth (`routerProvider`) + navigation par onglets Home/Chat/Profil testée (`test/features/auth/presentation/pages/home_page_navigation_test.dart`) ; routes couvertes unitairement |
| Affichage du profil | ✅ | `ProfilePage` : affichage des données utilisateur, état "aucun utilisateur", état de chargement, état d'erreur, sélecteur de thème, ouverture/pré-remplissage de la boîte de dialogue d'édition — tous testés |
| Modification du profil | ⏳ | La boîte de dialogue s'ouvre et se pré-remplit (testé), mais l'enregistrement effectif (`UpdateProfile` → Firestore) n'est pas testé |
| Affichage du Chat | ⏳ | `ChatsPage`, `ChatMessagesPage` (Firestore) sans test. Le tab "Chat" de la navigation principale (`ChatPage`) utilise un `ChatNotifier` local en mémoire, pas la vraie implémentation Firestore — voir `BUG_REPORT.md` |
| Envoi d'un message | ⏳ | `MessageComposer` et `SendMessageUseCase` (Firestore) existent mais aucun test automatisé |
| Réception temps réel | ⏳ | Couche Firestore (`ChatRepositoryImpl`, `watchMessagesUseCase`) en place mais aucun test automatisé (nécessite mocks Firestore) |
| Composant `MessageBubble` | ✅ | Rendu testé : message reçu/envoyé, avatar/initiale, icône de lecture |
| États loading/error/empty | ✅ (partiel) | Couverts pour `LoginPage`/`RegisterPage` (validations) et `ProfilePage` (loading/error/empty) ; pas encore pour le chat |

## Résumé

Les parcours d'authentification, de navigation principale et d'affichage du profil sont désormais couverts par des tests automatisés, ainsi que le composant `MessageBubble`. Restent à couvrir : la déconnexion, l'enregistrement réel des modifications de profil, et tout le chat Firestore (liste de conversations, envoi, réception temps réel) — cela nécessite l'introduction d'une librairie de mocks (ex. `mocktail`) pour isoler les tests de Firebase/Firestore.
