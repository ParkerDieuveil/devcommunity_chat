# Contributing Guide

## 1. Branches

Le projet utilise trois niveaux principaux de branches.

### main

La branche `main` contient uniquement les versions stables du projet.

Aucun développement direct n'est autorisé sur `main`.

### develop

La branche `develop` est la branche d'intégration.

Les Pull Requests des fonctionnalités sont fusionnées dans `develop`.

### feature/*

Chaque fonctionnalité doit être développée dans une branche dédiée.

Format :

feature/<nom-de-la-fonctionnalite>

Exemples :

feature/firebase-auth
feature/chat-ui
feature/firestore-chat
feature/auth-ui
feature/profile-navigation
feature/state-management
feature/tests-qa

---

## 2. Workflow

Chaque membre doit suivre ce workflow :

feature/*
↓
Pull Request
↓
develop
↓
Pull Request
↓
main

Il est interdit de travailler directement sur `main` ou `develop`.

---

## 3. Création d'une branche

Avant de commencer une nouvelle tâche :

```bash
git checkout develop
git pull origin develop
git checkout -b feature/<nom-de-la-tache>