import 'package:dio/dio.dart';
import 'api_config.dart';

class DioConfig {
  static Dio createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        sendTimeout: ApiConfig.sendTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    dio.interceptors.addAll([
      _LogInterceptor(),
      _ErrorInterceptor(),
    ]);

    return dio;
  }
}

// Log interceptor để debug requests/responses
class _LogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('REQUEST[${options.method}] => PATH: ${options.path}');
    print('Headers: ${options.headers}');
    if (options.data != null) {
      print('Data: ${options.data}');
    }
    if (options.queryParameters.isNotEmpty) {
      print('Query Parameters: ${options.queryParameters}');
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print(
      'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
    );
    print('Data: ${response.data}');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print(
      'ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}',
    );
    print('Error Message: ${err.message}');
    if (err.response != null) {
      print('Error Data: ${err.response?.data}');
    }
    super.onError(err, handler);
  }
}

// Error interceptor để xử lý lỗi chung
class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        // Handle timeout errors
        break;
      case DioExceptionType.badResponse:
        // Handle bad response errors
        if (err.response?.statusCode == 401) {
          // Handle unauthorized
        } else if (err.response?.statusCode == 404) {
          // Handle not found
        } else if (err.response?.statusCode == 500) {
          // Handle server error
        }
        break;
      case DioExceptionType.cancel:
        // Handle cancelled requests
        break;
      case DioExceptionType.unknown:
        // Handle unknown errors
        break;
      default:
        break;
    }
    super.onError(err, handler);
  }
}

