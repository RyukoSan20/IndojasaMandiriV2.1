import 'package:dio/dio.dart';
import 'package:fintrack/config/api_config.dart';
import 'package:fintrack/config/env_config.dart';
import 'package:fintrack/utils/storage_helper.dart';
import 'package:fintrack/utils/error_handler.dart';

class ApiService {
  static ApiService? _instance;
  late final Dio _dio;
  bool _isRefreshing = false;

  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Client-Version': ApiConfig.apiVersion,
          'X-Platform': ApiConfig.platform,
        },
      ),
    );

    _setupInterceptors();
  }

  factory ApiService() {
    _instance ??= ApiService._internal();
    return _instance!;
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = StorageHelper.getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            final refreshed = await _handleTokenRefresh(error);
            if (refreshed) {
              return handler.resolve(refreshed);
            }
          }
          return handler.next(error);
        },
      ),
    );

    if (EnvConfig.isDevelopment) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (object) => print('[API] $object'),
      ));
    }
  }

  Future<Response?> _handleTokenRefresh(DioException error) async {
    if (_isRefreshing) return null;
    _isRefreshing = true;

    try {
      final refreshToken = StorageHelper.getRefreshToken();
      if (refreshToken == null) {
        await StorageHelper.clearAll();
        return null;
      }

      final response = await _dio.post(
        '${ApiConfig.endpoints.auth}/refresh',
        options: Options(headers: {'Authorization': 'Bearer $refreshToken'}),
      );

      final newAccessToken = response.data['access_token'];
      final newRefreshToken = response.data['refresh_token'];

      await StorageHelper.saveAccessToken(newAccessToken);
      await StorageHelper.saveRefreshToken(newRefreshToken);

      final opts = error.requestOptions;
      opts.headers['Authorization'] = 'Bearer $newAccessToken';

      return await _dio.fetch(opts);
    } catch (e) {
      await StorageHelper.clearAll();
      return null;
    } finally {
      _isRefreshing = false;
    }
  }

  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    String? fromJsonKey,
  }) async {
    try {
      final response = await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return ApiResponse.success(
        response.data,
        fromJsonKey: fromJsonKey,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    String? fromJsonKey,
  }) async {
    try {
      final response = await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return ApiResponse.success(
        response.data,
        fromJsonKey: fromJsonKey,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    String? fromJsonKey,
  }) async {
    try {
      final response = await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return ApiResponse.success(
        response.data,
        fromJsonKey: fromJsonKey,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<ApiResponse<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    String? fromJsonKey,
  }) async {
    try {
      final response = await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return ApiResponse.success(
        response.data,
        fromJsonKey: fromJsonKey,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    String? fromJsonKey,
  }) async {
    try {
      final response = await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return ApiResponse.success(
        response.data,
        fromJsonKey: fromJsonKey,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<ApiResponse<T>> uploadFile<T>(
    String path, {
    required String filePath,
    required String fileField,
    Map<String, dynamic>? additionalFields,
    Options? options,
    void Function(int, int)? onSendProgress,
  }) async {
    try {
      final formData = FormData.fromMap({
        fileField: await MultipartFile.fromFile(filePath),
        ...?additionalFields,
      });

      final response = await _dio.post<T>(
        path,
        data: formData,
        options: options ??
            Options(
              headers: {'Content-Type': 'multipart/form-data'},
            ),
        onSendProgress: onSendProgress,
      );
      return ApiResponse.success(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<ApiResponse<T>> downloadFile<T>(
    String path, {
    required String savePath,
    void Function(int, int)? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.download(
        path,
        savePath,
        queryParameters: queryParameters,
        onReceiveProgress: onReceiveProgress,
      );
      return ApiResponse.success(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  void setBaseUrl(String baseUrl) {
    _dio.options.baseUrl = baseUrl;
  }

  void addAuthHeader(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void removeAuthHeader() {
    _dio.options.headers.remove('Authorization');
  }
}

class ApiResponse<T> {
  final T? data;
  final bool success;
  final String? message;
  final int? statusCode;

  ApiResponse._({
    this.data,
    required this.success,
    this.message,
    this.statusCode,
  });

  factory ApiResponse.success(
    T? data, {
    String? fromJsonKey,
  }) {
    return ApiResponse._(
      data: data,
      success: true,
    );
  }

  factory ApiResponse.error({
    required String message,
    int? statusCode,
  }) {
    return ApiResponse._(
      success: false,
      message: message,
      statusCode: statusCode,
    );
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  ApiException._({
    required this.message,
    this.statusCode,
    this.originalError,
  });

  factory ApiException.fromDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return ApiException._(
          message: 'Connection timeout. Please check your internet connection.',
          statusCode: error.response?.statusCode,
          originalError: error,
        );
      case DioExceptionType.sendTimeout:
        return ApiException._(
          message: 'Send timeout. Please try again.',
          statusCode: error.response?.statusCode,
          originalError: error,
        );
      case DioExceptionType.receiveTimeout:
        return ApiException._(
          message: 'Receive timeout. Please try again.',
          statusCode: error.response?.statusCode,
          originalError: error,
        );
      case DioExceptionType.badResponse:
        return ApiException._(
          message: _parseErrorMessage(error.response),
          statusCode: error.response?.statusCode,
          originalError: error,
        );
      case DioExceptionType.cancel:
        return ApiException._(
          message: 'Request cancelled.',
          statusCode: error.response?.statusCode,
          originalError: error,
        );
      case DioExceptionType.connectionError:
        return ApiException._(
          message: 'No internet connection. Please check your network.',
          statusCode: error.response?.statusCode,
          originalError: error,
        );
      case DioExceptionType.badCertificate:
        return ApiException._(
          message: 'Security certificate error.',
          statusCode: error.response?.statusCode,
          originalError: error,
        );
      case DioExceptionType.unknown:
        return ApiException._(
          message: 'An unexpected error occurred.',
          statusCode: error.response?.statusCode,
          originalError: error,
        );
    }
  }

  static String _parseErrorMessage(Response? response) {
    if (response == null) return 'Unknown error occurred.';

    final data = response.data;
    if (data is Map<String, dynamic>) {
      if (data.containsKey('message')) {
        return data['message'];
      }
      if (data.containsKey('error')) {
        return data['error'];
      }
      if (data.containsKey('detail')) {
        return data['detail'];
      }
    }

    switch (response.statusCode) {
      case 400:
        return 'Bad request. Please check your input.';
      case 401:
        return 'Unauthorized. Please login again.';
      case 403:
        return 'Access forbidden.';
      case 404:
        return 'Resource not found.';
      case 409:
        return 'Conflict. Resource already exists.';
      case 422:
        return 'Validation error. Please check your input.';
      case 429:
        return 'Too many requests. Please try again later.';
      case 500:
        return 'Server error. Please try again later.';
      case 502:
        return 'Bad gateway. Please try again later.';
      case 503:
        return 'Service unavailable. Please try again later.';
      default:
        return 'An error occurred. Status: ${response.statusCode}';
    }
  }

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}
