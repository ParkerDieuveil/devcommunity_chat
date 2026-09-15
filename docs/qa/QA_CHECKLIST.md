# Checklist QA — DevCommunity Chat

Basée sur l'Issue #8 (Tests & QA), état vérifié sur `develop` au 15/09/2026, après merge de toutes les features (auth, chat, profil, temps réel, images, thème, avatar).

Légende : ✅ testé et fonctionnel · ⏳ pas encore testé · ❌ bug bloquant

| Fonctionnalité | Statut | Détails |
|---|---|---|
| Démarrage de l'application | ✅ | L'app démarre sur `LoginPage` sans utilisateur connecté (`test/widget_test.dart`) |
| Inscription | ✅ | `RegisterPage` : rendu + validations testées |
| Connexion | ✅ | `LoginPage` : rendu + validations testées ; vrais appels Firebase couverts par `integration_test/auth_firebase_test.dart` |
| Déconnexion | ✅ | `AuthController.logout()` testé unitairement (succès + erreur) et via tap du bouton sur `HomePage`/`ProfilePage` |
| Navigation | ✅ | Navigation par onglets Home/Chat/Profil testée (icônes, contenu par onglet) ; routes couvertes unitairement |
| Affichage du profil | ✅ | `ProfilePage` : données réelles (bio, titre, stats de salons, statut en ligne, date d'inscription), états loading/erreur/vide, thème, boîte de dialogue d'édition |
| Modification du profil | ✅ | Enregistrement réussi, échec avec message d'erreur, annulation, validation nom obligatoire — tous testés (`FakeProfileRepository`) |
| Upload d'avatar | ✅ | `UpdateProfileAvatar` (pipeline complet : sélection galerie, validation, upload, persistance, nettoyage de l'ancien avatar, annulation) testé unitairement (`update_profile_avatar_test.dart`) |
| Thème clair/sombre | ✅ | `ThemeModeController` testé (persistance et restauration via `SharedPreferences`) + changement de thème testé depuis `ProfilePage` |
| Affichage du Chat | ✅ | `ChatsPage`/`ChatMessagesPage` (Firestore) branchés sur le tab Chat de `HomePage` et testés (liste, vide, temps réel) |
| Envoi d'un message texte | ✅ | `SendMessageUseCase` (unitaire) + `ChatMessagesPage` de bout en bout (saisie → envoi → repository → champ vidé, cas d'erreur) |
| Envoi d'une image | ✅ | `SendChatImageUseCase` testé unitairement (upload + envoi + légende, annulation, validation fichier vide) |
| Réception temps réel | ✅ | `WatchMessagesUseCase` + `ChatsPage`/`ChatMessagesPage` testés avec un flux simulé (plusieurs émissions successives) |
| Composant `MessageBubble` | ✅ | Rendu testé : message reçu/envoyé, avatar/initiale, icône de lecture |
| États loading/error/empty | ✅ | Couverts pour auth, profil, chat |

## Résumé

L'ensemble des fonctionnalités MVP + bonus (Issue #8 et #9 — envoi d'images) sont couvertes par des tests automatisés (56 tests), en utilisant des fakes en mémoire pour isoler Firebase/Firestore/Storage sans dépendance de mock supplémentaire. Aucun gap de couverture majeur identifié à ce jour.
