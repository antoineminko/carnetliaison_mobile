# Analyse Architecture — Feature Teacher + Plan de Refactoring
> Projet `carnetliaison_mobile` · 30 juin 2026

---

## 1. Structure actuelle vs réalité

```
lib/features/teacher/
│
├── teacher_slice.dart         ❌ STUB (classe vide)
│
├── components/
│   ├── class_selector.dart    ❌ STUB (DropdownButton vide)
│   └── student_list.dart      ❌ STUB (ListView vide)
│
└── pages/
    ├── teacher_home.dart               ✅ RÉEL (~1 104 lignes) ⚠️ DONNÉES FAKE
    ├── teacher_classes_page.dart       ✅ RÉEL (~500 lignes) ⚠️ DONNÉES FAKE
    ├── class_dashboard.dart            ✅ RÉEL (~400 lignes)
    ├── attendance_view.dart            ✅ RÉEL (~974 lignes)
    ├── teacher_student_list_page.dart  ✅ RÉEL (~999 lignes)
    ├── teacher_messages_page.dart      ✅ RÉEL (~250 lignes)
    ├── teacher_profile_page.dart       ✅ RÉEL (~300 lignes)
    ├── create_homework_page.dart       ✅ RÉEL (~600 lignes)
    ├── create_appointment_page.dart    ✅ RÉEL (~350 lignes)
    ├── parent_info_page.dart           ✅ RÉEL (~200 lignes)
    ├── grades_entry_view.dart          ✅ RÉEL (~300 lignes) ⚠️ DONNÉES FAKE
    ├── textbook_view.dart              ✅ RÉEL (~350 lignes)
    ├── homework_manager.dart           ❓ NON LU (fichier présent)
    └── attendance.dart                 ❌ STUB (placeholder vide)
```

---

## 2. Fichiers avec beaucoup de lignes

| Fichier | Lignes | État | Description |
|---------|--------|------|-------------|
| `teacher_home.dart` | ~1 104 | ✅ Implémenté | Shell 5 onglets + dashboard + données fake classes |
| `attendance_view.dart` | ~974 | ✅ Implémenté | Faire l'appel + actions globales + API |
| `teacher_student_list_page.dart` | ~999 | ✅ Implémenté | Liste élèves + multi-sélection + signalement incidents |
| `create_homework_page.dart` | ~600 | ✅ Implémenté | Création devoir (maison/classe/exercice) |
| `teacher_classes_page.dart` | ~500 | ✅ Implémenté | Espace cours (3 onglets) + données fake |

---

## 3. Fichiers avec données fake hardcodées

### 🔴 `teacher_home.dart` — ~1 104 lignes

**Dashboard fake** :
```dart
// ❌ DONNÉES FAKE — à supprimer et remplacer par API
final teacher = _dashboardData?['teacher'] ?? {};
final classes = (_dashboardData?['classes'] as List?) ?? [];

// Carousel publicitaire hardcodé
final List<String> _bannerImages = [
  'https://i.pinimg.com/736x/46/c9/7f/46c97fda08fb8c284e70704de113fa1a.jpg',
  'https://i.pinimg.com/736x/70/84/85/7084854f0a3841d6cfda063c0ad64ccc.jpg',
  'https://www.aciafrica.org/images/gabon_1642722311.jpg',
];
```

### 🔴 `teacher_classes_page.dart` — ~500 lignes

**Emploi du temps hardcodé** :
```dart
// ❌ DONNÉES FAKE — à remplacer par API
final List<Map<String, dynamic>> todayMorningClasses = [
  {
    'name': 'Terminale A', 
    'subject': 'Philosophie', 
    'students': 35, 
    'time': '08:00 - 10:00', 
    'color': AppTheme.forestGreen,
    'school': SchoolConfigs.sainteTherese,
  },
  {
    'name': 'Terminale C', 
    'subject': 'Physique-Chimie', 
    'students': 28, 
    'time': '10:30 - 12:30', 
    'color': AppTheme.seaBlue,
    'school': SchoolConfigs.notreDame,
  },
];

final List<Map<String, dynamic>> todayAfternoonClasses = [
  // ... données statiques
];

final List<Map<String, dynamic>> tomorrowClasses = [
  // ... données statiques
];
```

### 🟠 `grades_entry_view.dart` — ~300 lignes

**Liste élèves simulée** :
```dart
// ❌ SIMULATION — à remplacer par API
final List<Map<String, dynamic>> students = [
  {'id': 'STU-001', 'name': 'Yannick MPIGA', 'grade': ''},
  {'id': 'STU-002', 'name': 'Awa NDIAYE', 'grade': ''},
  {'id': 'STU-003', 'name': 'Jean-Marc ONDO', 'grade': ''},
  // ... 12 autres hardcodés
];

void _simulateExcelImport() {
  // Simulation remplissage depuis Excel
  for (var student in students) {
    student['grade'] = (10 + (students.indexOf(student) % 10)).toStringAsFixed(1);
  }
}
```

---

## 4. Architecture actuelle (ce qui tourne)

```
TeacherHomePage (StatefulWidget)
│
├── BottomNavigationBar (5 onglets)
│   ├── Onglet 0 — Accueil
│   │   ├── _buildHomeContent()
│   │   │   ├── Header avec switcheur écoles (Sainte Thérèse / Notre-Dame)
│   │   │   ├── Carte "Prochaine classe" (classe principale)
│   │   │   ├── GridView 4 cartes priorités (Faire appel, Publier devoir, Messages, Agenda)
│   │   │   └── _buildPromoBanner() (carousel auto avec Timer 3s)
│   │   
│   ├── Onglet 1 — Classes
│   │   └── TeacherClassesPage (3 sous-onglets)
│   │       ├── Cours (aujourd'hui AM/PM + demain)
│   │       ├── Calendrier (grille mensuelle)
│   │       └── Notifications (liste hardcodée)
│   │
│   ├── Onglet 2 — Planning / Événements
│   │   └── _buildPlanningTab()
│   │       ├── Toggle disponibilité RDV
│   │       ├── Liste RDV parents (fetch API)
│   │       └── Liste demandes messagerie (fetch API)
│   │
│   ├── Onglet 3 — Messages
│   │   └── TeacherMessagesPage (2 sous-onglets)
│   │       ├── Parents (conversations fetch API)
│   │       └── Administration (vide)
│   │
│   └── Onglet 4 — Profil
│       └── TeacherProfilePage
│           ├── Avatar initiales
│           ├── Infos enseignant (SharedPreferences)
│           ├── Liste établissements (scroll horizontal avec retrait)
│           ├── Préférences notifications (3 switchs)
│           └── Déconnexion
│
├── ClassDashboardPage (Page indépendante)
│   ├── Header classe (nom, matière, horaires, école)
│   ├── GridView 6 raccourcis
│   │   ├── Résultats → GradesEntryView
│   │   ├── Faire l'appel → AttendanceView
│   │   ├── Cahier de textes → TextbookView
│   │   ├── Saisie Notes → GradesEntryView
│   │   ├── Messages → TeacherMessagesPage
│   │   └── Signaler → TeacherStudentListPage
│   └── Timeline événements du jour
│
└── Modaux / Pages secondaires
    ├── AttendanceView (grille élèves + actions globales)
    ├── TextbookView (résumé cours + devoirs)
    ├── GradesEntryView (saisie notes + import Excel simulé)
    ├── CreateHomeworkPage (type + classe + élèves + détails + date)
    ├── CreateAppointmentPage (type RDV + date/heure + motif)
    ├── ParentInfoPage (infos parent + boutons Message/RDV)
    └── TeacherStudentListPage (grille + multi-sélection + incidents)
```

---

## 5. Problèmes identifiés

### 🔴 Critiques

| # | Problème | Fichier | Impact |
|---|----------|---------|--------|
| 1 | Données fake hardcodées (emploi du temps) | `teacher_classes_page.dart` | Les vrais cours ne sont jamais affichés |
| 2 | Liste élèves simulée dans saisie notes | `grades_entry_view.dart` | Simulation Excel ne fonctionne pas avec l'API |
| 3 | Pas de service teacher dédié | Absence | Appels API éparpillés dans chaque page |
| 4 | BottomNavigationBar 5 onglets dans 1 fichier | `teacher_home.dart` | God file (1 104 lignes) |

### 🟠 Importants

| # | Problème | Fichier | Impact |
|---|----------|---------|--------|
| 5 | 2 composants stubs jamais utilisés | `components/` | Architecture trompeuse |
| 6 | `attendance.dart` stub inutilisé | `pages/` | Doublon avec `attendance_view.dart` |
| 7 | `teacher_slice.dart` vide | `teacher_slice.dart` | Fichier inutile |
| 8 | Timer carousel non annulé si dispose rapide | `teacher_home.dart` | Fuite mémoire potentielle |
| 9 | Junior détecté par nom hardcodé "Junior" | `teacher_student_list_page.dart`, `attendance_view.dart` | Logique fragile si élève renommé |
| 10 | Pas de gestion d'erreur réseau centralisée | Tous fichiers | Crash silencieux si API down |

### 🟡 Mineurs

| # | Problème | Fichier |
|---|----------|---------|
| 11 | `withOpacity` déprécié Flutter 3.x | Partout |
| 12 | Print() de debug en production | `teacher_student_list_page.dart`, `teacher_messages_page.dart` |
| 13 | Chat dans `features/parent/messages/` mais utilisé par teacher | Structure |
| 14 | Icônes matière hardcodées dans `textbook_view.dart` | Widget |

---

## 6. Plan de refactoring — Architecture propre

### Objectifs
1. ✅ Supprimer toutes les données fake
2. ✅ Créer un service teacher centralisé
3. ✅ Restructurer en 4 onglets propres (Accueil, Événements, Messages, Profil)
4. ✅ Créer dossier `espace_classe/` séparé
5. ✅ Gestion d'erreurs robuste
6. ✅ Scalabilité pour multi-écoles

---

### ✨ Nouvelle structure proposée

```
lib/features/teacher/
│
├── services/
│   └── teacher_service.dart          ← ✅ CRÉER (appels API centralisés)
│
├── accueil/
│   ├── teacher_home_dashboard.dart   ← ✅ EXTRAIRE de teacher_home.dart
│   └── widgets/
│       ├── school_switcher.dart      ← ✅ EXTRAIRE (chip écoles)
│       ├── next_class_card.dart      ← ✅ EXTRAIRE (carte bleue classe)
│       ├── priority_grid.dart        ← ✅ EXTRAIRE (grid 4 raccourcis)
│       └── promo_banner.dart         ← ✅ EXTRAIRE (carousel pub)
│
├── evenements/
│   ├── teacher_events_page.dart      ← ✅ RENOMMER _buildPlanningTab()
│   └── widgets/
│       ├── availability_toggle.dart  ← ✅ EXTRAIRE
│       ├── appointment_list.dart     ← ✅ EXTRAIRE
│       └── conversation_requests.dart← ✅ EXTRAIRE
│
├── messages/
│   └── teacher_messages_page.dart    ← ✅ CONSERVER (déjà propre)
│
├── profil/
│   └── teacher_profile_page.dart     ← ✅ CONSERVER (déjà propre)
│
├── espace_classe/
│   ├── class_dashboard.dart          ← ✅ CONSERVER
│   ├── widgets/
│   │   ├── class_header_card.dart    ← ✅ EXTRAIRE
│   │   ├── shortcuts_grid.dart       ← ✅ EXTRAIRE
│   │   └── timeline_events.dart      ← ✅ EXTRAIRE
│   │
│   ├── resultats/
│   │   └── grades_entry_view.dart    ← ✅ DÉPLACER + FIX API
│   │
│   ├── faire_appel/
│   │   └── attendance_view.dart      ← ✅ DÉPLACER
│   │
│   ├── cahier_texte/
│   │   └── textbook_view.dart        ← ✅ DÉPLACER
│   │
│   ├── saisie_notes/
│   │   └── grades_entry_view.dart    ← ✅ ALIAS (même que resultats/)
│   │
│   ├── messages/
│   │   └── [lien vers ../messages/] ← ✅ RÉFÉRENCE
│   │
│   └── signaler/
│       ├── student_list_page.dart    ← ✅ RENOMMER teacher_student_list_page.dart
│       └── widgets/
│           ├── student_card.dart     ← ✅ EXTRAIRE
│           ├── incident_modal.dart   ← ✅ EXTRAIRE
│           └── multi_incident_modal.dart ← ✅ EXTRAIRE
│
├── devoirs/
│   └── create_homework_page.dart     ← ✅ CONSERVER
│
├── rendez_vous/
│   ├── create_appointment_page.dart  ← ✅ CONSERVER
│   └── parent_info_page.dart         ← ✅ CONSERVER
│
└── teacher_home.dart                 ← ✅ REFACTOR (seulement BottomNav + routing)
```

---

### 🛠 Actions de refactoring prioritaires

#### **Priorité 1 — Créer `teacher_service.dart`**

```dart
// lib/features/teacher/services/teacher_service.dart
class TeacherService {
  // Dashboard
  static Future<Map<String, dynamic>> getDashboard(int teacherId) async {
    final response = await ApiClient.instance.get(
      ApiEndpoints.teacherDashboard(teacherId),
    );
    if (response.data['success'] != true) {
      throw Exception('Erreur dashboard');
    }
    return response.data;
  }

  // Classes de l'enseignant
  static Future<List<Map<String, dynamic>>> getClasses(int teacherId) async {
    final response = await ApiClient.instance.get(
      '/enseignants/$teacherId/classes',
    );
    return List<Map<String, dynamic>>.from(response.data['classes'] ?? []);
  }

  // Élèves d'une classe
  static Future<List<Map<String, dynamic>>> getClassStudents(int classId) async {
    final response = await ApiClient.instance.get(
      '/classes/$classId/eleves',
    );
    return List<Map<String, dynamic>>.from(response.data ?? []);
  }

  // Événements (RDV + conversations)
  static Future<Map<String, dynamic>> getEvents(int teacherId) async {
    final response = await ApiClient.instance.get(
      '/enseignants/$teacherId/events',
    );
    return {
      'appointments': response.data['appointments'] ?? [],
      'conversations': response.data['conversations'] ?? [],
    };
  }

  // Conversations
  static Future<List<Map<String, dynamic>>> getConversations(int teacherId) async {
    final response = await ApiClient.instance.get(
      ApiEndpoints.teacherConversations(teacherId),
    );
    return List<Map<String, dynamic>>.from(
      response.data['conversations'] ?? [],
    );
  }
}
```

---

#### **Priorité 2 — Supprimer les données fake**

**`teacher_classes_page.dart`** :
```dart
// ❌ SUPPRIMER todayMorningClasses, todayAfternoonClasses, tomorrowClasses

// ✅ REMPLACER PAR
List<Map<String, dynamic>> _classes = [];

@override
void initState() {
  super.initState();
  _loadClasses();
}

Future<void> _loadClasses() async {
  final teacherId = await AuthService.getTeacherId();
  if (teacherId == null) return;
  
  final classes = await TeacherService.getClasses(teacherId);
  setState(() {
    _classes = classes;
  });
}
```

**`grades_entry_view.dart`** :
```dart
// ❌ SUPPRIMER students hardcodés + _simulateExcelImport()

// ✅ REMPLACER PAR
List<Map<String, dynamic>> _students = [];

@override
void initState() {
  super.initState();
  _loadStudents();
}

Future<void> _loadStudents() async {
  // Récupérer classe sélectionnée puis ses élèves via TeacherService
  final students = await TeacherService.getClassStudents(classId);
  setState(() {
    _students = students;
  });
}
```

---

#### **Priorité 3 — Refactorer `teacher_home.dart`**

**Avant (1 104 lignes)** :
- Tout dans un seul fichier
- 5 onglets inline
- Carousel, header, grid inline

**Après (~200 lignes)** :
```dart
// lib/features/teacher/teacher_home.dart
class TeacherHomePage extends StatefulWidget {
  @override
  State<TeacherHomePage> createState() => _TeacherHomePageState();
}

class _TeacherHomePageState extends State<TeacherHomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Événements'),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Messages'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return TeacherHomeDashboard(); // ← Nouveau fichier
      case 1:
        return TeacherEventsPage();    // ← Nouveau fichier
      case 2:
        return TeacherMessagesPage();  // ← Existant
      case 3:
        return TeacherProfilePage();   // ← Existant
      default:
        return Container();
    }
  }
}
```

---

#### **Priorité 4 — Retirer "Classes" de la navbar**

**Avant** : 5 onglets (Accueil, Classes, Planning, Messages, Profil)

**Après** : 4 onglets (Accueil, Événements, Messages, Profil)

- La page "Classes" devient une carte cliquable dans l'accueil
- Navigation vers `TeacherClassesPage` via `Navigator.push()` (pas de navbar)

---

#### **Priorité 5 — Organiser `espace_classe/`**

```
espace_classe/
├── class_dashboard.dart              (entrée principale, cadre bleu + grid raccourcis)
├── resultats/
│   └── grades_entry_view.dart        (saisie notes API + publish)
├── faire_appel/
│   └── attendance_view.dart          (grille élèves + API save)
├── cahier_texte/
│   └── textbook_view.dart            (résumé cours + devoirs)
├── saisie_notes/
│   → [alias vers resultats/]
├── messages/
│   → [référence ../messages/]
└── signaler/
    └── student_list_page.dart        (liste + incidents)
```

**Widgets à extraire** :
- `class_header_card.dart` (cadre bleu en haut)
- `shortcuts_grid.dart` (grid 6 boutons)
- `student_card.dart` (carte élève dans la grille)
- `incident_modal.dart` (modal signalement 1 élève)
- `multi_incident_modal.dart` (modal signalement multiple)

---

#### **Priorité 6 — Gestion d'erreurs robuste**

**Pattern à appliquer partout** :
```dart
try {
  final data = await TeacherService.getClasses(teacherId);
  setState(() {
    _classes = data;
    _isLoading = false;
  });
} on DioException catch (e) {
  if (!mounted) return;
  final message = e.response?.data?['message'] ?? e.message;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Erreur: $message')),
  );
  setState(() => _isLoading = false);
} catch (e) {
  if (!mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Erreur réseau: $e')),
  );
  setState(() => _isLoading = false);
}
```

---

#### **Priorité 7 — Remplacer détection "Junior" par ID**

**Avant (fragile)** :
```dart
if (student['name'] == 'Junior') {
  // Logique spéciale
}
```

**Après (robuste)** :
```dart
// Basé sur données API (flag ou seuil)
if (student['absences_count'] != null && student['absences_count'] >= 3) {
  // Afficher avertissement
}

if (student['average'] != null && student['average'] < 10) {
  // Afficher avertissement performance
}
```

---

## 7. Checklist de migration

### Phase 1 : Services & Nettoyage (1-2 jours)
- [ ] Créer `services/teacher_service.dart` avec toutes les méthodes API
- [ ] Supprimer données fake `teacher_classes_page.dart`
- [ ] Supprimer données fake `grades_entry_view.dart`
- [ ] Supprimer `teacher_slice.dart`, `attendance.dart`, `components/*.dart`
- [ ] Remplacer tous les print() par `if (kDebugMode) debugPrint()`

### Phase 2 : Refactor teacher_home.dart (2-3 jours)
- [ ] Créer `accueil/teacher_home_dashboard.dart`
- [ ] Extraire `widgets/school_switcher.dart`
- [ ] Extraire `widgets/next_class_card.dart`
- [ ] Extraire `widgets/priority_grid.dart`
- [ ] Extraire `widgets/promo_banner.dart` (+ fix Timer dispose)
- [ ] Réduire `teacher_home.dart` à ~200 lignes (seulement BottomNav)

### Phase 3 : Retirer Classes de navbar (1 jour)
- [ ] Passer de 5 à 4 onglets (supprimer "Classes")
- [ ] Ajouter carte "Mes Classes" dans l'accueil
- [ ] Navigation vers `TeacherClassesPage` via push (pas navbar)

### Phase 4 : Réorganiser espace_classe/ (2-3 jours)
- [ ] Créer structure dossiers `espace_classe/` (resultats, faire_appel, etc.)
- [ ] Déplacer fichiers existants
- [ ] Extraire `widgets/class_header_card.dart`
- [ ] Extraire `widgets/shortcuts_grid.dart`
- [ ] Extraire `widgets/student_card.dart`
- [ ] Extraire `widgets/incident_modal.dart`
- [ ] Extraire `widgets/multi_incident_modal.dart`

### Phase 5 : Gestion d'erreurs (1 jour)
- [ ] Appliquer pattern try/catch robuste partout
- [ ] Ajouter loading states partout
- [ ] Tester déconnexion réseau
- [ ] Tester erreurs API (401, 404, 500)

### Phase 6 : Tests & Validation (1-2 jours)
- [ ] Tester navigation complète
- [ ] Tester création devoir
- [ ] Tester faire l'appel
- [ ] Tester signalement incident
- [ ] Tester saisie notes
- [ ] Tester cahier de textes
- [ ] Tester messages
- [ ] Tester RDV

---

## 8. Ce qui fonctionne bien

- ✅ `AttendanceView` est bien conçu (grille, actions globales, API save)
- ✅ `CreateHomeworkPage` est complet (type, ciblage élèves, API publish)
- ✅ `TeacherStudentListPage` supporte la multi-sélection
- ✅ `CreateAppointmentPage` gère physique + vidéo
- ✅ Toutes les pages utilisent `ApiClient.instance` (pas de requêtes raw)
- ✅ La plupart des pages utilisent `SharedPreferences` pour teacherId
- ✅ Les couleurs sont cohérentes (`AppTheme.seaBlue`, `forestGreen`, `sunYellow`)

---

*Analyse générée sur la base du code source lu en intégralité.*
