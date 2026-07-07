import 'package:dio/dio.dart';
import 'package:app_mobile/shared/config/api_client.dart';

class TeacherEventService {
  TeacherEventService._();
  static final TeacherEventService instance = TeacherEventService._();

  Future<Response> getEvents(int teacherId) async {
    return await ApiClient.instance.get('/enseignants/$teacherId/events');
  }

  Future<Response> createAppointment(Map<String, dynamic> data) async {
    return await ApiClient.instance.post('/appointments', data: data);
  }

  Future<Response> updateAppointmentStatus(int appointmentId, String status) async {
    return await ApiClient.instance.put(
      '/appointments/$appointmentId/status',
      data: {'statut': status},
    );
  }
}
