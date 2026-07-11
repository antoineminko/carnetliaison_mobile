import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static const String defaultServerUrl = 'https://sirh.alwaysdata.net/api_carnet_liaison/api';

  static final Dio _dio = _createDioInstance();

  static Dio _createDioInstance() {
    final dio = Dio(BaseOptions(
      baseUrl: defaultServerUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        
        // Multi-tenant: Ajout du code d'établissement
        final schoolCode = prefs.getString('school_code');
        if (schoolCode != null && schoolCode.isNotEmpty) {
          options.headers['X-School-Code'] = schoolCode;
        }

        // Authentification standard (si on utilise Sanctum Token dans l'app)
        final token = prefs.getString('auth_token');
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        return handler.next(options);
      },
      onError: (DioException e, ErrorInterceptorHandler handler) async {
        final code = e.response?.statusCode ?? 0;
        if (code == 401) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('parent_id');
          await prefs.remove('teacher_id');
          await prefs.remove('auth_token');
          await prefs.remove('last_login_time');
          // On garde le school_code pour que l'utilisateur n'ait pas à le re-sélectionner
        }
        handler.next(e);
      },
    ));

    return dio;
  }

  static Dio get instance {
    return _dio;
  }

  static Dio getInstanceForSchool(String schoolCode) {
    final dio = _createDioInstance();
    dio.options.headers['X-School-Code'] = schoolCode;
    return dio;
  }
}
