# 💬 DevCommunity Chat

> **Connecter les développeurs. Faciliter les échanges. Construire la communauté.**

**DevCommunity Chat** est une application mobile de communication développée avec **Flutter et Firebase** dans le cadre du **FlutterFire Summer Camp 2026 – Groupe 8**.

L'application a pour objectif de fournir aux développeurs et aux communautés technologiques un espace dédié permettant de **communiquer, échanger des messages, créer des conversations, interagir avec des groupes et gérer son profil** depuis une application mobile moderne.

---

## 📱 Présentation

Les communautés de développeurs ont besoin d'espaces où leurs membres peuvent communiquer rapidement, partager des informations et maintenir leurs échanges au même endroit.

DevCommunity Chat propose une expérience de messagerie orientée communauté avec :

* 🔐 authentification sécurisée ;
* 💬 conversations entre utilisateurs ;
* 👥 communication au sein de groupes ;
* ⚡ synchronisation en temps réel ;
* 🖼️ partage d'images dans les conversations ;
* 👤 profils utilisateurs ;
* 📸 gestion de l'avatar ;
* 🌙 thème clair et sombre ;
* 🧭 navigation structurée ;
* 🔄 persistance de la session utilisateur.

---

# 🎯 Objectifs du projet

Le projet poursuit plusieurs objectifs :

### 1. Créer un espace de communication dédié

Permettre aux membres d'une communauté technologique de communiquer depuis une application mobile unique.

### 2. Mettre en pratique Flutter et Firebase

Le projet permet de mettre en œuvre concrètement :

* Flutter ;
* Dart ;
* Firebase Authentication ;
* Cloud Firestore ;
* Riverpod ;
* navigation déclarative ;
* architecture logicielle ;
* tests automatisés.

### 3. Appliquer une architecture maintenable

L'application est organisée autour d'une approche inspirée de la **Clean Architecture**, afin de séparer l'interface utilisateur, la logique métier et l'accès aux données.

### 4. Travailler comme une équipe

Le développement est réalisé avec Git et GitHub à travers des branches, Pull Requests, revues de code, tests et intégrations progressives.

---

# ✨ Fonctionnalités

## 🔐 Authentification

DevCommunity Chat utilise **Firebase Authentication** pour gérer les comptes utilisateurs.

Fonctionnalités :

* inscription par email et mot de passe ;
* connexion ;
* déconnexion ;
* récupération de l'utilisateur courant ;
* observation des changements d'état d'authentification ;
* gestion des erreurs Firebase ;
* protection des routes selon l'état de connexion ;
* persistance de la session.

### 🔄 Restauration de session

Au démarrage de l'application, un écran de démarrage laisse le temps à Firebase de restaurer la session existante avant que le routeur décide de la destination de l'utilisateur.

```text
                 Lancement
                     │
                     ▼
                  Splash
                     │
                     ▼
          Restauration de session
                     │
              ┌──────┴──────┐
              │             │
          Connecté      Non connecté
              │             │
              ▼             ▼
            Home           Login
```

Ainsi, un utilisateur qui s'est déjà connecté peut fermer puis rouvrir l'application sans être renvoyé inutilement vers l'écran de connexion.

---

# 💬 Messagerie

Le module de chat utilise **Cloud Firestore** comme source de données.

Il permet notamment :

* d'afficher les conversations ;
* de créer une nouvelle conversation ;
* d'ouvrir une conversation ;
* d'afficher les messages ;
* d'envoyer des messages ;
* de recevoir les changements en temps réel ;
* de gérer les conversations associées à l'utilisateur.

Les données sont observées avec des `StreamProvider` Riverpod afin que l'interface puisse automatiquement réagir aux changements de Firestore.

### Architecture simplifiée

```text
             Flutter UI
                 │
                 ▼
          Riverpod Provider
                 │
                 ▼
             Use Case
                 │
                 ▼
            Repository
                 │
                 ▼
       Remote Data Source
                 │
                 ▼
           Cloud Firestore
```

---

# 🖼️ Messages avec images

Le projet comprend également une fonctionnalité permettant de travailler avec des **images dans les conversations**.

Les éléments concernés comprennent notamment :

* sélection d'une image ;
* traitement de l'image ;
* détermination du type MIME ;
* préparation de l'envoi ;
* use case dédié à l'envoi d'image ;
* affichage des images dans les messages.

Les dépendances utilisées comprennent notamment :

* `image_picker`
* `image`
* `mime`
* `firebase_storage`

### ⚠️ Limitation de l'environnement Firebase

La fonctionnalité d'upload vers Firebase Storage dépend de la configuration et du forfait Firebase utilisé.

Dans l'environnement actuel du projet, certaines opérations Storage peuvent être limitées par les restrictions du forfait gratuit. Cette contrainte est donc distinguée de la logique Flutter développée pour la fonctionnalité.

---

# 👥 Conversations et groupes

L'application prévoit une organisation des échanges autour des conversations et des groupes.

La navigation principale permet de distinguer les différents espaces de communication et d'accéder aux conversations correspondantes.

L'objectif est de permettre à l'application d'évoluer d'une simple messagerie individuelle vers un véritable espace de communication communautaire.

---

# 👤 Profil utilisateur

Le module Profile permet de gérer les informations liées à l'utilisateur.

Il comprend notamment :

* affichage du profil ;
* récupération du profil depuis Firestore ;
* observation des profils ;
* gestion de l'utilisateur courant ;
* gestion de l'avatar ;
* synchronisation de certaines informations avec Firebase Authentication.

Le projet utilise également des providers Riverpod dédiés au profil.

---

# 📸 Avatar utilisateur

Le projet contient une fonctionnalité dédiée à la gestion de l'avatar utilisateur.

L'architecture prévoit notamment un contrôleur :

```text
ProfileAvatarController
```

avec un état basé sur :

```text
AsyncValue<void>
```

afin de représenter les états de l'opération :

```text
Loading → Success
        ↘ Error
```

---

# 🌙 Thème clair et sombre

L'application possède une gestion du mode d'affichage avec un contrôleur dédié.

Le thème peut être géré à travers Riverpod et la préférence d'affichage peut être conservée localement.

Le projet utilise :

```text
SharedPreferences
```

pour les préférences locales qui ne nécessitent pas Firestore.

---

# 🧭 Navigation

La navigation est construite avec **go_router**.

Le projet possède notamment des routes pour :

* authentification ;
* accueil ;
* profil ;
* conversations ;
* nouvelle conversation ;
* détail d'une conversation ;
* écran de démarrage.

La navigation est également connectée à l'état d'authentification.

```text
Firebase Auth
     │
     ▼
authStateProvider
     │
     ▼
AuthRouterRefresh
     │
     ▼
GoRouter
     │
 ┌───┴────┐
 ▼        ▼
Login    Home
```

Cela permet de protéger les écrans nécessitant une authentification et de rediriger automatiquement l'utilisateur lorsque son état de session change.

---

# 🧠 Gestion d'état avec Riverpod

**Riverpod** est utilisé pour la gestion de l'état et l'injection des dépendances.

Le projet utilise plusieurs types de providers, notamment :

* `Provider`
* `StreamProvider`
* `StreamProvider.family`
* `NotifierProvider`

### Exemple : authentification

```text
FirebaseAuth
     ↓
AuthRemoteDataSource
     ↓
AuthRepository
     ↓
Use Cases
     ↓
AuthController
     ↓
UI
```

### Exemple : chat

Les conversations et messages sont exposés sous forme de flux :

```text
StreamProvider.family<List<ChatEntity>, String>
```

et :

```text
StreamProvider.family<List<MessageEntity>, String>
```

Cela permet à l'interface de recevoir automatiquement les mises à jour provenant de Firestore.

---

# 🏛️ Architecture du projet

Le projet suit une organisation par fonctionnalités inspirée de la **Clean Architecture**.

```text
lib/
│
├── core/
│   ├── constants/
│   ├── preferences/
│   ├── router/
│   ├── theme/
│   └── utils/
│
└── features/
    │
    ├── auth/
    │   ├── data/
    │   ├── domain/
    │   └── presentation/
    │
    ├── chat/
    │   ├── data/
    │   ├── domain/
    │   └── presentation/
    │
    └── profile/
        ├── data/
        ├── domain/
        └── presentation/
```

### Data

Responsable de l'accès aux sources de données.

Exemples :

* Firebase Authentication ;
* Cloud Firestore ;
* Firebase Storage.

### Domain

Contient la logique métier indépendante des détails de présentation.

On y retrouve notamment :

* entities ;
* repositories ;
* use cases.

### Presentation

Contient :

* pages ;
* widgets ;
* controllers ;
* providers ;
* états de l'interface.

### Core

Contient les éléments transversaux :

* navigation ;
* thème ;
* préférences ;
* constantes ;
* utilitaires.

---

# 🔄 Principe de séparation des responsabilités

L'application évite autant que possible de placer directement la logique Firebase dans les pages Flutter.

Par exemple, pour l'authentification :

```text
LoginPage
    │
    ▼
AuthController
    │
    ▼
LoginUseCase
    │
    ▼
AuthRepository
    │
    ▼
AuthRemoteDataSource
    │
    ▼
FirebaseAuth
```

Cette séparation permet de :

* tester les différentes couches ;
* remplacer une source de données plus facilement ;
* limiter le couplage ;
* maintenir une structure claire ;
* faciliter le travail en équipe.

---

# 🧪 Tests et qualité

La qualité du projet est vérifiée avec les outils Flutter.

### Analyse statique

```bash
flutter analyze
```

Résultat sur la branche de référence :

```text
No issues found!
```

### Tests automatisés

```bash
flutter test
```

Résultat :

```text
56 tests passed
```

Les tests couvrent notamment différentes parties de l'application, avec des tests liés à :

* authentification ;
* profil ;
* chat ;
* fonctionnalités d'image ;
* providers ;
* use cases ;
* widgets ;
* gestion des préférences.

---

# 🧪 Approche QA

Le projet comprend également une démarche de **Quality Assurance**.

Le travail QA a notamment permis de :

* identifier les problèmes d'intégration ;
* corriger des tests après intégration de branches ;
* documenter les constats ;
* vérifier les fonctionnalités après fusion ;
* contrôler la stabilité du projet.

L'objectif n'est pas uniquement de vérifier que l'application compile, mais de vérifier que les fonctionnalités continuent de fonctionner après l'intégration des différentes contributions.

---

# 🛠️ Technologies et dépendances principales

| Technologie                 | Rôle                          |
| --------------------------- | ----------------------------- |
| **Flutter**                 | Framework mobile              |
| **Dart**                    | Langage                       |
| **Firebase Core**           | Initialisation Firebase       |
| **Firebase Authentication** | Authentification              |
| **Cloud Firestore**         | Données et temps réel         |
| **Firebase Storage**        | Stockage de fichiers/images   |
| **Riverpod**                | Gestion d'état et dépendances |
| **go_router**               | Navigation                    |
| **SharedPreferences**       | Préférences locales           |
| **image_picker**            | Sélection d'images            |
| **image**                   | Traitement d'images           |
| **mime**                    | Détection des types MIME      |
| **Flutter Test**            | Tests                         |
| **Integration Test**        | Tests d'intégration           |
| **Git / GitHub**            | Collaboration                 |

---

# 📦 Installation

## Prérequis

* Flutter SDK compatible avec le projet
* Dart SDK
* Android Studio
* Android SDK
* Appareil Android ou émulateur
* Compte/projet Firebase configuré

## Cloner le projet

```bash
git clone https://github.com/ParkerDieuveil/devcommunity_chat.git

cd devcommunity_chat
```

## Installer les dépendances

```bash
flutter pub get
```

## Vérifier le projet

```bash
flutter analyze
```

## Exécuter les tests

```bash
flutter test
```

## Lancer l'application

```bash
flutter run
```

---

# 🔥 Configuration Firebase

DevCommunity Chat utilise Firebase comme backend pour plusieurs fonctionnalités.

Services utilisés :

```text
Firebase Authentication
        +
Cloud Firestore
        +
Firebase Storage
```

La configuration Flutter Firebase est générée via :

```text
firebase_options.dart
```

Les informations sensibles et credentials privés ne doivent pas être ajoutés manuellement au dépôt.

---

# 🌳 Workflow Git et GitHub

Le projet utilise une stratégie de développement basée sur les branches et les Pull Requests.

```text
feature/*
    │
    ▼
 Pull Request
    │
    ▼
 develop
    │
    ▼
 Pull Request
    │
    ▼
 main
```

Les branches principales sont protégées afin d'éviter les modifications directes non vérifiées.

Chaque fonctionnalité importante peut être développée séparément puis intégrée après validation.

---

# 📈 Historique des contributions

Le projet a été développé progressivement à travers plusieurs contributions et Pull Requests.

Parmi les travaux intégrés figurent notamment :

### 🔐 Authentification

Mise en place de Firebase Authentication, des repositories, use cases, providers et gestion des erreurs.

### 🖼️ Messagerie avec images

Une branche dédiée a permis d'introduire :

* permissions ;
* image picker ;
* traitement des images ;
* Storage ;
* use case d'envoi ;
* affichage dans le chat ;
* tests associés.

### 👤 Profil et avatar

Le projet comprend également des travaux dédiés au profil et au téléchargement/gestion de l'avatar.

### 🌙 Thème

Une fonctionnalité dédiée permet de gérer le changement de thème.

### 🧪 QA et tests

Une branche spécifique a été consacrée à la couverture des tests et à la documentation QA.

Cette organisation permet de retracer les contributions directement dans l'historique GitHub.

---

# 👨‍💻 Collaboration d'équipe

Le projet a été réalisé par le **Groupe 8 du FlutterFire Summer Camp 2026**.

Le développement repose sur une collaboration GitHub permettant à chaque membre de contribuer à différentes parties du projet.

Les contributions peuvent être vérifiées à travers :

* commits ;
* branches ;
* Pull Requests ;
* corrections ;
* tests ;
* documentation.

Cette organisation permet également de suivre l'évolution du projet au cours du développement.

---

# 📊 État actuel

La branche de référence utilisée pour la validation actuelle présente une base stable comprenant notamment :

* ✅ authentification Firebase ;
* ✅ inscription / connexion / déconnexion ;
* ✅ persistance de session ;
* ✅ navigation protégée ;
* ✅ chat ;
* ✅ synchronisation Firestore ;
* ✅ profils ;
* ✅ avatar ;
* ✅ gestion du thème ;
* ✅ messagerie avec images dans le périmètre prévu ;
* ✅ gestion d'état Riverpod ;
* ✅ Clean Architecture ;
* ✅ tests automatisés ;
* ✅ QA ;
* ✅ documentation.

### Validation actuelle

```text
flutter analyze
→ No issues found!

flutter test
→ 56 tests passed
```

La persistance de session a également été vérifiée manuellement sur un appareil Android.

---

# 🔮 Perspectives

Le projet peut continuer à évoluer avec notamment :

* 🔔 notifications push ;
* 🔎 recherche avancée d'utilisateurs et de conversations ;
* 📎 amélioration du partage de fichiers ;
* 🛡️ modération et signalement ;
* 👥 gestion avancée des membres de groupes ;
* 📊 fonctionnalités communautaires ;
* 🔔 notifications de nouveaux messages ;
* ☁️ amélioration de la gestion des médias ;
* 🎨 amélioration continue de l'expérience utilisateur.

---

# 🏆 FlutterFire Summer Camp 2026

**Projet :** DevCommunity Chat
**Groupe :** 8
**Catégorie :** Communication & Réseaux Sociaux

### Notre objectif

> **Créer un espace simple et moderne permettant aux développeurs de communiquer, partager et construire leur communauté.**

---

## 📄 Licence

Projet académique réalisé dans le cadre du **FlutterFire Summer Camp 2026**.
