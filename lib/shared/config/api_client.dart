import 'package:dio/dio.dart';

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

  static Dio get instance => _dio;
}

