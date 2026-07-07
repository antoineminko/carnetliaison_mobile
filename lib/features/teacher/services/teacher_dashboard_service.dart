import 'package:dio/dio.dart';
import 'package:app_mobile/shared/config/api_client.dart';
import 'package:app_mobile/shared/config/api_endpoints.dart';

class TeacherDashboardService {
  TeacherDashboardService._();
  static final TeacherDashboardService instance = TeacherDashboardService._();

  Future<Response> getDashboard(int teacherId) async {
    return await ApiClient.instance.get(ApiEndpoints.teacherDashboard(teacherId));
  }
}
