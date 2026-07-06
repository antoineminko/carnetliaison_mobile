import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  // Dictionnaire des serveurs selon le préfixe
  static final Map<String, String> schoolServers = {
    'LYIMA': 'https://sirh.alwaysdata.net/api_carnet_liaison/api',
    'LYIMM': 'https://sirh.alwaysdata.net/api_carnet_liaison/api',
    'LYNDQ': 'https://sirh.alwaysdata.net/api_carnetliaison2/api',
  };

  // Serveur par défaut (Colbert) si on ne connaît pas le préfixe
  static const String defaultServerUrl = 'https://sirh.alwaysdata.net/api_carnet_liaison/api';

  // Cache des instances Dio pour ne pas les recréer à chaque fois
  static final Map<String, Dio> _dioInstances = {};

  // Fonction utilitaire pour créer une instance Dio configurée
  static Dio _createDioInstance(String baseUrl) {
    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onError: (DioException e, ErrorInterceptorHandler handler) async {
        final code = e.response?.statusCode ?? 0;
        if (code == 401) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('parent_id');
          await prefs.remove('teacher_id');
          await prefs.remove('last_login_time');
        }
        handler.next(e);
      },
    ));

    return dio;
  }

  // Ancienne méthode (pour ne pas casser le code existant qui utilise ApiClient.instance)
  // Renvoie le serveur par défaut
  static Dio get instance {
    return getInstanceForUrl(defaultServerUrl);
  }

  // Obtenir une instance Dio spécifique pour une URL
  static Dio getInstanceForUrl(String url) {
    if (!_dioInstances.containsKey(url)) {
      _dioInstances[url] = _createDioInstance(url);
    }
    return _dioInstances[url]!;
  }

  // Obtenir une instance Dio en fonction du code secret (ex: COLB-1234)
  static Dio getInstanceForCode(String codeSecret) {
    if (codeSecret.contains('-')) {
      final prefix = codeSecret.split('-')[0].toUpperCase();
      if (schoolServers.containsKey(prefix)) {
        return getInstanceForUrl(schoolServers[prefix]!);
      }
    }
    return instance; // Retourne le serveur par défaut si non trouvé
  }

  static void init() {
    // Les intercepteurs sont ajoutés dynamiquement dans _createDioInstance
  }
}

