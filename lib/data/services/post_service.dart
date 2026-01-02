import '../../core/network/api_config.dart';
import '../models/post_model.dart';
import 'api_service.dart';

class PostService {
  final ApiService _apiService;

  PostService({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  // Get all posts
  Future<PostsResponse> getPosts({
    int? limit,
    int? skip,
    String? select,
    String? sortBy,
    String? order,
  }) async {
    final queryParams = <String, dynamic>{};
    if (limit != null) queryParams['limit'] = limit;
    if (skip != null) queryParams['skip'] = skip;
    if (select != null) queryParams['select'] = select;
    if (sortBy != null) queryParams['sortBy'] = sortBy;
    if (order != null) queryParams['order'] = order;

    final response = await _apiService.get(
      ApiConfig.postsEndpoint,
      queryParameters: queryParams,
    );

    return PostsResponse.fromJson(response.data);
  }

  // Get single post
  Future<PostModel> getPostById(int id) async {
    final response = await _apiService.get('${ApiConfig.postByIdEndpoint}/$id');
    return PostModel.fromJson(response.data);
  }

  // Search posts
  Future<PostsResponse> searchPosts(String query) async {
    final response = await _apiService.get(
      ApiConfig.searchPostsEndpoint,
      queryParameters: {'q': query},
    );
    return PostsResponse.fromJson(response.data);
  }

  // Get posts by tag
  Future<PostsResponse> getPostsByTag(String tag) async {
    final response = await _apiService.get(
      '${ApiConfig.postsByTagEndpoint}/$tag',
    );
    return PostsResponse.fromJson(response.data);
  }

  // Get posts by user id
  Future<PostsResponse> getPostsByUserId(int userId) async {
    final response = await _apiService.get(
      '${ApiConfig.postsByUserEndpoint}/$userId',
    );
    return PostsResponse.fromJson(response.data);
  }
}
