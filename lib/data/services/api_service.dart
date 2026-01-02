import 'package:dio/dio.dart';
import '../../core/network/dio_config.dart';

class ApiService {
  late final Dio _dio;

  ApiService() {
    _dio = DioConfig.createDio();
  }

  // Get instance với custom Dio (nếu cần)
  ApiService.withDio(Dio dio) : _dio = dio;

  // GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PATCH request
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Error handler
  String _handleError(DioException error) {
    String errorMessage = 'Đã xảy ra lỗi không xác định';

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        errorMessage = 'Kết nối timeout. Vui lòng thử lại.';
        break;
      case DioExceptionType.badResponse:
        if (error.response != null) {
          switch (error.response?.statusCode) {
            case 400:
              errorMessage = 'Yêu cầu không hợp lệ';
              break;
            case 401:
              errorMessage = 'Không có quyền truy cập';
              break;
            case 403:
              errorMessage = 'Bị từ chối truy cập';
              break;
            case 404:
              errorMessage = 'Không tìm thấy dữ liệu';
              break;
            case 500:
              errorMessage = 'Lỗi máy chủ';
              break;
            default:
              errorMessage = 'Lỗi: ${error.response?.statusCode}';
          }
        }
        break;
      case DioExceptionType.cancel:
        errorMessage = 'Yêu cầu đã bị hủy';
        break;
      case DioExceptionType.unknown:
        errorMessage = 'Không có kết nối internet';
        break;
      default:
        errorMessage = 'Đã xảy ra lỗi không xác định';
    }

    return errorMessage;
  }

  // Set authorization token
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  // Remove authorization token
  void removeAuthToken() {
    _dio.options.headers.remove('Authorization');
  }
}
