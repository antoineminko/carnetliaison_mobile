# Analyse Architecture — Feature Parent
> Projet `carnetliaison_mobile` · 30 juin 2026

---

## Structure déclarée vs réalité

```
lib/features/parent/
│
├── pages/
│   ├── parent_home_page.dart     ✅ RÉEL      (~4 165 lignes) ⚠️ GOD FILE + DONNÉES FAKE
│   ├── child_dashboard.dart      ❌ STUB       (10 lignes — placeholder vide)
│   ├── child_details_page.dart   ⚠️ LEGACY    (~350 lignes — ancienne version 3 onglets)
│   ├── children_list.dart        ❌ STUB       (10 lignes — placeholder vide)
│   ├── calendar_page.dart        ✅ RÉEL      (~350 lignes)
│   ├── textbook_page.dart        ✅ RÉEL      (~300 lignes) ⚠️ DONNÉES FAKE
│   └── chat_page.dart            ✅ RÉEL      (~500 lignes)
│
├── components/
│   ├── child_card.dart           ❌ STUB       (Card vide — widget réel est dans parent_home_page.dart)
│   ├── attendance_status.dart    ❌ STUB       (Card vide — logique réelle dans child_details_view.dart)
│   ├── homework_preview.dart     ❌ STUB       (Card vide — logique réelle dans child_details_view.dart)
│   └── signature_modal.dart      ❌ STUB       (Dialog vide — jamais implémenté)
│
├── widgets/
│   └── child_details_view.dart   ✅ RÉEL      (~2 280 lignes) ⚠️ FICHIER MASSIF
│
├── services/
│   └── parent_service.dart       ✅ RÉEL      (~50 lignes)
│
└── parent_slice.dart             ❌ STUB       (classe vide ParentSlice{})
```

---

## Fichiers avec beaucoup de lignes de code

### 🔴 `parent_home_page.dart` — ~4 165 lignes
C'est le fichier le plus problématique du module. Il contient **tout** :
- Le shell `BottomNavigationBar` (4 onglets)
- La logique de chargement des enfants via API
- Le dashboard global
- La liste enfants + widget `_ChildCard` défini en bas du même fichier
- La messagerie (`_buildMessagesTab`, `_buildMessageList`, `_buildMessageTile`)
- Les événements et RDV (`_buildEventsTab`, `_buildRdvCard`)
- Le profil complet (`_buildProfileView`)
- Les modaux (notifications, ajout enfant, saisie manuelle)
- Le carousel publicitaire avec `Timer`
- La navigation deep-link depuis les push notifications

> **Résultat** : impossible à tester unitairement, difficile à relire, et contient des données fictives hardcodées.

---

### 🟠 `child_details_view.dart` — ~2 280 lignes
Widget inline utilisé directement dans `parent_home_page.dart`. Il gère les 7 onglets de la vue détaillée d'un enfant :

| Onglet | Contenu |
|--------|---------|
| Aperçu | Présence du jour, emploi du temps, résumé devoirs, actualités |
| Actualités | Liste complète depuis l'API dashboard |
| Devoirs | ExpansionTile par devoir (maison / classe / exercice) |
| Professeurs | Liste avec boutons RDV et Chat |
| Notes | Relevé de notes, lien RDV si note faible |
| Infos | Incidents, finances, messages administration |
| Statistiques | Moyenne, comparaison trimestrielle, points d'attention |

Fait aussi : `_fetchDashboard()`, `_fetchIncidents()`, `_markIncidentAsRead()`, gestion du highlight d'incident/devoir depuis une notification.

---

### 🟡 `chat_page.dart` — ~500 lignes
Messagerie parent ↔ enseignant. Gère : chargement des messages, envoi, acceptation/refus de conversation, appels audio/vidéo, signalement. Devrait être dans `features/messaging/` car partagé avec le rôle enseignant.

---

## Fichiers avec données fake hardcodées

### 🔴 `parent_home_page.dart` — méthode `_onChildSelected()`

Dans la méthode `_onChildSelected()`, les cases `0`, `1`, `2` définissent des enfants fictifs qui ne viennent pas de l'API :

```dart
// ❌ DONNÉES FAKE — à supprimer
case 0:
  _selectedChild = {
    'name': 'Yannick Nguema',
    'grade': 'Tle C',
    'school': 'Notre Dame de Quaben',
    'status': 'Présent',
    'arrivalTime': '07:45',
    'feesOwed': '125 000 FCFA',
    'homeworks': [ /* devoirs hardcodés */ ],
    'notifications': [ /* notifs hardcodées */ ],
    'incidents': [ /* incidents hardcodés */ ],
    ...
  };
case 1:
  _selectedChild = {
    'name': 'Emmanuella Nguema',
    'school': 'Sainte Thérèse',
    ...
  };
// case 1 est dupliqué (!), Junior Nguema est aussi en case 1
```

Ces données coexistent avec le chemin réel (`fromApi == true`) qui lui est correct.

---

### 🔴 `textbook_page.dart` — `_coursesData` hardcodé

Toutes les données du cahier de textes sont statiques :

```dart
// ❌ DONNÉES FAKE — à remplacer par un appel API
final Map<String, List<Map<String, dynamic>>> _coursesData = {
  'Yannick Nguema': [
    { 'subject': 'Mathématiques', 'time': '08:00 - 09:30', ... },
    { 'subject': 'Français', ... },
    { 'subject': 'Histoire-Géographie', ... },
  ],
  'Emmanuella Nguema': [ ... ],
  'Junior Nguema': [ ... ],
};
```

La sélection de l'enfant se fait aussi sur un `DropdownButton` local non connecté à l'API.

---

### 🟠 `calendar_page.dart` — grille calendrier statique

La grille de présences est une simulation fixe (Mars 2026, jours et points d'absence hardcodés) :

```dart
// ❌ SIMULATION — à connecter à l'API
_buildWeekRow(['1','2','3','4','5','6','7'], selectedDay: '5', dots: {'3': Colors.orange})
_buildWeekRow(['22','23','24','25','26','27','28'], dots: {'24': Colors.redAccent})
```

Les stats affichées (92% Assiduité, 3 Absences) sont aussi fixes.

---

## Flux de données réel (chemin API)

```
AuthService.getParentId()
        ↓
ParentService.getChildren(parentId)
        ↓  GET /parents/{id}/enfants
        ↓
_mapApiChild()  ← normalise chaque enfant API → Map locale
        ↓
_childrenData[]
        ↓
_onChildSelected(index)  ← si fromApi == true → chemin réel
        ↓
_selectedChild (Map)
        ↓
ChildDetailsView(child: _selectedChild)
    ├── _fetchDashboard()  → GET /eleves/{rawId}/dashboard
    │                        GET /admin/informations/{rawId}
    └── _fetchIncidents()  → GET /eleves/{rawId}/incidents
```

### Navigation depuis push notification
```
FCM payload reçu
        ↓
ParentHomePage(arguments: {
  selectChildName, childInitialTab,
  highlightIncidentId, highlightHomeworkId,
  openConversationId, openAppointments,
  openNotifications
})
        ↓
_pendingSelectChildName → _selectChildByName()
_pendingHighlightIncidentId → transmis à ChildDetailsView
_pendingHighlightHomeworkId → transmis à ChildDetailsView
openConversationId → navigue vers ChatPage
openAppointments   → navigue vers AppointmentsListPage
```

---

## Problèmes identifiés

### 🔴 Critiques

| # | Problème | Fichier | Impact |
|---|----------|---------|--------|
| 1 | God File 4 165 lignes — tout est dans un seul fichier | `parent_home_page.dart` | Impossible à tester, refactoring très coûteux |
| 2 | Données fake hardcodées mélangées avec l'API | `parent_home_page.dart` `_onChildSelected()` | Comportement imprévisible, confusion dev/prod |
| 3 | `case 1` dupliqué dans `_onChildSelected()` | `parent_home_page.dart` | Emmanuella et Junior ont le même case — Junior n'est jamais atteint |
| 4 | Cahier de textes 100% statique | `textbook_page.dart` | N'affiche jamais les vrais cours |

### 🟠 Importants

| # | Problème | Fichier | Impact |
|---|----------|---------|--------|
| 5 | 4 composants stubs jamais implémentés | `components/*.dart` | Architecture trompeuse, fichiers inutiles |
| 6 | `child_details_page.dart` obsolète (3 onglets) | `pages/` | Double implémentation avec `child_details_view.dart` (7 onglets) |
| 7 | 3 pages stubs (`child_dashboard`, `children_list`, `parent_home`) | `pages/` | Jamais utilisées, jamais implémentées |
| 8 | `print()` de debug en production (15+ occurrences) | `child_details_view.dart` | Fuite d'infos sensibles (finances, incidents) |
| 9 | Cast fragile `String`/`int` sur solde financier | `child_details_view.dart` `_buildInfosTab()` | Crash potentiel au parsing |
| 10 | `chat_page.dart` dans le module parent | `pages/chat_page.dart` | Partagé avec enseignant, devrait être dans `features/messaging/` |

### 🟡 Mineurs

| # | Problème | Fichier |
|---|----------|---------|
| 11 | `withOpacity` déprécié Flutter 3.x (partout) | Tous les fichiers |
| 12 | `parent_slice.dart` vide (`class ParentSlice {}`) | `parent_slice.dart` |
| 13 | Calendrier présences simulé (statique) | `calendar_page.dart` |
| 14 | `signature_modal.dart` jamais implémenté ni utilisé | `components/` |

---

## Ce qui fonctionne bien

- ✅ Deep-link depuis notifications push bien conçu (arguments → navigation ciblée)
- ✅ `_mapApiChild()` normalise correctement les données API
- ✅ `RefreshIndicator` présent sur les zones principales
- ✅ Badges de compteurs non lus (messages, RDV) mis à jour en temps réel
- ✅ `highlightIncidentId` / `highlightHomeworkId` pour navigation ciblée depuis notif
- ✅ `ParentService` bien séparé et utilise `ApiClient.instance`
- ✅ Gestion état `fromApi` explicite dans `_mapApiChild()`

---

## Recommandations de refactoring (par priorité)

### 1 — Supprimer les données fake
```dart
// parent_home_page.dart → _onChildSelected()
// Supprimer les cases 0, 1, 2 avec données Yannick/Emmanuella/Junior
// Ne garder que le chemin fromApi == true + le cas default

// textbook_page.dart
// Remplacer _coursesData par un appel API
// GET /eleves/{id}/cahier-de-textes?date=...
```

### 2 — Éclater parent_home_page.dart
```
parent_home_page.dart  →  _ParentDashboardTab.dart
                        →  _ParentMessagesTab.dart
                        →  _ParentEventsTab.dart
                        →  _ParentProfileTab.dart
                        →  parent_notification_modal.dart
                        →  parent_add_child_modal.dart
                        →  child_card.dart  (déplacer _ChildCard ici)
```

### 3 — Implémenter ou supprimer les stubs
```
Option A : implémenter
  child_card.dart         ← extraire _ChildCard de parent_home_page.dart
  attendance_status.dart  ← extraire la box présence de child_details_view.dart
  homework_preview.dart   ← extraire _buildHomeworkSummary()

Option B : supprimer les fichiers
  child_dashboard.dart, children_list.dart, parent_home.dart
  parent_slice.dart, signature_modal.dart
```

### 4 — Supprimer les print() de debug
```dart
// Remplacer dans child_details_view.dart
print('[DEBUG ...]')  →  if (kDebugMode) debugPrint('[DEBUG ...]')
```

### 5 — Connecter le calendrier à l'API
```dart
// calendar_page.dart
// GET /eleves/{id}/presences?mois=...
// Remplacer _buildCalendarGrid() statique par données dynamiques
```

---

*Analyse générée sur la base du code source lu en intégralité.*
