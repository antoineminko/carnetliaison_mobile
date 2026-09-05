import 'package:flutter/material.dart';
import 'package:app_mobile/features/auth/services/auth_service.dart';
import 'package:app_mobile/features/teacher/services/teacher_dashboard_service.dart';
import 'package:app_mobile/features/teacher/services/teacher_event_service.dart';
import 'package:app_mobile/features/teacher/services/teacher_message_service.dart';

class AccueilViewModel extends ChangeNotifier {
  int _currentIndex = 0;
  bool _isLoading = true;
  Map<String, dynamic>? _dashboardData;
  int? _teacherId;
  List<dynamic> _appointments = [];
  List<dynamic> _conversations = [];
  String _selectedEventFilter = 'En attente';
  bool _argsProcessed = false;
  final Set<int> _viewedAppointmentIds = {};

  // Getters
  int get currentIndex => _currentIndex;
  bool get isLoading => _isLoading;
  Map<String, dynamic>? get dashboardData => _dashboardData;
  int? get teacherId => _teacherId;
  List<dynamic> get appointments => _appointments;
  List<dynamic> get conversations => _conversations;
  String get selectedEventFilter => _selectedEventFilter;
  bool get argsProcessed => _argsProcessed;
  Set<int> get viewedAppointmentIds => _viewedAppointmentIds;

  // Setters
  void setIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void setSelectedEventFilter(String filter) {
    _selectedEventFilter = filter;
    notifyListeners();
  }

  void markArgsAsProcessed() {
    _argsProcessed = true;
    notifyListeners();
  }

  Future<void> loadDashboardData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final tid = await AuthService.getTeacherId();
      if (tid == null) {
        _isLoading = false;
        notifyListeners();
        return;
      }
      _teacherId = tid;

      final response = await TeacherDashboardService.instance.getDashboard(tid);
      if (response.data['success'] == true) {
        _dashboardData = response.data;
      }

      try {
        final eventsResponse = await TeacherEventService.instance.getEvents(tid);
        _appointments = eventsResponse.data['appointments'] ?? [];
        _conversations = eventsResponse.data['conversations'] ?? [];
      } catch (e) {
        debugPrint('Erreur lors du chargement des événements : $e');
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  void processNavigationArgs(Map<String, dynamic> args, BuildContext context) {
    if (_argsProcessed) return;

    if (args['openChat'] == true || args['initialTab'] == 1) {
      _currentIndex = 1;
      for (var c in _conversations) {
        if (c is Map) {
          c['unread_count'] = 0;
        }
      }
      notifyListeners();
    }

    if (args['openAppointments'] == true || args['initialTab'] == 2) {
      _currentIndex = 2; // Planning tab
      for (var appt in _appointments) {
        if (appt is Map && appt['statut'] == 'en_attente') {
          final id = int.tryParse(appt['id']?.toString() ?? '');
          if (id != null && !_viewedAppointmentIds.contains(id)) {
            _viewedAppointmentIds.add(id);
            TeacherEventService.instance.markEventAsRead(id);
          }
        }
      }
      notifyListeners();
    }

    _argsProcessed = true;
    notifyListeners();
  }

  Future<void> updateRequestStatus(
    int? id,
    String? type,
    String status, {
    String? newProposedDate,
    String? reportReason,
  }) async {
    if (id == null || type == null) return;

    try {
      if (type == 'appointment') {
        String finalStatus = status;
        if (status == 'rejected') finalStatus = 'refuse';
        if (status == 'accepted') finalStatus = 'accepte';
        if (status == 'reporte') finalStatus = 'reporte';

        await TeacherEventService.instance.updateAppointmentStatus(
          id,
          finalStatus,
          newProposedDate: newProposedDate,
          reportReason: reportReason,
        );
      } else if (type == 'conversation') {
        await TeacherMessageService.instance.updateConversationStatus(id, status);
      }
      await loadDashboardData();
    } catch (e) {
      debugPrint('Erreur lors de la mise à jour : $e');
      rethrow;
    }
  }
}
