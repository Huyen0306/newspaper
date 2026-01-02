class ApiConfig {
  // Base URL - thay đổi theo môi trường của bạn
  static const String baseUrl = 'https://api.example.com';
  
  // API Endpoints
  static const String newsEndpoint = '/news';
  static const String savedEndpoint = '/saved';
  static const String rewardsEndpoint = '/rewards';
  static const String profileEndpoint = '/profile';
  
  // Timeout settings
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
}

