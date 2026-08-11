class ApiConstants {
  // Use localhost / 10.0.2.2 depending on target environment
  static const String baseUrl = 'http://localhost:5000/api/v1';

  // Timeout limits
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // Endpoints
  static const String login = '/auth/login';
  static const String me = '/auth/me';
  static const String logout = '/auth/logout';
  static const String seed = '/seed';
}
