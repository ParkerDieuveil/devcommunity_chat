# DevCommunity Chat 🚀

Application mobile de messagerie destinée aux équipes de développement et aux communautés de développeurs.

Le projet est réalisé dans le cadre du **FlutterFire Summer Camp 2026**.

---

## 📱 Présentation

DevCommunity Chat permet aux développeurs de communiquer au sein d'une équipe ou d'une communauté grâce à une interface de messagerie moderne.

L'application a pour objectif de proposer une expérience de communication simple, rapide et adaptée aux communautés techniques.

### Fonctionnalités principales

* Création de compte
* Connexion
* Déconnexion
* Gestion de session utilisateur
* Profil utilisateur
* Messagerie en temps réel
* Envoi de messages
* Réception des messages en temps réel
* Gestion des états avec Riverpod
* Persistance des données avec Cloud Firestore
* Navigation avec GoRouter

### Fonctionnalité bonus

* Envoi d'images depuis la galerie
* Stockage des images avec Firebase Storage

---

## 🛠️ Technologies

* Flutter
* Dart
* Firebase Authentication
* Cloud Firestore
* Firebase Storage
* Riverpod
* GoRouter
* Git
* GitHub

---

## 🏗️ Architecture

Le projet utilise **Clean Architecture** afin de séparer les responsabilités et permettre à plusieurs développeurs de travailler indépendamment sur les différentes fonctionnalités.

```text
lib/
│
├── core/
│   ├── constants/
│   ├── router/
│   ├── theme/
│   └── utils/
│
├── features/
│   ├── auth/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── chat/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   └── profile/
│       ├── data/
│       ├── domain/
│       └── presentation/
│
├── firebase_options.dart
└── main.dart
```

### Responsabilités des couches

#### Presentation

Contient :

* Pages
* Widgets
* Providers Riverpod
* Gestion de l'affichage
* Interactions utilisateur

La couche Presentation ne communique pas directement avec Firebase.

#### Domain

Contient :

* Entités
* Interfaces des repositories
* Use Cases
* Logique métier

Cette couche ne dépend pas directement de Firebase.

#### Data

Contient :

* Models
* Data Sources
* Implémentations des repositories
* Communication avec Firebase

---

## 🔄 Flux de données

Le principe général est :

```text
Presentation
      ↓
  Riverpod
      ↓
   UseCase
      ↓
 Repository
      ↓
     Data
      ↓
   Firebase
```

Exemple pour l'authentification :

```text
LoginPage
    ↓
AuthProvider
    ↓
LoginUseCase
    ↓
AuthRepository
    ↓
FirebaseAuthRepository
    ↓
Firebase Authentication
```

---

## 🧭 Navigation

La navigation est gérée avec **GoRouter**.

Routes principales :

```text
/login
/home
```

Le système de navigation sera ensuite connecté à l'état d'authentification Firebase.

Le comportement prévu est :

```text
Utilisateur non connecté
        ↓
      /login

Utilisateur connecté
        ↓
      /home
```

---

## 📦 Installation

### Prérequis

Installer :

* Flutter
* Dart
* Android Studio ou un environnement compatible
* Git

Vérifier Flutter :

```bash
flutter --version
```

Vérifier l'environnement :

```bash
flutter doctor
```

---

## 🚀 Installation du projet

Cloner le repository :

```bash
git clone https://github.com/ParkerDieuveil/devcommunity_chat.git
```

Entrer dans le projet :

```bash
cd devcommunity_chat
```

Récupérer les dépendances :

```bash
flutter pub get
```

---

## 🔥 Firebase

Le projet utilise Firebase.

La configuration FlutterFire est présente dans :

```text
lib/firebase_options.dart
```

Initialisation Firebase dans `main.dart` :

```dart
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

Les règles de sécurité Firebase doivent être correctement configurées avant la mise en production.

---

## ▶️ Lancer l'application

Utiliser :

```bash
flutter run
```

Pour sélectionner un appareil :

```bash
flutter devices
```

Puis :

```bash
flutter run -d <device>
```

---

## 🧪 Tests

Exécuter les tests :

```bash
flutter test
```

Analyser le projet :

```bash
flutter analyze
```

Avant de créer une Pull Request, les commandes suivantes doivent être exécutées :

```bash
flutter analyze
flutter test
flutter run
```

---

## 🌿 Git Workflow

Le projet utilise trois niveaux de branches :

```text
main
  ↑
develop
  ↑
feature/*
```

### `main`

Version stable du projet.

### `develop`

Branche d'intégration.

### `feature/*`

Branche utilisée pour développer une fonctionnalité.

Exemple :

```bash
git checkout develop
git pull origin develop
git checkout -b feature/firebase-auth
```

Après développement :

```bash
flutter analyze
flutter test
git add .
git commit -m "feat: implement firebase authentication"
git push -u origin feature/firebase-auth
```

Créer ensuite une Pull Request :

```text
feature/firebase-auth → develop
```

---

## 📝 Conventions de commits

| Préfixe     | Utilisation               |
| ----------- | ------------------------- |
| `feat:`     | Nouvelle fonctionnalité   |
| `fix:`      | Correction de bug         |
| `refactor:` | Refactorisation           |
| `test:`     | Tests                     |
| `docs:`     | Documentation             |
| `chore:`    | Maintenance/configuration |

Exemples :

```text
feat: implement chat interface
fix: handle firestore error
test: add login widget tests
docs: update installation guide
refactor: improve auth repository
chore: update dependencies
```

---

## 📐 Conventions de code

### Fichiers

Utiliser `snake_case` :

```text
login_page.dart
auth_repository.dart
message_model.dart
```

### Classes

Utiliser `PascalCase` :

```dart
class LoginPage {}

class AuthRepository {}

class MessageModel {}
```

### Variables et méthodes

Utiliser `camelCase` :

```dart
currentUser
messageText
loginUser()
sendMessage()
```

### Models

Les models utilisent le suffixe :

```text
Model
```

Exemples :

```text
UserModel
MessageModel
ChatModel
```

### Repositories

Interface :

```text
AuthRepository
```

Implémentation :

```text
FirebaseAuthRepository
```

### Use Cases

Exemples :

```text
LoginUseCase
RegisterUseCase
LogoutUseCase
SendMessageUseCase
```

---

## 👥 Collaboration

Le développement suit le principe :

```text
RESPONSABLE
     ↓
DÉVELOPPE
     ↓
DOCUMENTE
     ↓
EXPLIQUE AU GROUPE
     ↓
UN AUTRE MEMBRE RELIT / TESTE
     ↓
PULL REQUEST
     ↓
REVIEW
     ↓
MERGE
```

Chaque membre doit connaître :

* son Issue ;
* les tâches associées ;
* les critères d'acceptation ;
* la branche utilisée ;
* les conventions du projet.

---

## 📅 Organisation quotidienne

Une courte réunion quotidienne de **10 à 15 minutes** permet de répondre à trois questions :

1. Qu'est-ce que j'ai fait hier ?
2. Qu'est-ce que je vais faire aujourd'hui ?
3. Est-ce que j'ai un blocage ?

Les problèmes techniques doivent être signalés rapidement afin que l'équipe puisse les résoudre ensemble.

---

## 🎯 Objectif du projet

L'objectif est de construire une application Flutter fonctionnelle, maintenable et développée en collaboration selon les bonnes pratiques professionnelles.

Le projet met particulièrement l'accent sur :

* Clean Architecture
* Firebase
* Riverpod
* Git/GitHub
* travail collaboratif
* tests
* qualité du code
* développement en équipe
