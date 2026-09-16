# DevCommunity Chat

> Connecter les développeurs. Faciliter les échanges. Construire la communauté.

**DevCommunity Chat** est une application mobile de messagerie d’équipe, développée avec **Flutter** et **Firebase** dans le cadre du **FlutterFire Summer Camp 2026 (Groupe 8)**.

Elle offre un espace dédié pour communiquer, créer des conversations, animer des groupes et gérer un profil, avec une expérience claire et adaptée aux communautés techniques.

---

## Présentation

Les équipes et communautés de développeurs ont besoin d’un canal simple pour échanger rapidement, partager des médias et garder le contexte au même endroit.

DevCommunity Chat propose notamment :

* authentification sécurisée ;
* conversations en temps réel ;
* groupes nommés ;
* partage d’images et de messages vocaux ;
* profils et avatar ;
* thème clair et sombre ;
* interface bilingue (français / anglais) ;
* navigation structurée ;
* restauration de session au démarrage.

---

## Objectifs du projet

### 1. Créer un espace de communication dédié

Permettre aux membres d’une équipe ou d’une communauté technologique de communiquer depuis une application mobile unique.

### 2. Mettre en pratique Flutter et Firebase

Le projet met en œuvre concrètement :

* Flutter et Dart ;
* Firebase Authentication ;
* Cloud Firestore ;
* Firebase Storage ;
* Riverpod ;
* navigation déclarative (GoRouter) ;
* architecture logicielle ;
* tests automatisés.

### 3. Appliquer une architecture maintenable

L’application s’appuie sur une organisation inspirée de la **Clean Architecture**, afin de séparer l’interface utilisateur, la logique métier et l’accès aux données.

### 4. Travailler comme une équipe

Le développement suit un workflow Git et GitHub : branches thématiques, Pull Requests, revues, tests et intégrations progressives vers `develop`.

---

## Fonctionnalités

### Authentification

Gestion des comptes avec **Firebase Authentication** :

* inscription par email et mot de passe ;
* connexion et déconnexion ;
* observation de l’état de session ;
* protection des routes selon l’état de connexion ;
* validation renforcée des emails (refus des adresses de test / démo) ;
* messages d’erreur exploitables côté interface.

### Restauration de session

Au lancement, un écran de démarrage laisse le temps à Firebase de restaurer la session avant que le routeur choisisse la destination.

```text
                 Lancement
                     |
                     v
                  Splash
                     |
                     v
          Restauration de session
                     |
              +------+------+
              |             |
          Connecté      Non connecté
              |             |
              v             v
            Home           Login
```

Un utilisateur déjà authentifié peut donc rouvrir l’application sans repasser inutilement par l’écran de connexion.

### Onboarding

Au premier lancement, un parcours d’introduction présente le produit (discussions d’équipe, médias, profil, temps réel Firebase). L’état « déjà vu » est persisté localement via SharedPreferences.

### Messagerie

Le module de chat s’appuie sur **Cloud Firestore** :

* liste des conversations avec **badges de non-lus** (style messagerie) ;
* recherche unifiée (discussions + contacts) depuis l’écran Chats ;
* création d’un chat 1:1 avec **réutilisation du même `chatId`** pour une paire d’utilisateurs ;
* invitation (copie presse-papiers) si l’email recherché n’a pas encore de compte — **pas de fausse discussion** ;
* création de groupes avec **nom persisté** ;
* envoi et réception de messages texte en temps réel ;
* **pagination / lazy loading** des messages (10 récents à l’ouverture, +10 au scroll vers le haut) ;
* affichage via `ListView.builder` ;
* bulles style Messenger / WhatsApp (couleurs clair / sombre) ;
* accusés de lecture (`readBy`) : coches ✓ / ✓✓, appui long « Vu par », **mini-avatars** sous le dernier message lu (style Messenger) ;
* marquage des messages lus (remet le compteur à zéro) ;
* prévisualisation et horodatage localisés (FR / EN).

Les flux sont exposés via des `StreamProvider` Riverpod, ce qui permet à l’interface de réagir automatiquement aux mises à jour Firestore.

Flux simplifié :

```text
             Flutter UI
                 |
                 v
          Riverpod Provider
                 |
                 v
             Use Case
                 |
                 v
            Repository
                 |
                 v
       Remote Data Source
                 |
                 v
           Cloud Firestore
```

### Médias dans les conversations

L’application permet d’envoyer :

* des **images** (caméra ou galerie) ;
* des **messages vocaux**.

Le panneau de pièces jointes n’expose que les actions réellement supportées (caméra, enregistrement, galerie).

Dépendances principales : `image_picker`, `image`, `mime`, `record`, `audioplayers`, `firebase_storage`.

#### Note Firebase Storage

L’upload dépend de l’activation et de la configuration du bucket Storage sur le projet Firebase, ainsi que des règles de sécurité déployées. Une erreur `404 Not Found` côté Storage indique en général un bucket non provisionné, indépendamment de la logique Flutter.

### Conversations et groupes

La navigation principale distingue clairement :

* **Chats** : conversations (1:1 et groupes) ;
* **Groupes** : filtre dédié aux conversations multi-participants ;
* **Profil** : informations et édition ;
* **Plus** : langue, thème, informations.

Le bouton **« + »** central (FAB docké dans l’encoche de la barre) ouvre le menu nouveau contact / nouveau groupe.

Les groupes créés portent un nom visible dans les listes et l’en-tête de conversation.

### Profil utilisateur

* affichage du profil ;
* édition (pseudo, titre, bio) ;
* avatar ;
* synchronisation avec les données Firestore / Auth ;
* **présence en ligne réelle** (`isOnline` / `lastSeen` Firestore) : pastille sur les avatars, libellé dans le profil et l’en-tête de conversation ;
* cycle de vie app + heartbeat (pas de mock) : online à la reprise, offline en arrière-plan / logout ; affichage seulement si `lastSeen` est récent.

### Thème et localisation

* thème clair / sombre (préférence locale) ;
* chaînes d’interface FR / EN via un provider de locale.

### Expérience utilisateur

Des transitions légères (fade / slide) animent notamment :

* l’ouverture du panneau de pièces jointes ;
* le passage entre états de liste (chargement, vide, contenu).

La barre de navigation utilise une **encoche** (`CircularNotchedRectangle`) pour accueillir le FAB « + », avec un état sélectionné discret (icône / label brand, sans pavé concurrent).

---

## Navigation

Navigation déclarative avec **go_router**, reliée à l’état d’authentification et à l’onboarding.

Espaces principaux une fois connecté :

```text
/home  →  Chats | Groupes | Profil | Plus
```

Autres routes utiles :

* `/login`, `/register` ;
* `/onboarding`, `/splash` ;
* nouvelle discussion / création de groupe ;
* détail d’une conversation.

```text
Firebase Auth
     |
     v
authStateProvider
     |
     v
AuthRouterRefresh
     |
     v
  GoRouter
     |
  +--+--+
  |     |
Login  Home
```

---

## Gestion d’état avec Riverpod

Riverpod assure la gestion d’état et l’injection des dépendances (`Provider`, `StreamProvider`, `NotifierProvider`, etc.).

Exemple authentification :

```text
FirebaseAuth
     |
AuthRemoteDataSource
     |
AuthRepository
     |
Use Cases
     |
AuthController
     |
UI
```

Exemple chat (flux) :

```text
StreamProvider.family<List<ChatEntity>, String>
StreamProvider.family<List<MessageEntity>, String>
```

---

## Architecture du projet

Organisation par fonctionnalités, inspirée de la Clean Architecture.

```text
lib/
|
+-- core/
|     +-- locale/
|     +-- preferences/
|     +-- router/
|     +-- theme/
|     +-- utils/
|     +-- widgets/
|
+-- features/
|     +-- auth/
|     |     +-- data/
|     |     +-- domain/
|     |     +-- presentation/
|     |
|     +-- chat/
|     |     +-- data/
|     |     +-- domain/
|     |     +-- presentation/
|     |
|     +-- onboarding/
|     |     +-- presentation/
|     |
|     +-- profile/
|           +-- data/
|           +-- domain/
|           +-- presentation/
|
+-- firebase_options.dart
+-- main.dart
```

### Couches

| Couche | Rôle |
| ------ | ---- |
| **Presentation** | Pages, widgets, providers, interactions |
| **Domain** | Entités, contrats de repositories, use cases |
| **Data** | Models, data sources, implémentations Firebase |
| **Core** | Navigation, thème, locale, utilitaires partagés |

La Presentation ne parle pas directement à Firebase : elle passe par Riverpod, puis par les use cases et repositories.

---

## Technologies

| Technologie | Rôle |
| ----------- | ---- |
| Flutter / Dart | Application mobile |
| Firebase Authentication | Comptes et session |
| Cloud Firestore | Données et temps réel |
| Firebase Storage | Images et audio |
| Riverpod | État et dépendances |
| go_router | Navigation |
| SharedPreferences | Préférences locales |
| image_picker / image / mime | Pipeline images |
| record / audioplayers | Messages vocaux |
| Flutter Test | Tests automatisés |

---

## Installation

### Prérequis

* Flutter SDK compatible avec le projet
* Android Studio (ou équivalent) et SDK Android
* Appareil ou émulateur
* Projet Firebase configuré (`lib/firebase_options.dart`)

### Cloner et préparer

```bash
git clone https://github.com/ParkerDieuveil/devcommunity_chat.git
cd devcommunity_chat
flutter pub get
```

### Vérifier et lancer

```bash
flutter analyze
flutter test
flutter run
```

---

## Configuration Firebase

Services utilisés :

```text
Firebase Authentication
        +
Cloud Firestore
        +
Firebase Storage
```

Points d’attention pour la démo :

1. Auth email / mot de passe activé ;
2. Firestore avec règles adaptées aux chats et profils ;
3. Storage **activé** (création du bucket) et règles déployées (`storage.rules`).

Les credentials privés ne doivent pas être ajoutés manuellement au dépôt.

---

## Tests et qualité

```bash
flutter analyze
flutter test
```

La suite de tests couvre notamment l’authentification, le chat, le profil, l’onboarding, les préférences et les utilitaires (formats de dates, validateurs).

Une démarche QA documentée est également présente dans `docs/qa/` (checklist, rapport de bugs, rapport de validation), en cohérence avec le travail intégré sur `develop`.

---

## Workflow Git

```text
feature/*
    |
    v
 Pull Request
    |
    v
 develop
    |
    v
 Pull Request
    |
    v
  main
```

Conventions de commits :

| Préfixe | Usage |
| ------- | ----- |
| `feat:` | Nouvelle fonctionnalité |
| `fix:` | Correction |
| `refactor:` | Restructuration sans changement de comportement |
| `test:` | Tests |
| `docs:` | Documentation |
| `chore:` | Maintenance / configuration |
| `polish:` | Finitions UI / UX |

Cette branche `feature/ui-polish` concentre le polish produit (navigation, onboarding, i18n, médias, groupes, thème) avant intégration dans `develop`.

---

## État actuel (feature/ui-polish)

Base fonctionnelle pour la démonstration du camp :

* authentification et session ;
* splash et onboarding ;
* messagerie temps réel avec badges non-lus ;
* recherche discussions / contacts + invite si non inscrit ;
* un seul chat 1:1 par paire d’utilisateurs ;
* pagination messages (10) + `ListView.builder` ;
* accusés de lecture + mini-avatars « vu » (Messenger) ;
* présence en ligne réelle (Firestore + lifecycle) ;
* groupes avec nom ;
* images et vocaux (sous réserve Storage) ;
* profil et avatar ;
* thème et localisation FR / EN ;
* navigation Chats / Groupes / Profil / Plus + FAB « + » central ;
* architecture Clean + Riverpod ;
* animations UI légères ;
* tests automatisés.

Référence d’intégration : les avancées de documentation et de stabilisation présentes sur `develop` (README enrichi, QA, persistance de session) sont prises en compte dans ce document afin d’aligner la présentation du produit.

---

## Perspectives

* notifications push ;
* partage d’invitation natif (au-delà du presse-papiers) ;
* gestion enrichie des membres de groupe ;
* amélioration continue des médias et de l’accessibilité.

---

## FlutterFire Summer Camp 2026

| | |
| --- | --- |
| **Projet** | DevCommunity Chat |
| **Groupe** | 8 |
| **Catégorie** | Communication et réseaux sociaux |

> Créer un espace simple et moderne permettant aux développeurs de communiquer, partager et construire leur communauté.

---

## Licence

Projet académique réalisé dans le cadre du **FlutterFire Summer Camp 2026**.
