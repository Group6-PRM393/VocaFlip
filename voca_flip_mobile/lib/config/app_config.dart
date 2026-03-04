class AppConfig {
  AppConfig._();

  static const bool isProduction = false; 

  static String get baseUrl => isProduction
      ? 'https://vocaflip-api.onrender.com'
      : 'http://localhost:8080';

  static const int connectTimeout = 120000; 
  static const int receiveTimeout = 60000; 

  static const String tokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
}
