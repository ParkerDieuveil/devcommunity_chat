# Rapport de bugs — DevCommunity Chat

État vérifié sur la branche `develop` au 08/09/2026.

## Bugs bloquants

Aucun bug bloquant identifié sur le périmètre actuel de `develop`.

## Constats (gaps d'intégration, pas des bugs)

Ces points ne sont pas des bugs mais des fonctionnalités pas encore mergées dans `develop` — à re-vérifier après intégration des PR correspondantes :

1. **Authentification non branchée** — `LoginPage` contient un bouton "Continuer" qui navigue directement vers `HomePage` sans appel à Firebase Auth. À re-tester une fois `feature/firebase-auth` mergée.
2. **Pas d'inscription** — aucune page register sur `develop`. À re-tester une fois `feature/auth-ui` mergée.
3. **Pas de déconnexion** — aucun bouton/action de déconnexion sur `develop`.
4. **Chat et profil vides** — `features/chat/presentation` et `features/profile/presentation` ne contiennent que des `.gitkeep`. À re-tester une fois `feature/chat-ui`, `feature/firestore-chat` et `feature/profile-navigation` mergées.
5. **Pas de gestion d'états loading/error/empty** — normal à ce stade puisqu'aucun appel réseau/Firebase n'est encore branché dans l'UI.

## Suivi

Ce rapport sera mis à jour à chaque nouvelle vérification QA après intégration de PR dans `develop`.
