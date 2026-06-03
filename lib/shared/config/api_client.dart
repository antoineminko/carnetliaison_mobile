import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://sirh.alwaysdata.net/api_carnet_liaison/api', // Emulateur Android vers localhost
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  static void _installInterceptors() {
    _dio.interceptors.add(InterceptorsWrapper(
      onError: (DioException e, ErrorInterceptorHandler handler) async {
        final code = e.response?.statusCode ?? 0;
        if (code == 401) {
          // Clear any persisted session keys
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('parent_id');
          await prefs.remove('teacher_id');
          await prefs.remove('last_login_time');
        }
        handler.next(e);
      },
    ));
  }

  static Dio get instance => _dio;

  // Ensure interceptors are installed when this file is first loaded
  static void init() {
    _installInterceptors();
  }
  // Initialize on import
  static final _ = init();
}

