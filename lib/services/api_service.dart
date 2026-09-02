import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

/// API Service configuration options
class ApiServiceConfig {
  final String baseUrl;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final Duration sendTimeout;
  final bool enableMockData;
  final bool enableLogging;

  const ApiServiceConfig({
    this.baseUrl = ApiConstants.baseUrl,
    this.connectTimeout = const Duration(seconds: 30),
    this.receiveTimeout = const Duration(seconds: 30),
    this.sendTimeout = const Duration(seconds: 30),
    this.enableMockData = true,
    this.enableLogging = true,
  });
}

/// HTTP Methods enum for type safety
enum HttpMethod {
  get('GET'),
  post('POST'),
  put('PUT'),
  patch('PATCH'),
  delete('DELETE');

  final String value;
  const HttpMethod(this.value);
}

/// API Response wrapper
class ApiResponse<T> {
  final bool success;
  final T? data;
  final ApiError? error;
  final ResponseMeta? meta;
  final bool isFromCache;

  const ApiResponse({
    required this.success,
    this.data,
    this.error,
    this.meta,
    this.isFromCache = false,
  });

  factory ApiResponse.success(T data, {ResponseMeta? meta, bool isFromCache = false}) {
    return ApiResponse(
      success: true,
      data: data,
      meta: meta,
      isFromCache: isFromCache,
    );
  }

  factory ApiResponse.failure(ApiError error) {
    return ApiResponse(
      success: false,
      error: error,
    );
  }
}

/// Response metadata for pagination
class ResponseMeta {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  const ResponseMeta({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory ResponseMeta.fromJson(Map<String, dynamic> json) {
    return ResponseMeta(
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 20,
      total: json['total'] ?? 0,
      totalPages: json['totalPages'] ?? 1,
    );
  }

  bool get hasNextPage => page < totalPages;
  bool get hasPreviousPage => page > 1;
}

/// API Error model
class ApiError {
  final String code;
  final String message;
  final List<FieldError>? details;
  final String? requestId;

  const ApiError({
    required this.code,
    required this.message,
    this.details,
    this.requestId,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) {
    List<FieldError>? fieldErrors;
    if (json['details'] != null) {
      fieldErrors = (json['details'] as List)
          .map((e) => FieldError.fromJson(e))
          .toList();
    }

    return ApiError(
      code: json['code'] ?? 'UNKNOWN_ERROR',
      message: json['message'] ?? 'An unknown error occurred',
      details: fieldErrors,
      requestId: json['request_id'],
    );
  }

  factory ApiError.fromDioException(DioException e) {
    String code;
    String message;

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        code = 'CONNECTION_TIMEOUT';
        message = 'Connection timeout. Please check your internet connection.';
        break;
      case DioExceptionType.sendTimeout:
        code = 'SEND_TIMEOUT';
        message = 'Request timeout. Please try again.';
        break;
      case DioExceptionType.receiveTimeout:
        code = 'RECEIVE_TIMEOUT';
        message = 'Server response timeout. Please try again.';
        break;
      case DioExceptionType.badCertificate:
        code = 'BAD_CERTIFICATE';
        message = 'Security certificate error. Please update the app.';
        break;
      case DioExceptionType.badResponse:
        code = _getStatusCodeError(e.response?.statusCode);
        message = _getStatusCodeMessage(e.response?.statusCode);
        break;
      case DioExceptionType.cancel:
        code = 'REQUEST_CANCELLED';
        message = 'Request was cancelled.';
        break;
      case DioExceptionType.connectionError:
        code = 'CONNECTION_ERROR';
        message = 'Unable to connect. Please check your internet connection.';
        break;
      case DioExceptionType.unknown:
      default:
        code = 'UNKNOWN_ERROR';
        message = 'An unexpected error occurred. Please try again.';
    }

    return ApiError(code: code, message: message);
  }

  static String _getStatusCodeError(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'BAD_REQUEST';
      case 401:
        return 'UNAUTHORIZED';
      case 403:
        return 'FORBIDDEN';
      case 404:
        return 'NOT_FOUND';
      case 409:
        return 'CONFLICT';
      case 422:
        return 'VALIDATION_ERROR';
      case 429:
        return 'RATE_LIMITED';
      case 500:
        return 'INTERNAL_ERROR';
      case 502:
        return 'BAD_GATEWAY';
      case 503:
        return 'SERVICE_UNAVAILABLE';
      default:
        return 'SERVER_ERROR';
    }
  }

  static String _getStatusCodeMessage(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Invalid request data.';
      case 401:
        return 'Session expired. Please login again.';
      case 403:
        return 'You do not have permission to access this resource.';
      case 404:
        return 'Resource not found.';
      case 409:
        return 'Resource already exists or conflict occurred.';
      case 422:
        return 'Validation failed. Please check your input.';
      case 429:
        return 'Too many requests. Please wait and try again.';
      case 500:
        return 'Server error. Please try again later.';
      case 502:
        return 'Server temporarily unavailable. Please try again.';
      case 503:
        return 'Service unavailable. Please try again later.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}

/// Field-specific error
class FieldError {
  final String field;
  final String message;
  final dynamic value;

  const FieldError({
    required this.field,
    required this.message,
    this.value,
  });

  factory FieldError.fromJson(Map<String, dynamic> json) {
    return FieldError(
      field: json['field'] ?? '',
      message: json['message'] ?? '',
      value: json['value'],
    );
  }
}

/// Request options wrapper
class RequestOptions {
  final Map<String, dynamic>? queryParameters;
  final Map<String, dynamic>? headers;
  final dynamic data;
  final String? contentType;
  final bool requiresAuth;
  final bool useCache;
  final Duration? cacheDuration;

  const RequestOptions({
    this.queryParameters,
    this.headers,
    this.data,
    this.contentType,
    this.requiresAuth = true,
    this.useCache = false,
    this.cacheDuration,
  });

  RequestOptions copyWith({
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    dynamic data,
    String? contentType,
    bool? requiresAuth,
    bool? useCache,
    Duration? cacheDuration,
  }) {
    return RequestOptions(
      queryParameters: queryParameters ?? this.queryParameters,
      headers: headers ?? this.headers,
      data: data ?? this.data,
      contentType: contentType ?? this.contentType,
      requiresAuth: requiresAuth ?? this.requiresAuth,
      useCache: useCache ?? this.useCache,
      cacheDuration: cacheDuration ?? this.cacheDuration,
    );
  }
}

/// Main API Service class
class ApiService {
  late final Dio _dio;
  final ApiServiceConfig _config;
  final NetworkInfo _networkInfo;
  final StorageService _storageService;
  final MockDataService _mockDataService;

  static final ApiService _instance = ApiService._internal();
  factory ApiService({ApiServiceConfig? config}) {
    if (config != null) {
      _instance._configure(config);
    }
    return _instance;
  }

  factory ApiService.instance() => _instance;

  ApiService._internal()
      : _config = const ApiServiceConfig(),
        _networkInfo = GetIt.I<NetworkInfo>(),
        _storageService = GetIt.I<StorageService>(),
        _mockDataService = MockDataService() {
    _dio = _createDio();
  }

  static void _configure(ApiServiceConfig config) {
    _instance._config = config;
    _instance._dio = _instance._createDio();
  }

  Dio _createDio() {
    final dio = Dio(BaseOptions(
      baseUrl: _config.baseUrl,
      connectTimeout: _config.connectTimeout,
      receiveTimeout: _config.receiveTimeout,
      sendTimeout: _config.sendTimeout,
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.acceptHeader: 'application/json',
        'X-App-Version': AppConstants.appVersion,
        'X-Client-Type': kIsWeb ? 'web' : Platform.operatingSystem,
      },
    ));

    dio.interceptors.addAll([
      _AuthInterceptor(_storageService),
      _LoggingInterceptor(),
      _RetryInterceptor(dio),
      if (_config.enableLogging) _DebugInterceptor(),
    ]);

    return dio;
  }

  /// GET request
  Future<ApiResponse<T>> get<T>(
    String path, {
    RequestOptions options = const RequestOptions(),
    T Function(dynamic)? parser,
  }) async {
    return _request<T>(
      path,
      method: HttpMethod.get,
      options: options,
      parser: parser,
    );
  }

  /// POST request
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    RequestOptions options = const RequestOptions(),
    T Function(dynamic)? parser,
  }) async {
    return _request<T>(
      path,
      method: HttpMethod.post,
      data: data,
      options: options,
      parser: parser,
    );
  }

  /// PUT request
  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    RequestOptions options = const RequestOptions(),
    T Function(dynamic)? parser,
  }) async {
    return _request<T>(
      path,
      method: HttpMethod.put,
      data: data,
      options: options,
      parser: parser,
    );
  }

  /// PATCH request
  Future<ApiResponse<T>> patch<T>(
    String path, {
    dynamic data,
    RequestOptions options = const RequestOptions(),
    T Function(dynamic)? parser,
  }) async {
    return _request<T>(
      path,
      method: HttpMethod.patch,
      data: data,
      options: options,
      parser: parser,
    );
  }

  /// DELETE request
  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic data,
    RequestOptions options = const RequestOptions(),
    T Function(dynamic)? parser,
  }) async {
    return _request<T>(
      path,
      method: HttpMethod.delete,
      data: data,
      options: options,
      parser: parser,
    );
  }

  /// Upload file
  Future<ApiResponse<T>> uploadFile<T>(
    String path, {
    required String filePath,
    required String fileField,
    Map<String, dynamic>? additionalFields,
    RequestOptions options = const RequestOptions(),
    void Function(int, int)? onSendProgress,
    T Function(dynamic)? parser,
  }) async {
    final formData = FormData.fromMap({
      ...?additionalFields,
      fileField: await MultipartFile.fromFile(filePath),
    });

    final uploadOptions = options.copyWith(
      headers: {
        ...?options.headers,
        HttpHeaders.contentTypeHeader: 'multipart/form-data',
      },
    );

    return _request<T>(
      path,
      method: HttpMethod.post,
      data: formData,
      options: uploadOptions,
      parser: parser,
      onSendProgress: onSendProgress,
    );
  }

  /// Download file
  Future<String> downloadFile(
    String path,
    String savePath, {
    RequestOptions options = const RequestOptions(),
    void Function(int, int)? onReceiveProgress,
  }) async {
    final response = await _dio.download(
      path,
      savePath,
      queryParameters: options.queryParameters,
      options: Options(
        headers: options.headers,
      ),
      onReceiveProgress: onReceiveProgress,
    );

    if (response.statusCode == 200) {
      return savePath;
    }
    throw ApiException('Failed to download file');
  }

  Future<ApiResponse<T>> _request<T>(
    String path, {
    required HttpMethod method,
    dynamic data,
    RequestOptions options = const RequestOptions(),
    T Function(dynamic)? parser,
    void Function(int, int)? onSendProgress,
  }) async {
    // Check network connectivity
    final isConnected = await _networkInfo.isConnected;

    // Try mock data if offline and enabled
    if (!isConnected && _config.enableMockData && options.useCache) {
      return _handleMockData<T>(path, method, parser);
    }

    // If offline and mock not available, return offline error
    if (!isConnected) {
      return ApiResponse.failure(const ApiError(
        code: 'OFFLINE',
        message: 'No internet connection. Please check your network.',
      ));
    }

    try {
      final response = await _dio.request<T>(
        path,
        data: data,
        queryParameters: options.queryParameters,
        options: Options(
          method: method.value,
          headers: options.headers,
          contentType: options.contentType,
        ),
        onSendProgress: onSendProgress,
      );

      return _handleResponse<T>(response, parser);
    } on DioException catch (e) {
      return _handleDioError<T>(e, path, method, options, parser);
    } catch (e) {
      return ApiResponse.failure(ApiError(
        code: 'UNKNOWN_ERROR',
        message: e.toString(),
      ));
    }
  }

  ApiResponse<T> _handleResponse<T>(
    Response response,
    T Function(dynamic)? parser,
  ) {
    final body = response.data;

    // Handle standard API response format
    if (body is Map<String, dynamic>) {
      final success = body['success'] == true;

      if (success && body['data'] != null) {
        final meta = body['meta'] != null
            ? ResponseMeta.fromJson(body['meta'])
            : null;

        final parsedData = parser != null
            ? parser(body['data'])
            : body['data'] as T;

        return ApiResponse.success(parsedData, meta: meta);
      } else if (!success && body['error'] != null) {
        return ApiResponse.failure(
          ApiError.fromJson(body['error'] as Map<String, dynamic>),
        );
      }
    }

    // Direct data response
    final parsedData = parser != null ? parser(body) : body as T;
    return ApiResponse.success(parsedData);
  }

  ApiResponse<T> _handleDioError<T>(
    DioException e,
    String path,
    HttpMethod method,
    RequestOptions options,
    T Function(dynamic)? parser,
  ) {
    // Handle 401 - token expired
    if (e.response?.statusCode == 401) {
      _handleUnauthorized();
    }

    // Try mock data fallback for read operations
    if (e.response?.statusCode != null &&
        e.response!.statusCode! >= 500 &&
        _config.enableMockData &&
        method == HttpMethod.get) {
      return _handleMockData<T>(path, method, parser);
    }

    // Parse error response
    if (e.response?.data is Map<String, dynamic>) {
      final errorData = e.response!.data['error'];
      if (errorData != null) {
        return ApiResponse.failure(ApiError.fromJson(errorData));
      }
    }

    return ApiResponse.failure(ApiError.fromDioException(e));
  }

  Future<ApiResponse<T>> _handleMockData<T>(
    String path,
    HttpMethod method,
    T Function(dynamic)? parser,
  ) async {
    try {
      final mockData = _mockDataService.getMockData(path, method.value);

      if (mockData != null) {
        final parsedData = parser != null ? parser(mockData) : mockData as T;
        return ApiResponse.success(parsedData, isFromCache: true);
      }
    } catch (e) {
      // Fall through to error response
    }

    return ApiResponse.failure(const ApiError(
      code: 'NO_DATA',
      message: 'No cached data available. Please connect to the internet.',
    ));
  }

  void _handleUnauthorized() {
    // Trigger logout or token refresh
    _storageService.remove(ApiConstants.accessTokenKey);
    _storageService.remove(ApiConstants.refreshTokenKey);
  }

  /// Set authentication token
  void setAuthToken(String token) {
    _storageService.write(ApiConstants.accessTokenKey, token);
  }

  /// Set refresh token
  void setRefreshToken(String token) {
    _storageService.write(ApiConstants.refreshTokenKey, token);
  }

  /// Clear authentication tokens
  void clearAuth() {
    _storageService.remove(ApiConstants.accessTokenKey);
    _storageService.remove(ApiConstants.refreshTokenKey);
  }

  /// Get current access token
  Future<String?> getAccessToken() async {
    return _storageService.read(ApiConstants.accessTokenKey);
  }

  /// Get current refresh token
  Future<String?> getRefreshToken() async {
    return _storageService.read(ApiConstants.refreshTokenKey);
  }

  /// Cancel all pending requests
  void cancelAllRequests() {
    _dio.close(force: true);
    _dio = _createDio();
  }
}

/// Auth interceptor for adding tokens
class _AuthInterceptor extends Interceptor {
  final StorageService _storageService;

  _AuthInterceptor(this._storageService);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Skip auth for public endpoints
    if (_isPublicEndpoint(options.path)) {
      return handler.next(options);
    }

    final token = await _storageService.read(ApiConstants.accessTokenKey);

    if (token != null) {
      options.headers[HttpHeaders.authorizationHeader] = 'Bearer $token';
    }

    // Add timezone header
    options.headers['X-Timezone'] = DateTime.now().timeZoneName;

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Try to refresh token
      final refreshed = await _refreshToken();
      if (refreshed) {
        // Retry original request
        final retryResponse = await _retryRequest(err.requestOptions);
        return handler.resolve(retryResponse);
      }
    }
    handler.next(err);
  }

  bool _isPublicEndpoint(String path) {
    final publicEndpoints = [
      '/auth/login',
      '/auth/register',
      '/auth/forgot-password',
      '/auth/reset-password',
      '/auth/verify-email',
      '/auth/google',
      '/utilities/exchange-rates',
    ];

    return publicEndpoints.any((endpoint) => path.contains(endpoint));
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _storageService.read(ApiConstants.refreshTokenKey);
      if (refreshToken == null) return false;

      final dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
      final response = await dio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data['tokens'] != null) {
          await _storageService.write(
            ApiConstants.accessTokenKey,
            data['tokens']['accessToken'],
          );
          await _storageService.write(
            ApiConstants.refreshTokenKey,
            data['tokens']['refreshToken'],
          );
          return true;
        }
      }
    } catch (_) {}
    return false;
  }

  Future<Response> _retryRequest(RequestOptions options) async {
    final token = await _storageService.read(ApiConstants.accessTokenKey);
    options.headers[HttpHeaders.authorizationHeader] = 'Bearer $token';

    final dio = Dio();
    return dio.fetch(options);
  }
}

/// Logging interceptor
class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('┌──────────────────────────────────────────────────────────────');
    debugPrint('│ REQUEST: ${options.method} ${options.uri}');
    debugPrint('│ Headers: ${options.headers}');
    if (options.data != null) {
      debugPrint('│ Body: ${jsonEncode(options.data)}');
    }
    debugPrint('└──────────────────────────────────────────────────────────────');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint('┌──────────────────────────────────────────────────────────────');
    debugPrint('│ RESPONSE: ${response.statusCode} ${response.requestOptions.uri}');
    debugPrint('│ Data: ${jsonEncode(response.data)}');
    debugPrint('└──────────────────────────────────────────────────────────────');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint('┌──────────────────────────────────────────────────────────────');
    debugPrint('│ ERROR: ${err.type} ${err.requestOptions.uri}');
    debugPrint('│ Message: ${err.message}');
    if (err.response != null) {
      debugPrint('│ Response: ${err.response?.data}');
    }
    debugPrint('└──────────────────────────────────────────────────────────────');
    handler.next(err);
  }
}

/// Debug interceptor for development
class _DebugInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      _logRequest(options);
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      _logResponse(response);
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      _logError(err);
    }
    handler.next(err);
  }

  void _logRequest(RequestOptions options) {
    final separator = '═' * 60;
    debugPrint('''
$separator
📤 REQUEST
$separator
${options.method} ${options.uri}
${options.headers.entries.map((e) => '${e.key}: ${e.value}').join('\n')}
${options.data != null ? '\nBody: ${jsonEncode(options.data)}' : ''}
$separator
''');
  }

  void _logResponse(Response response) {
    final separator = '═' * 60;
    debugPrint('''
$separator
📥 RESPONSE
$separator
${response.statusCode} ${response.requestOptions.uri}
Time: ${response.responseDateTime}
${response.data != null ? '\nBody: ${jsonEncode(response.data)}' : ''}
$separator
''');
  }

  void _logError(DioException err) {
    final separator = '═' * 60;
    debugPrint('''
$separator
❌ ERROR
$separator
Type: ${err.type}
URL: ${err.requestOptions.uri}
Message: ${err.message}
${err.response != null ? 'Status: ${err.response?.statusCode}\nData: ${err.response?.data}' : ''}
$separator
''');
  }
}

/// Retry interceptor for failed requests
class _RetryInterceptor extends Interceptor {
  final Dio _dio;
  final int _maxRetries;
  final Duration _retryDelay;

  _RetryInterceptor(
    this._dio, {
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 1),
  })  : _maxRetries = maxRetries,
        _retryDelay = retryDelay;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final requestOptions = err.requestOptions;
    final retryCount = requestOptions.extra['retryCount'] ?? 0;

    // Only retry on connection errors or 5xx server errors
    final shouldRetry = _shouldRetry(err) && retryCount < _maxRetries;

    if (shouldRetry) {
      requestOptions.extra['retryCount'] = retryCount + 1;

      // Exponential backoff
      final delay = _retryDelay * (retryCount + 1);
      await Future.delayed(delay);

      try {
        final response = await _dio.fetch(requestOptions);
        return handler.resolve(response);
      } catch (e) {
        if (e is DioException) {
          return handler.next(e);
        }
      }
    }

    handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.connectionError ||
        (err.response?.statusCode ?? 0) >= 500;
  }
}

/// Extension for API Exception handling
extension ApiErrorExtension on ApiError {
  bool get isNetworkError =>
      code == 'CONNECTION_ERROR' ||
      code == 'CONNECTION_TIMEOUT' ||
      code == 'OFFLINE';

  bool get isAuthError =>
      code == 'UNAUTHORIZED' ||
      code == 'TOKEN_EXPIRED' ||
      code == 'INVALID_CREDENTIALS';

  bool get isValidationError =>
      code == 'VALIDATION_ERROR' || code == 'BAD_REQUEST';

  bool get isServerError =>
      code == 'INTERNAL_ERROR' ||
      code == 'SERVER_ERROR' ||
      code == 'SERVICE_UNAVAILABLE';
}

/// API Exception wrapper
class ApiException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const ApiException(this.message, {this.code, this.originalError});

  factory ApiException.fromApiError(ApiError error) {
    return ApiException(
      error.message,
      code: error.code,
    );
  }

  @override
  String toString() => 'ApiException: $message (code: $code)';
}
