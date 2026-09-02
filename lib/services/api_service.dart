import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/// API Configuration
class ApiConfig {
  static const String baseUrl = 'https://api.fintrack.app/v1';
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 1);
}

/// API Error Types
enum ApiErrorType {
  networkError,
  timeoutError,
  serverError,
  unauthorized,
  forbidden,
  notFound,
  validationError,
  conflictError,
  unknownError,
}

/// Custom API Exception
class ApiException implements Exception {
  final String message;
  final ApiErrorType type;
  final int? statusCode;
  final dynamic data;
  final String? requestId;

  ApiException({
    required this.message,
    required this.type,
    this.statusCode,
    this.data,
    this.requestId,
  });

  factory ApiException.fromStatusCode(int statusCode, [dynamic data]) {
    switch (statusCode) {
      case 400:
        return ApiException(
          message: 'Bad request',
          type: ApiErrorType.validationError,
          statusCode: statusCode,
          data: data,
        );
      case 401:
        return ApiException(
          message: 'Unauthorized - Please login again',
          type: ApiErrorType.unauthorized,
          statusCode: statusCode,
          data: data,
        );
      case 403:
        return ApiException(
          message: 'Access forbidden',
          type: ApiErrorType.forbidden,
          statusCode: statusCode,
          data: data,
        );
      case 404:
        return ApiException(
          message: 'Resource not found',
          type: ApiErrorType.notFound,
          statusCode: statusCode,
          data: data,
        );
      case 409:
        return ApiException(
          message: 'Resource conflict',
          type: ApiErrorType.conflictError,
          statusCode: statusCode,
          data: data,
        );
      case 500:
      case 502:
      case 503:
        return ApiException(
          message: 'Server error - Please try again later',
          type: ApiErrorType.serverError,
          statusCode: statusCode,
          data: data,
        );
      default:
        return ApiException(
          message: 'An unexpected error occurred',
          type: ApiErrorType.unknownError,
          statusCode: statusCode,
          data: data,
        );
    }
  }

  factory ApiException.network([String? message]) => ApiException(
        message: message ?? 'Network error - Please check your connection',
        type: ApiErrorType.networkError,
      );

  factory ApiException.timeout([String? message]) => ApiException(
        message: message ?? 'Request timed out - Please try again',
        type: ApiErrorType.timeoutError,
      );

  @override
  String toString() => 'ApiException: $message (Type: $type, Code: $statusCode)';
}

/// API Response wrapper
class ApiResponse<T> {
  final bool success;
  final T? data;
  final dynamic error;
  final ApiMeta? meta;
  final String? requestId;

  ApiResponse({
    required this.success,
    this.data,
    this.error,
    this.meta,
    this.requestId,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse(
      success: json['success'] ?? false,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'],
      error: json['error'],
      meta: json['meta'] != null ? ApiMeta.fromJson(json['meta']) : null,
      requestId: json['request_id'],
    );
  }

  R when<R>({
    required R Function(T data) success,
    required R Function(dynamic error) failure,
  }) {
    if (success) {
      return success(data as T);
    }
    return failure(error);
  }
}

/// API Metadata for pagination
class ApiMeta {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  ApiMeta({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory ApiMeta.fromJson(Map<String, dynamic> json) {
    return ApiMeta(
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 20,
      total: json['total'] ?? 0,
      totalPages: json['totalPages'] ?? 1,
    );
  }

  bool get hasMore => page < totalPages;
}

/// Request interceptor type
typedef RequestInterceptor = Future<Map<String, String>> Function(
    Map<String, String> headers);

/// Response interceptor type
typedef ResponseInterceptor = dynamic Function(dynamic data);

/// Mock data provider type
typedef MockDataProvider<T> = T Function();

/// API Service class
class ApiService {
  static ApiService? _instance;
  static ApiService get instance => _instance ??= ApiService._();

  ApiService._();

  http.Client? _client;
  String? _accessToken;
  String? _refreshToken;
  RequestInterceptor? _requestInterceptor;
  bool _useMockData = false;
  Map<String, MockDataProvider> _mockProviders = {};

  /// Initialize the API service
  void init({
    http.Client? client,
    RequestInterceptor? requestInterceptor,
  }) {
    _client = client ?? http.Client();
    _requestInterceptor = requestInterceptor;
    _instance = this;
  }

  /// Set authentication tokens
  void setTokens({String? accessToken, String? refreshToken}) {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
  }

  /// Clear authentication tokens
  void clearTokens() {
    _accessToken = null;
    _refreshToken = null;
  }

  /// Enable/disable mock data mode
  void setMockMode(bool enabled) {
    _useMockData = enabled;
  }

  /// Register a mock data provider
  void registerMockProvider<T>(String endpoint, MockDataProvider<T> provider) {
    _mockProviders[endpoint] = provider;
  }

  /// Clear all mock providers
  void clearMockProviders() {
    _mockProviders.clear();
  }

  /// Get default headers
  Map<String, String> _getHeaders() {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Client-Version': '1.0.0',
      'X-Platform': Platform.operatingSystem,
    };

    if (_accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }

    return headers;
  }

  /// Build full URL
  Uri _buildUrl(String endpoint, [Map<String, dynamic>? queryParams]) {
    final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    if (queryParams != null && queryParams.isNotEmpty) {
      return uri.replace(
        queryParameters: queryParams.map(
          (key, value) => MapEntry(
            key,
            value is List ? value.join(',') : value.toString(),
          ),
        ),
      );
    }
    return uri;
  }

  /// Execute request with retry logic
  Future<dynamic> _executeWithRetry(
    Future<http.Response> Function() request,
  ) async {
    int attempts = 0;
    while (attempts < ApiConfig.maxRetries) {
      try {
        final response = await request().timeout(
          ApiConfig.connectTimeout,
          onTimeout: () {
            throw ApiException.timeout();
          },
        );
        return response;
      } on TimeoutException {
        attempts++;
        if (attempts >= ApiConfig.maxRetries) {
          throw ApiException.timeout();
        }
        await Future.delayed(ApiConfig.retryDelay * attempts);
      } on SocketException {
        throw ApiException.network();
      } on http.ClientException {
        throw ApiException.network();
      }
    }
    throw ApiException.network('Max retries exceeded');
  }

  /// Handle response
  dynamic _handleResponse(http.Response response) {
    final contentType = response.headers['content-type'];
    dynamic data;
    
    if (contentType?.contains('application/json') ?? false) {
      try {
        data = json.decode(response.body);
      } catch (_) {
        data = response.body;
      }
    } else {
      data = response.body;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }

    String? requestId;
    if (data is Map<String, dynamic>) {
      requestId = data['request_id'];
    }

    throw ApiException.fromStatusCode(
      response.statusCode,
      data,
    ).copyWith(requestId: requestId);
  }

  /// Process mock data
  T? _processMockData<T>(String endpoint) {
    final provider = _mockProviders[endpoint];
    if (provider != null) {
      return provider() as T;
    }
    return null;
  }

  /// GET request
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    T Function(dynamic)? fromJsonT,
    bool useAuth = true,
  }) async {
    if (_useMockData) {
      final mockData = _processMockData<T>(endpoint);
      return ApiResponse(
        success: true,
        data: mockData,
      );
    }

    try {
      var headers = _getHeaders();
      if (!useAuth) {
        headers.remove('Authorization');
      }
      if (_requestInterceptor != null) {
        headers = await _requestInterceptor!(headers);
      }

      final response = await _executeWithRetry(
        () => _client!.get(
          _buildUrl(endpoint, queryParams),
          headers: headers,
        ),
      );

      final data = _handleResponse(response);
      return ApiResponse.fromJson(data as Map<String, dynamic>, fromJsonT);
    } on ApiException catch (e) {
      return ApiResponse(success: false, error: e.toString());
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }

  /// POST request
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(dynamic)? fromJsonT,
    bool useAuth = true,
  }) async {
    if (_useMockData) {
      final mockData = _processMockData<T>(endpoint);
      return ApiResponse(
        success: true,
        data: mockData,
      );
    }

    try {
      var headers = _getHeaders();
      if (!useAuth) {
        headers.remove('Authorization');
      }
      if (_requestInterceptor != null) {
        headers = await _requestInterceptor!(headers);
      }

      final response = await _executeWithRetry(
        () => _client!.post(
          _buildUrl(endpoint),
          headers: headers,
          body: body != null ? json.encode(body) : null,
        ),
      );

      final data = _handleResponse(response);
      return ApiResponse.fromJson(data as Map<String, dynamic>, fromJsonT);
    } on ApiException catch (e) {
      return ApiResponse(success: false, error: e.toString());
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }

  /// PUT request
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(dynamic)? fromJsonT,
    bool useAuth = true,
  }) async {
    if (_useMockData) {
      final mockData = _processMockData<T>(endpoint);
      return ApiResponse(
        success: true,
        data: mockData,
      );
    }

    try {
      var headers = _getHeaders();
      if (!useAuth) {
        headers.remove('Authorization');
      }
      if (_requestInterceptor != null) {
        headers = await _requestInterceptor!(headers);
      }

      final response = await _executeWithRetry(
        () => _client!.put(
          _buildUrl(endpoint),
          headers: headers,
          body: body != null ? json.encode(body) : null,
        ),
      );

      final data = _handleResponse(response);
      return ApiResponse.fromJson(data as Map<String, dynamic>, fromJsonT);
    } on ApiException catch (e) {
      return ApiResponse(success: false, error: e.toString());
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }

  /// PATCH request
  Future<ApiResponse<T>> patch<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(dynamic)? fromJsonT,
    bool useAuth = true,
  }) async {
    if (_useMockData) {
      final mockData = _processMockData<T>(endpoint);
      return ApiResponse(
        success: true,
        data: mockData,
      );
    }

    try {
      var headers = _getHeaders();
      if (!useAuth) {
        headers.remove('Authorization');
      }
      if (_requestInterceptor != null) {
        headers = await _requestInterceptor!(headers);
      }

      final response = await _executeWithRetry(
        () => _client!.patch(
          _buildUrl(endpoint),
          headers: headers,
          body: body != null ? json.encode(body) : null,
        ),
      );

      final data = _handleResponse(response);
      return ApiResponse.fromJson(data as Map<String, dynamic>, fromJsonT);
    } on ApiException catch (e) {
      return ApiResponse(success: false, error: e.toString());
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }

  /// DELETE request
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(dynamic)? fromJsonT,
    bool useAuth = true,
  }) async {
    if (_useMockData) {
      final mockData = _processMockData<T>(endpoint);
      return ApiResponse(
        success: true,
        data: mockData,
      );
    }

    try {
      var headers = _getHeaders();
      if (!useAuth) {
        headers.remove('Authorization');
      }
      if (_requestInterceptor != null) {
        headers = await _requestInterceptor!(headers);
      }

      final request = http.Request('DELETE', _buildUrl(endpoint));
      request.headers.addAll(headers);
      if (body != null) {
        request.body = json.encode(body);
      }

      final streamedResponse = await _executeWithRetry(
        () => _client!.send(request),
      );
      final response = await http.Response.fromStream(streamedResponse);

      final data = _handleResponse(response);
      return ApiResponse.fromJson(data as Map<String, dynamic>, fromJsonT);
    } on ApiException catch (e) {
      return ApiResponse(success: false, error: e.toString());
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }

  /// Upload file
  Future<ApiResponse<T>> uploadFile<T>(
    String endpoint, {
    required String filePath,
    required String fieldName,
    Map<String, String>? fields,
    T Function(dynamic)? fromJsonT,
    bool useAuth = true,
  }) async {
    if (_useMockData) {
      final mockData = _processMockData<T>(endpoint);
      return ApiResponse(
        success: true,
        data: mockData,
      );
    }

    try {
      var headers = _getHeaders();
      if (!useAuth) {
        headers.remove('Authorization');
      }
      headers.remove('Content-Type');

      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(headers);

      if (fields != null) {
        request.fields.addAll(fields);
      }

      request.files.add(
        await http.MultipartFile.fromPath(fieldName, filePath),
      );

      final streamedResponse = await _executeWithRetry(
        () => _client!.send(request),
      );
      final response = await http.Response.fromStream(streamedResponse);
      final data = _handleResponse(response);

      return ApiResponse.fromJson(data as Map<String, dynamic>, fromJsonT);
    } on ApiException catch (e) {
      return ApiResponse(success: false, error: e.toString());
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }

  /// Download file
  Future<Uint8List?> downloadFile(
    String endpoint, {
    bool useAuth = true,
  }) async {
    try {
      var headers = _getHeaders();
      if (!useAuth) {
        headers.remove('Authorization');
      }
      if (_requestInterceptor != null) {
        headers = await _requestInterceptor!(headers);
      }

      final response = await _executeWithRetry(
        () => _client!.get(
          _buildUrl(endpoint),
          headers: headers,
        ),
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Close the client
  void dispose() {
    _client?.close();
    _client = null;
  }
}

/// Extension to copy ApiException with requestId
extension ApiExceptionCopyWith on ApiException {
  ApiException copyWith({
    String? message,
    ApiErrorType? type,
    int? statusCode,
    dynamic data,
    String? requestId,
  }) {
    return ApiException(
      message: message ?? this.message,
      type: type ?? this.type,
      statusCode: statusCode ?? this.statusCode,
      data: data ?? this.data,
      requestId: requestId ?? this.requestId,
    );
  }
}
