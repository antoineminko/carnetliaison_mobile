# SCHOOLY - Analyse Technique : Logique et Flux des Interfaces

## 📱 Vue d'ensemble

Schooly est une application mobile de carnet de liaison académique développée en Flutter. Elle connecte trois acteurs principaux : **Parents**, **Enseignants** et **Élèves** pour faciliter le suivi scolaire et la communication.

---

## 🎯 Architecture Globale

### Flux d'Authentification
```
SplashScreen → SelectRole → Login (par rôle) → Dashboard (Parent/Teacher/Student)
```

### Structure des Features
- **auth/** : Authentification et sélection de rôle
- **parent/** : Interface parent avec suivi des enfants
- **teacher/** : Interface enseignant avec gestion de classes
- **student/** : Interface élève (en développement)
- **communication/** : Messages et annonces
- **documents/** : Gestion documentaire
- **notifications/** : Système de notifications

---

## 👨‍👩‍👧 INTERFACE PARENT - Logique et Flux

### 1. Architecture de Navigation

#### BottomNavigationBar (4 onglets dynamiques)
L'interface parent utilise une navigation contextuelle qui change selon l'état :

**Mode Global (aucun enfant sélectionné) :**
- 🏠 Accueil : Dashboard global avec liste des enfants
- 💬 Messages : Messagerie (en construction)
- 📅 Événements : Calendrier global (en construction)
- 👤 Profil : Profil parent et préférences

**Mode Enfant (enfant sélectionné) :**
- 🏠 Accueil : Détails de l'enfant sélectionné
- 📖 Cahier : Cahier de texte numérique
- 🔔 Alertes : Calendrier de présence et incidents
- 👤 Profil : Profil parent (inchangé)

### 2. Flux Principal Parent

```
ParentHomePage (État initial)
    ↓
┌─────────────────────────────────────┐
│  Dashboard Global                    │
│  - Header avec notifications         │
│  - Liste horizontale avatars enfants │
│  - Cartes enfants avec infos clés    │
└─────────────────────────────────────┘
    ↓ (Clic sur un enfant)
┌─────────────────────────────────────┐
│  ChildDetailsView                    │
│  - Header enfant (retour possible)   │
│  - TabBar : Aperçu/Actualités/Devoirs│
│  - Contenu dynamique par onglet      │
└─────────────────────────────────────┘
    ↓ (Navigation bottom bar)
┌──────────────────┬──────────────────┐
│  TextbookPage    │  CalendarPage    │
│  (Cahier texte)  │  (Présences)     │
└──────────────────┴──────────────────┘
```

### 3. Composants Clés Parent

#### A. Dashboard Global (`_buildGlobalDashboard`)
**Logique :**
- Affiche tous les enfants du parent
- Toggle démo pour simuler état vide
- Badge de notifications global
- Liste horizontale d'avatars pour sélection rapide
- Cartes verticales détaillées par enfant

**Données affichées par enfant :**
- Photo et badge école
- Nom, classe, ID
- Statut présence du jour
- Nombre de notifications
- Devoirs à venir
- Actualités récentes

#### B. ChildDetailsView (Vue détaillée enfant)
**Structure en 3 onglets :**

**Onglet Aperçu :**
- Présence du jour (statut + heure arrivée)
- Notification quiz/notes (si applicable)
- Liste devoirs à venir (expandable)
- Actualités école (carte avec image)

**Onglet Actualités :**
- Flux complet des actualités
- Images et descriptions détaillées

**Onglet Devoirs :**
- Liste complète des devoirs
- Détails par matière avec horaires

#### C. TextbookPage (Cahier de texte)
**Logique :**
- Sélection enfant (si plusieurs)
- Affichage du contenu de cours publié par l'enseignant
- Résumé des séances
- Devoirs assignés
- Documents joints

#### D. CalendarPage (Suivi présences)
**Fonctionnalités :**
- Profil enfant avec statistiques d'assiduité
- Calendrier mensuel avec indicateurs visuels
  - 🔴 Rouge : Absence
  - 🟠 Orange : Retard
  - 🟢 Vert : Justifié
- Liste incidents récents
- Modal de justification d'absence
  - Motifs prédéfinis (maladie, RDV médical, transport, etc.)
  - Envoi de justification

#### E. Profil Parent
**Sections :**
- Photo et informations personnelles
- Email et téléphone
- Liste enfants avec bouton ajout
- Préférences notifications (Push/SMS/Email)
- Changement mot de passe
- Déconnexion






## 👨‍🏫 INTERFACE TEACHER - Logique et Flux

### 1. Architecture de Navigation

#### BottomNavigationBar (5 onglets fixes)
- 🏠 Accueil : Dashboard enseignant
- 📚 Classes : Liste des classes
- 💬 Messages : Messagerie (en construction)
- 📅 Planning : Emploi du temps (en construction)
- 👤 Profil : Profil enseignant

### 2. Flux Principal Teacher

```
TeacherHomePage
    ↓
┌─────────────────────────────────────┐
│  Dashboard Enseignant                │
│  - Header avec salutation            │
│  - Carte "Prochaine Classe" (hero)   │
│  - Grille priorités du jour (4 cards)│
└─────────────────────────────────────┘
    ↓ (Navigation vers Classes)
┌─────────────────────────────────────┐
│  TeacherClassesPage                  │
│  - Liste des classes enseignées      │
│  - Infos : matière, nb élèves, session│
└─────────────────────────────────────┘
    ↓ (Sélection d'une classe)
┌─────────────────────────────────────┐
│  ClassDashboardPage                  │
│  - Header classe avec gradient       │
│  - TabBar : 5 onglets                │
│    • Appel                           │
│    • Cahier de texte                 │
│    • Devoirs                         │
│    • Élèves                          │
│    • Statistiques                    │
└─────────────────────────────────────┘
    ↓
┌──────────────────┬──────────────────┐
│  AttendanceView  │  TextbookView    │
│  (Faire l'appel) │  (Publier cours) │
└──────────────────┴──────────────────┘
```

### 3. Composants Clés Teacher

#### A. Dashboard Enseignant (`_buildHomeContent`)
**Sections :**

**Header :**
- Salutation personnalisée ("Bonjour M. Obiang")
- Date du jour
- Photo de profil

**Carte Prochaine Classe (Hero) :**
- Gradient bleu-cyan moderne
- Nom de la classe (ex: CM1-A)
- Salle et horaires
- Design accrocheur pour attirer l'attention

**Grille Priorités (4 cartes) :**
1. **Faire l'appel** (Rouge/Coral) - Badge URGENT
2. **Publier devoir** (Teal)
3. **Messages** (Jaune/Orange) - Compteur non lus
4. **Agenda** (Bleu) - Compteur événements

**Logique des cartes priorités :**
```dart
_buildPriorityCard(
  title: String,
  subtitle: String,
  icon: IconData,
  color: Color,
  isUrgent: bool,
  onTap: VoidCallback,
)
```

#### B. TeacherClassesPage (Liste des classes)
**Affichage :**
- Header avec date
- Liste scrollable de cartes classes
- Chaque carte affiche :
  - Bande colorée latérale (couleur unique par classe)
  - Nom classe (ex: CM1-A)
  - Matière enseignée
  - Nombre d'élèves
  - Session (Matin/Après-midi)
  - Flèche navigation


#### C. ClassDashboardPage (Tableau de bord classe)
**Structure :**
- Header avec gradient (nom classe, nb élèves, session)
- TabController avec 5 onglets
- Bouton flottant contextuel (visible uniquement sur onglet Cahier de texte)

**Onglets :**
1. **APPEL** → AttendanceView
2. **CAHIER DE TEXTE** → TextbookView
3. **DEVOIRS** → Placeholder
4. **ÉLÈVES** → Placeholder
5. **STATISTIQUES** → Placeholder


**Interface :**
1. **Header métriques**
   - Compteur progression (ex: "15 / 35 marqués")
   - Bouton "Tout présent" (marque tous en un clic)

2. **Grille numérotée (5 colonnes)**
   - Chaque case = numéro élève
   - Couleur selon statut :
     - Gris/Blanc : Non marqué
     - Vert : Présent
     - Rouge : Absent
     - Jaune : Retard
   - Animation au changement de statut
   - Ombre colorée si marqué

3. **Modal détail élève (clic sur numéro)**
   - Avatar avec numéro
   - Nom et matricule
   - 3 boutons statut :
     - PRÉSENT (vert)
     - ABSENT (rouge)
     - RETARD (jaune)

4. **Bouton validation**
   - Fixé en bas
   - "VALIDER L'APPEL"
   - Confirmation par SnackBar

**Fonctions clés :**
```dart
void _toggleStatus(int index) {
  // Cycle : null → present → absent → late → present
}

void _markAllPresent() {
  // Marque tous les élèves présents
}

void _updateMarkedCount() {
  // Recalcule le nombre d'élèves marqués
}

void _showStudentProfileModal(int index) {
  // Affiche modal détail élève
}
```

#### E. TextbookView (Cahier de texte)
**Formulaire en 3 sections :**

**1. Identification du cours**
- Dropdown matière (Maths, Français, Histoire-Géo, Sciences)
- Classe (fixe, passée en paramètre)
- Date picker

**2. Résumé du cours**
- TextArea multiligne pour contenu
- Boutons :
  - "Ajouter un document"
  - "Lien externe"

**3. Devoirs à faire**
- Description du travail (TextField)
- Date d'échéance (DatePicker)
- Estimation temps (Dropdown : 15min, 30min, 45min, 1h+)
- Bouton "Ajouter" pour devoirs multiples

**Publication :**
- Bouton "Publier pour les parents" (dans ClassDashboardPage)
- Envoie le contenu aux parents via le système
- Confirmation par SnackBar

**Structure données :**
```dart
{
  'subject': String?,
  'className': String,
  'date': String,
  'content': String,
  'attachments': List<String>,
  'homework': {
    'description': String,
    'dueDate': String,
    'estimatedTime': String,
  }
}
```

### 4. États et Gestion Teacher

**TeacherHomePage :**
```dart
int _currentIndex = 0;  // Index bottom navigation
```

**ClassDashboardPage :**
```dart
TabController _tabController;  // Gestion des onglets
```

**AttendanceView :**
```dart
List<Map<String, dynamic>> _students;
int _markedCount;
```

**TextbookView :**
```dart
String? _selectedSubject;
TextEditingController _contentController;
TextEditingController _homeworkController;
String _homeworkTime;
```

### 5. Interactions Teacher Clés

**Sélection classe :**
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ClassDashboardPage(
      className: className,
      studentCount: studentCount,
      session: session,
    ),
  ),
);
```

**Changement onglet classe :**
```dart
_tabController.addListener(() {
  setState(() {}); // Mise à jour UI (bouton flottant)
});
```

**Marquer présence :**
```dart
setState(() {
  _students[index]['status'] = AttendanceStatus.present;
  _updateMarkedCount();
});
```

**Publier cahier de texte :**
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('Cahier de texte publié ! 🚀'),
    backgroundColor: Color(0xFF48C774),
  ),
);
```

---

## 🔄 Flux de Données Inter-Rôles

### Teacher → Parent
1. **Cahier de texte**
   - Teacher publie via TextbookView
   - Parent consulte via TextbookPage
   - Contenu : résumé cours + devoirs

2. **Présences**
   - Teacher marque via AttendanceView
   - Parent voit via CalendarPage
   - Statuts : Présent/Absent/Retard

3. **Notes/Évaluations**
   - Teacher saisit (fonctionnalité future)
   - Parent reçoit notification
   - Affichage dans ChildDetailsView

### Parent → Teacher
1. **Justifications d'absence**
   - Parent envoie via CalendarPage
   - Teacher reçoit notification
   - Validation/Refus possible

2. **Messages**
   - Communication bidirectionnelle
   - Via module communication (en construction)

---
