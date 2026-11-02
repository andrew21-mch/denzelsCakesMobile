import 'dart:io';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../constants/app_constants.dart';
import 'storage_service.dart';

/// Shown to the person using the app. [toString] is the sentence itself,
/// so a snackbar can display it without a Dio or Exception prefix.
class ApiException implements Exception {
  ApiException(this.message);
  final String message;

  @override
  String toString() => message;
}

class ApiService {
  /// The sentence a person should read. Prefers the server's specific
  /// validation text over "Validation failed" or a Dio stack trace.
  static String readableError(Object error) {
    if (error is DioException) {
      final fromBody = readableBody(error.response?.data);
      if (fromBody != null) return fromBody;
      final message = error.message?.trim();
      if (message != null && message.isNotEmpty) return _stripWrappers(message);
    }
    return _stripWrappers(error.toString());
  }

  static String? readableBody(dynamic data) {
    if (data is! Map) return null;
    final error = data['error'];
    final message = data['message']?.toString().trim();

    if (error is List && error.isNotEmpty) {
      final lines = error.map((item) {
        if (item is Map && item['msg'] != null) return item['msg'].toString();
        return item.toString();
      }).where((line) => line.trim().isNotEmpty);
      final text = lines.join('\n');
      if (text.isNotEmpty) return text;
    }

    if (error is String && error.trim().isNotEmpty && error.contains(' ')) {
      return error.trim();
    }

    if (message != null &&
        message.isNotEmpty &&
        message.toLowerCase() != 'validation failed') {
      return message;
    }

    return null;
  }

  static String _stripWrappers(String text) {
    var value = text.trim();
    const prefixes = [
      'Exception: ',
      'DioException [badResponse]: ',
      'DioException [bad response]: ',
    ];
    var changed = true;
    while (changed) {
      changed = false;
      for (final prefix in prefixes) {
        if (value.startsWith(prefix)) {
          value = value.substring(prefix.length).trim();
          changed = true;
        }
      }
    }
    return value;
  }

  static late Dio _dio;
  static final Logger _logger = Logger();
  static void Function()? onSessionExpired;

  static Future<void> init() async {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: AppConstants.requestTimeout,
      receiveTimeout: AppConstants.requestTimeout,
      sendTimeout: AppConstants.requestTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add interceptors
    _dio.interceptors.add(_AuthInterceptor());
    _dio.interceptors.add(_LoggingInterceptor());
    _dio.interceptors.add(_ErrorInterceptor());
  }

  // GET request
  static Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      _logger.e('GET request failed: $path', error: e);
      rethrow;
    }
  }

  // POST request
  static Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      _logger.e('POST request failed: $path', error: e);
      rethrow;
    }
  }

  // PUT request
  static Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      _logger.e('PUT request failed: $path', error: e);
      rethrow;
    }
  }

  // DELETE request
  static Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      _logger.e('DELETE request failed: $path', error: e);
      rethrow;
    }
  }

  // Upload file
  static Future<Response<T>> uploadFile<T>(
    String path,
    File file, {
    String fieldName = 'file',
    Map<String, dynamic>? data,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final formData = FormData();

      // Add file
      formData.files.add(MapEntry(
        fieldName,
        await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
      ));

      // Add additional data
      if (data != null) {
        data.forEach((key, value) {
          formData.fields.add(MapEntry(key, value.toString()));
        });
      }

      return await _dio.post<T>(
        path,
        data: formData,
        onSendProgress: onSendProgress,
      );
    } catch (e) {
      _logger.e('File upload failed: $path', error: e);
      rethrow;
    }
  }

  // Download file
  static Future<Response> downloadFile(
    String path,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.download(
        path,
        savePath,
        queryParameters: queryParameters,
        onReceiveProgress: onReceiveProgress,
      );
    } catch (e) {
      _logger.e('File download failed: $path', error: e);
      rethrow;
    }
  }

  // Get Dio instance for custom requests
  static Dio get dio => _dio;
}

// Authentication Interceptor
class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    // Add access token to requests
    final accessToken = await StorageService.getAccessToken();
    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle token refresh on 401 errors
    if (err.response?.statusCode == 401) {
      final refreshToken = await StorageService.getRefreshToken();
      if (refreshToken != null) {
        try {
          // Attempt to refresh token
          final response = await ApiService._dio.post(
            '/auth/refresh',
            data: {'refreshToken': refreshToken},
            options: Options(
              headers: {
                'Authorization': null
              }, // Remove auth header for refresh
            ),
          );

          if (response.statusCode == 200) {
            final data = response.data['data'];
            final newAccessToken = data['accessToken'];
            final newRefreshToken = data['refreshToken'];

            // Save new tokens
            await StorageService.setAccessToken(newAccessToken);
            await StorageService.setRefreshToken(newRefreshToken);

            // Retry original request with new token
            final requestOptions = err.requestOptions;
            requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

            final retryResponse = await ApiService._dio.fetch(requestOptions);
            handler.resolve(retryResponse);
            return;
          }
        } catch (e) {
          // Refresh failed, clear tokens and redirect to login
          await StorageService.clearTokens();
          await StorageService.clearUserData();
          ApiService.onSessionExpired?.call();
        }
      }
    }
    handler.next(err);
  }
}

// Logging Interceptor
class _LoggingInterceptor extends Interceptor {
  final Logger _logger = Logger();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logger.d('REQUEST[${options.method}] => PATH: ${options.path}');
    _logger.d('Headers: ${options.headers}');
    if (options.data != null) {
      _logger.d('Data: ${options.data}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logger.d(
        'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
    _logger.d('Data: ${response.data}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.e(
        'ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}');
    _logger.e('Message: ${err.message}');
    if (err.response?.data != null) {
      _logger.e('Error Data: ${err.response?.data}');
    }
    handler.next(err);
  }
}

// Error Interceptor
class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    String message;

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = 'Connection timeout. Please check your internet connection.';
        break;
      case DioExceptionType.badResponse:
        message =
            _handleHttpError(err.response?.statusCode, err.response?.data);
        break;
      case DioExceptionType.cancel:
        message = 'Request was cancelled.';
        break;
      case DioExceptionType.connectionError:
        message = 'Failed to connect to server. Please check your internet connection and try again.';
        break;
      case DioExceptionType.unknown:
        if (err.error is SocketException) {
          final socketError = err.error as SocketException;
          if (socketError.message.contains('Failed host lookup') || 
              socketError.message.contains('Name resolution failed')) {
            message = 'Cannot reach server. Please check your internet connection or contact support if the problem persists.';
          } else {
            message = 'No internet connection. Please check your network.';
          }
        } else if (err.message != null && 
                   (err.message!.contains('Failed host lookup') || 
                    err.message!.contains('Name resolution failed'))) {
          message = 'Cannot reach server. Please check your internet connection or contact support if the problem persists.';
        } else {
          message = 'An unexpected error occurred.';
        }
        break;
      default:
        message = 'An unexpected error occurred.';
    }

    // Create a custom exception with user-friendly message
    final customError = DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: message,
      message: message,
    );

    handler.next(customError);
  }

  String _handleHttpError(int? statusCode, dynamic responseData) {
    final detail = ApiService.readableBody(responseData);
    switch (statusCode) {
      case 400:
      case 422:
        return detail ?? 'Please check your input.';
      case 401:
        return detail ?? 'Authentication failed. Please log in again.';
      case 403:
        return 'Access denied. You don\'t have permission to perform this action.';
      case 404:
        return 'The requested resource was not found.';
      case 429:
        return 'Too many requests. Please try again later.';
      case 500:
        return detail ?? 'Server error. Please try again later.';
      case 502:
      case 503:
      case 504:
        return 'Service temporarily unavailable. Please try again later.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}
