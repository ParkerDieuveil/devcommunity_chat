# Checklist QA — DevCommunity Chat

Basée sur l'Issue #8 (Tests & QA), état vérifié sur `develop` (merge `feature/chat-ui`, `feature/firebase-auth`, `feature/auth-ui`, `feature/state-management`, `feat/firestore-chat`, `feature/profil-navigation` inclus) au 14/09/2026.

Légende : ✅ testé et fonctionnel · ⏳ pas encore implémenté sur `develop` · ❌ bug bloquant

| Fonctionnalité | Statut | Détails |
|---|---|---|
| Démarrage de l'application | ✅ | L'app démarre sur `LoginPage` sans utilisateur connecté (`test/widget_test.dart`) |
| Inscription | ✅ | `RegisterPage` : rendu + validations testées. Appel réel à Firebase Auth non testé (pas de mocks en place) |
| Connexion | ✅ | `LoginPage` : rendu + validations testées. Appel réel à Firebase Auth non testé |
| Déconnexion | ✅ | `AuthController.logout()` testé unitairement (succès + erreur) et via le tap du bouton sur `HomePage`/`ProfilePage`, avec un `FakeAuthRepository` |
| Navigation | ✅ | Redirection selon l'état d'auth (`routerProvider`) + navigation par onglets Home/Chat/Profil testée ; routes couvertes unitairement |
| Affichage du profil | ✅ | `ProfilePage` : affichage des données, état "aucun utilisateur", chargement, erreur, sélecteur de thème, boîte de dialogue d'édition — tous testés |
| Modification du profil | ⏳ | La boîte de dialogue s'ouvre et se pré-remplit (testé), mais l'enregistrement effectif (`UpdateProfile` → Firestore) n'est pas testé |
| Affichage du Chat | ✅ | `ChatsPage` / `ChatMessagesPage` (Firestore) branchés sur le tab Chat (`HomePage`) |
| Envoi d'un message | ✅ | `SendMessageUseCase` testé unitairement (succès + erreur) ; `ChatMessagesPage` testé de bout en bout (saisie → tap envoi → appel repository → champ vidé, et cas d'erreur affiché) ; `MessageComposer` testé isolément |
| Réception temps réel | ✅ | `WatchMessagesUseCase` et `ChatsPage`/`ChatMessagesPage` testés avec un flux Firestore simulé (`FakeChatRepository`, plusieurs émissions successives) |
| Bulle de message | ✅ | `_MessageBubble` dans `ChatMessagesPage` (MessageEntity Firestore) |
| États loading/error/empty | ✅ | Couverts pour `LoginPage`/`RegisterPage`, `ProfilePage`, `ChatsPage` et `ChatMessagesPage` |

## Résumé

L'ensemble des fonctionnalités MVP demandées par l'Issue #8 (auth, déconnexion, navigation, profil, chat, envoi de message, réception temps réel) sont couvertes par des tests automatisés via fakes. Reste : enregistrement profil → Firestore en profondeur, IT Firebase.
