class ApiConfig {
  // Base URL
  static const String baseUrl = 'https://dummyjson.com';
  
  // API Endpoints
  static const String postsEndpoint = '/posts';
  static const String postByIdEndpoint = '/posts';
  static const String searchPostsEndpoint = '/posts/search';
  static const String postsTagsEndpoint = '/posts/tags';
  static const String postsTagListEndpoint = '/posts/tag-list';
  static const String postsByTagEndpoint = '/posts/tag';
  static const String postsByUserEndpoint = '/posts/user';
  static const String postCommentsEndpoint = '/posts';
  static const String addPostEndpoint = '/posts/add';
  
  // Timeout settings
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
}

