# Checklist QA — DevCommunity Chat

Basée sur l'Issue #8 (Tests & QA), état vérifié sur la branche `develop` au 08/09/2026.

Légende : ✅ testé et fonctionnel · ⏳ pas encore implémenté sur `develop` (existe potentiellement sur une branche `feature/*` non mergée) · ❌ bug bloquant

| Fonctionnalité | Statut | Détails |
|---|---|---|
| Démarrage de l'application | ✅ | L'app démarre et affiche `LoginPage` (`test/widget_test.dart`) |
| Inscription | ⏳ | Aucune page/register sur `develop` (prévu dans `feature/auth-ui` / `feature/firebase-auth`) |
| Connexion | ⏳ | `LoginPage` actuelle est un stub UI (bouton "Continuer" sans appel Firebase) — pas d'auth réelle sur `develop` |
| Déconnexion | ⏳ | Aucune fonctionnalité de déconnexion présente sur `develop` |
| Navigation | ✅ | Navigation `LoginPage` → `HomePage` via `go_router` testée (`test/features/auth/login_page_test.dart`) |
| Affichage du profil | ⏳ | Dossier `features/profile/presentation` vide sur `develop` (`.gitkeep` uniquement) |
| Affichage du Chat | ⏳ | Dossier `features/chat/presentation` vide sur `develop` (`.gitkeep` uniquement) |
| Envoi d'un message | ⏳ | Aucune UI/logique de chat sur `develop` |
| Réception temps réel | ⏳ | Aucune intégration Firestore sur `develop` |
| États loading/error/empty | ⏳ | Aucun état de ce type n'existe encore (pas d'appel réseau/Firebase dans l'UI actuelle) |

## Résumé

Sur l'état actuel de `develop`, seules les fonctionnalités de démarrage et de navigation basique existent et sont couvertes par des tests automatisés. Les fonctionnalités métier (auth, chat, profil, temps réel) sont développées sur des branches `feature/*` non encore mergées et devront être re-testées dès leur intégration dans `develop`.
