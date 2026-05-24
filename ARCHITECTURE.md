# Architecture — app_mobile

> Application mobile **Schooly** — carnet de liaison numérique multi-rôles.  
> Stack : **Flutter 3 + Dart 3.10 + Material Design 3**  
> Cibles : Android, iOS, Web, Linux, macOS, Windows (multi-plateforme Flutter)

---

## 1. Vue d'ensemble

```
app_mobile/
├── lib/                  # Code source Dart (toute la logique applicative)
│   ├── main.dart         # Point d'entrée Flutter
│   ├── app.dart          # Widget racine (MaterialApp + routing)
│   ├── app/              # Configuration globale (router, store, auth_provider)
│   ├── features/         # Modules métier par domaine (feature-based)
│   └── shared/           # Code partagé entre features (theme, utils, widgets)
├── assets/               # Ressources statiques (images, icônes, publicités)
├── android/              # Projet natif Android (Gradle + Kotlin)
├── ios/                  # Projet natif iOS (Xcode + Swift)
├── web/                  # Cible web Flutter
├── linux/ macos/ windows/# Cibles desktop Flutter
├── test/                 # Tests widget Flutter
└── pubspec.yaml          # Dépendances et configuration Flutter
```

---

## 2. Point d'entrée et arbre des widgets

```
main.dart
 └── App (StatelessWidget)
      └── MaterialApp
           ├── theme: AppTheme (Material3, seedColor deepPurple)
           ├── initialRoute: '/'
           └── onGenerateRoute: AppRouter.generateRoute
```

`main.dart` est minimal — il appelle simplement `runApp(const App())`. Toute la configuration est dans `app.dart`.

---

## 3. Routing (`lib/app/router.dart`)

Le routing utilise le système impératif de Flutter (`onGenerateRoute` + `Navigator.pushNamed`). Pas de package tiers (go_router, auto_route).

| Route | Widget | Description |
|---|---|---|
| `/` | `SplashScreenPage` | Écran de démarrage |
| `/select_role` | `SelectRolePage` | Sélection du rôle (Parent / Enseignant / Élève) |
| `/login` | `LoginPage(role)` | Connexion — reçoit le `UserRole` en argument |
| `/parent/home` | `ParentHomePage` | Dashboard parent |
| `/teacher/home` | `TeacherHomePage` | Dashboard enseignant |
| `/student/home` | `StudentMainPage` | Dashboard élève |

### Flux de navigation

```
SplashScreen
    │
    ▼
SelectRolePage  ──── tap carte ────►  LoginPage (modal bottom sheet)
                                           │
                              ┌────────────┼────────────┐
                              ▼            ▼             ▼
                        ParentHomePage  TeacherHomePage  StudentMainPage
```

La `LoginPage` est présentée en **modal bottom sheet** (hauteur 90%) depuis `SelectRolePage`, pas comme une route pleine page.

---

## 4. Gestion d'état

L'application est actuellement en **phase de prototypage UI**. La gestion d'état est locale (setState) et les slices sont des placeholders vides.

| Fichier | État actuel |
|---|---|
| `lib/app/store.dart` | Classe vide `AppStore` — non utilisée |
| `lib/app/auth_provider.dart` | `ChangeNotifier` vide — non injecté dans l'arbre |
| `lib/features/*/xxx_slice.dart` | Toutes les slices sont des classes vides (placeholder) |

**Conséquence** : toute la logique d'état est gérée localement avec `setState` dans les `StatefulWidget`. Il n'y a pas encore de Provider, Riverpod, Bloc ou autre solution globale en place.

---

## 5. Architecture Feature-Based (`lib/features/`)

Chaque domaine métier est un module autonome. La structure est inspirée du pattern feature-slice.

```
lib/features/
├── auth/           # Authentification et sélection de rôle
├── splash/         # Écran de démarrage
├── parent/         # Espace parent (dashboard multi-enfants)
├── teacher/        # Espace enseignant (classes, appel, devoirs)
├── student/        # Espace élève (dashboard, cahier, agenda)
├── communication/  # Messagerie et annonces
├── documents/      # Gestion de documents et signatures
└── notifications/  # Notifications push
```

### Détail des features

#### `auth`
```
auth/
├── pages/
│   ├── splash_screen_page.dart   → (dans features/splash)
│   ├── select_role.dart          → Sélection Parent / Enseignant / Élève
│   ├── login.dart                → Formulaire de connexion par rôle
│   ├── create_account.dart       → Création de compte (flux "nouveau")
│   └── first_access.dart         → Premier accès
└── services/
    └── auth_service.dart         → Logique d'auth (simulée)
```

`AuthService` simule 3 cas :
- username contient `"fail"` → `invalidCredentials`
- username contient `"new"` → `userNotFound` (propose création de compte)
- sinon → `success`

**Mode démo actif** : la `LoginPage` bypass complètement l'auth pour les rôles Parent, Teacher et Student — elle navigue directement vers le home.

#### `parent`
La feature la plus complète. Dashboard multi-enfants avec :

```
parent/
├── pages/
│   ├── parent_home_page.dart     → Shell principal (BottomNavigationBar 4 onglets)
│   ├── child_dashboard.dart      → Vue détaillée d'un enfant
│   ├── child_details_page.dart   → Détails complets
│   ├── children_list.dart        → Liste des enfants
│   ├── calendar_page.dart        → Calendrier scolaire de l'enfant
│   └── textbook_page.dart        → Cahier de textes
├── components/
│   ├── child_card.dart           → Carte résumé d'un enfant
│   ├── attendance_status.dart    → Statut de présence
│   ├── homework_preview.dart     → Aperçu des devoirs
│   └── signature_modal.dart      → Modal de signature
├── widgets/
│   └── child_details_view.dart   → Vue détaillée inline
└── services/
    └── parent_service.dart       → Service API parent
```

**Navigation interne** : `BottomNavigationBar` à 4 onglets dont le contenu change dynamiquement selon qu'un enfant est sélectionné ou non (ex. onglet 1 = "Messages" sans enfant, "Cahier" avec enfant sélectionné).

**Données démo** : 3 enfants hardcodés (Yannick, Emmanuella, Junior) dans 3 établissements différents (`SchoolConfigs`).

#### `teacher`
Dashboard enseignant multi-établissements :

```
teacher/
├── pages/
│   ├── teacher_home.dart         → Shell (BottomNavigationBar 5 onglets)
│   ├── teacher_classes_page.dart → Liste des classes
│   ├── class_dashboard.dart      → Dashboard d'une classe
│   ├── attendance.dart / attendance_view.dart → Appel des élèves
│   ├── homework_manager.dart / create_homework_page.dart → Gestion devoirs
│   ├── grades_entry_view.dart    → Saisie des notes
│   ├── textbook_view.dart        → Cahier de textes
│   ├── teacher_messages_page.dart → Messagerie
│   ├── teacher_student_list_page.dart → Liste élèves
│   └── teacher_profile_page.dart → Profil enseignant
└── components/
    ├── class_selector.dart       → Sélecteur de classe
    └── student_list.dart         → Liste des élèves
```

**Navigation interne** : `BottomNavigationBar` à 5 onglets (Accueil, Classes, Cours/Planning, Messages, Profil).

**Fonctionnalité notable** : switcher d'établissement (chip selector) — un enseignant peut intervenir dans plusieurs écoles.

#### `student`
Dashboard élève :

```
student/
└── pages/
    ├── student_main_page.dart        → Shell (BottomNavigationBar 5 onglets)
    ├── student_dashboard_page.dart   → Accueil élève
    ├── student_textbook_page.dart    → Cahier de textes
    ├── student_homework_page.dart    → Devoirs
    ├── student_messages_page.dart    → Messages
    ├── student_profile_page.dart     → Profil
    ├── student_home.dart             → (variante)
    ├── student_details_pages.dart    → Détails
    └── messages.dart / homework.dart → (variantes)
```

**Navigation interne** : `BottomNavigationBar` à 5 onglets (Accueil, Cahier, Agenda, Messages, Profil).

#### `communication`
```
communication/
├── pages/
│   ├── messages.dart       → Interface de messagerie
│   └── announcements.dart  → Annonces de l'établissement
└── components/
    ├── message_card.dart         → Carte de message
    └── confirmation_badge.dart   → Badge de confirmation de lecture
```

#### `documents`
```
documents/
├── pages/
│   └── documents.dart      → Liste et gestion des documents
└── components/
    ├── document_viewer.dart  → Visualiseur de document
    └── signature_pad.dart    → Pad de signature numérique
```

#### `notifications`
```
notifications/
└── services/
    └── notifications_service.dart  → Service de notifications push
```

---

## 6. Code partagé (`lib/shared/`)

| Dossier/Fichier | Rôle |
|---|---|
| `config/school_config.dart` | Constantes des établissements (noms, couleurs primaires). 3 écoles définies : Notre-Dame, Sainte-Thérèse, École Catholique |
| `theme/app_theme.dart` | Palette de couleurs globale + styles de boutons et cartes réutilisables |
| `utils/user_role.dart` | Enum `UserRole` (parent, teacher, student) avec label, couleur, icône, imagePath et flag `hasQrCode` |
| `utils/constants.dart` | Constantes globales (minimal — juste `appName`) |
| `hooks/use_auth.dart` | Hook d'auth partagé (non encore implémenté) |
| `layout/main_layout.dart` | Layout de base (wrapper `Scaffold` minimal) |
| `pages/appointment_page.dart` | Page de rendez-vous partagée entre rôles |
| `ui/app_button.dart` | Bouton réutilisable |
| `widgets/background_wrapper.dart` | Wrapper de fond d'écran (utilisé sur toutes les pages) |

### Palette de couleurs (`AppTheme`)

| Nom | Hex | Usage |
|---|---|---|
| `forestGreen` | `#1B4332` | Couleur principale, boutons, enseignants |
| `seaBlue` | `#0077B6` | Navigation active, liens, parents |
| `sunYellow` | `#FBC02D` | Alertes, urgences, élèves |
| `background` | `#F8F9FB` | Fond général |
| `loginBackground` | `#EFF3F6` | Fond écran de connexion |
| `textDark` | `#2D3748` | Texte principal |
| `textGrey` | `#718096` | Texte secondaire |

---

## 7. Assets (`assets/`)

```
assets/
├── icons/
│   └── schooly_logo.png      # Logo de l'app (aussi utilisé comme launcher icon)
├── images/
│   ├── parent.png / teacher.png / eleve.png / font.png
│   ├── profil/               # Photos de profil (élèves, parents)
│   └── iconEcole/            # Icônes des établissements
├── actualité/                # Images actualités (BEPC, équipe)
├── emploie/                  # Image emploi du temps
├── bulletin/                 # Image bulletin scolaire
└── publicit/                 # Bannières publicitaires (pub1.jpg, pub2.jpg, pub3.jpg)
```

Le launcher icon Android/iOS est généré automatiquement depuis `assets/icons/schooly_logo.png` via `flutter_launcher_icons`.

---

## 8. Dépendances (`pubspec.yaml`)

### Production
| Package | Version | Usage |
|---|---|---|
| `flutter` (SDK) | — | Framework UI |
| `cupertino_icons` | ^1.0.8 | Icônes style iOS |

**Observation importante** : l'application n'utilise **aucune dépendance tierce** au-delà des icônes Cupertino. Pas de package HTTP (dio, http), pas de gestion d'état (provider, riverpod, bloc), pas de stockage local (shared_preferences, hive). Tout est simulé en mémoire.

### Dev
| Package | Usage |
|---|---|
| `flutter_lints` | Règles de lint |
| `flutter_launcher_icons` | Génération des icônes de lancement |

---

## 9. Cibles de déploiement

Flutter génère un binaire natif pour chaque plateforme depuis le même code Dart.

| Plateforme | Dossier | État |
|---|---|---|
| Android | `android/` | Configuré — keystore de signature présent (`upload-keystore.jks`) |
| iOS | `ios/` | Configuré — projet Xcode complet |
| Web | `web/` | Configuré — manifest PWA inclus |
| Linux | `linux/` | Configuré — CMakeLists.txt |
| macOS | `macos/` | Configuré — projet Xcode |
| Windows | `windows/` | Configuré — CMakeLists.txt + runner Win32 |

---

## 10. Tests

```
test/
└── widget_test.dart    # Test widget par défaut Flutter (counter app template)
```

Un seul fichier de test présent — le test généré automatiquement par Flutter. Aucun test métier écrit.

---

## 11. Flux de données typique (état actuel)

```
Utilisateur (tap)
    │
    ▼
StatefulWidget (page)
    │  setState()
    ▼
Rebuild UI local
    │
    (pas d'appel API réel)
    │
    ▼
AuthService (simulé — Future.delayed 1s)
    │
    ▼
Navigation vers home du rôle
```

---

## 12. Points d'attention

| Sujet | Observation |
|---|---|
| **Pas de gestion d'état globale** | `AppStore` et `AuthProvider` sont des placeholders vides. Toute la logique est en `setState` local. À implémenter (Riverpod ou Bloc recommandé) |
| **Pas d'appels API réels** | `AuthService` simule les réponses avec `Future.delayed`. Aucun package HTTP n'est installé. La connexion au backend `api_skooly` n'est pas encore faite |
| **Mode démo hardcodé** | Les données (enfants, classes, notes) sont toutes hardcodées dans les widgets. Pas de couche service réelle |
| **Login bypassé** | `LoginPage._login()` navigue directement sans vérification pour les 3 rôles — pratique pour le prototypage, à retirer en production |
| **Slices vides** | Tous les `*_slice.dart` sont des classes vides. La nomenclature "slice" (inspirée Redux/Zustand) est en place mais non implémentée |
| **Doublons de pages** | Plusieurs pages semblent en doublon : `student_home.dart` vs `student_dashboard_page.dart`, `attendance.dart` vs `attendance_view.dart`, `parent_home.dart` vs `parent_home_page.dart` |
| **`shared/hooks/use_auth.dart`** | Fichier présent mais non implémenté — naming inspiré des hooks React, inhabituel en Flutter |
| **Pas de localisation** | Toutes les chaînes sont en dur en français. Pas de package `intl` ou `flutter_localizations` |
| **Aucune dépendance réseau** | Pour connecter l'app au backend Laravel, il faudra ajouter `dio` ou `http` + un système de token JWT |
