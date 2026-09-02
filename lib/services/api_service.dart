import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// HTTP methods enum for type safety
enum HttpMethod {
  get('GET'),
  post('POST'),
  put('PUT'),
  patch('PATCH'),
  delete('DELETE');

  final String value;
  const HttpMethod(this.value);
}

/// API response wrapper class
class ApiResponse<T> {
  final T? data;
  final int statusCode;
  final String? message;
  final bool success;
  final Map<String, String>? headers;

  ApiResponse({
    this.data,
    required this.statusCode,
    this.message,
    required this.success,
    this.headers,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    int statusCode, {
    T Function(dynamic)? fromJsonT,
  }) {
    return ApiResponse(
      data: fromJsonT != null && json['data'] != null
          ? fromJsonT(json['data'])
          : json['data'] as T?,
      statusCode: statusCode,
      message: json['message'] as String?,
      success: json['success'] as bool? ?? (statusCode >= 200 && statusCode < 300),
      headers: json['headers'] as Map<String, String>?,
    );
  }

  bool get isSuccess => success && (statusCode >= 200 && statusCode < 300);
  bool get isClientError => statusCode >= 400 && statusCode < 500;
  bool get isServerError => statusCode >= 500;
}

/// API service class for handling all HTTP communications
class ApiService {
  static ApiService? _instance;
  late final http.Client _client;
  late final String _baseUrl;
  late final Duration _timeout;
  String? _authToken;
  Map<String, String>? _customHeaders;

  ApiService._internal({
    String? baseUrl,
    Duration? timeout,
  })  : _baseUrl = baseUrl ?? ApiConfig.baseUrl,
        _timeout = timeout ?? ApiConfig.timeout {
    _client = http.Client();
    AppLogger.info('ApiService initialized with baseUrl: $_baseUrl');
  }

  /// Factory constructor for singleton pattern
  factory ApiService({
    String? baseUrl,
    Duration? timeout,
  }) {
    _instance ??= ApiService._internal(
      baseUrl: baseUrl,
      timeout: timeout,
    );
    return _instance!;
  }

  /// For testing purposes - allows injecting a new instance
  static void resetInstance() {
    _instance = null;
  }

  /// Set authentication token for secured endpoints
  void setAuthToken(String token) {
    _authToken = token;
    AppLogger.debug('Auth token set');
  }

  /// Clear authentication token on logout
  void clearAuthToken() {
    _authToken = null;
    AppLogger.debug('Auth token cleared');
  }

  /// Set custom headers that will be included in all requests
  void setCustomHeaders(Map<String, String> headers) {
    _customHeaders = headers;
    AppLogger.debug('Custom headers set: ${headers.keys.toList()}');
  }

  /// Get default headers for all requests
  Map<String, String> _getDefaultHeaders({bool requiresAuth = false}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      ...?ApiConfig.defaultHeaders,
      ...?_customHeaders,
    };

    if (requiresAuth && _authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    return headers;
  }

  /// Build full URL with optional path parameters and query string
  Uri _buildUri(String endpoint, {
    Map<String, String>? pathParams,
    Map<String, dynamic>? queryParams,
  }) {
    String url = endpoint;

    if (pathParams != null) {
      pathParams.forEach((key, value) {
        url = url.replaceAll('{$key}', Uri.encodeComponent(value));
      });
    }

    if (queryParams != null) {
      final encodedParams = <String, String>{};
      queryParams.forEach((key, value) {
        if (value != null) {
          if (value is List) {
            encodedParams[key] = jsonEncode(value);
          } else {
            encodedParams[key] = value.toString();
          }
        }
      });
      url = '$url?${Uri(queryParameters: encodedParams).query}';
    }

    return Uri.parse('$_baseUrl$url');
  }

  /// Execute HTTP request with proper error handling
  Future<ApiResponse<T>> _execute<T>({
    required HttpMethod method,
    required String endpoint,
    Map<String, String>? pathParams,
    Map<String, dynamic>? queryParams,
    dynamic body,
    bool requiresAuth = true,
    T Function(dynamic)? fromJson,
  }) async {
    final uri = _buildUri(endpoint, pathParams: pathParams, queryParams: queryParams);
    final headers = _getDefaultHeaders(requiresAuth: requiresAuth);
    String? requestBody;

    if (body != null) {
      if (body is Map<String, dynamic> || body is List) {
        requestBody = jsonEncode(body);
      } else if (body is String) {
        requestBody = body;
      }
    }

    AppLogger.debug('${method.value}: $uri');
    if (requestBody != null) {
      AppLogger.debug('Request body: $requestBody');
    }

    try {
      http.Response response;

      switch (method) {
        case HttpMethod.get:
          response = await _client
              .get(uri, headers: headers)
              .timeout(_timeout);
          break;
        case HttpMethod.post:
          response = await _client
              .post(uri, headers: headers, body: requestBody)
              .timeout(_timeout);
          break;
        case HttpMethod.put:
          response = await _client
              .put(uri, headers: headers, body: requestBody)
              .timeout(_timeout);
          break;
        case HttpMethod.patch:
          response = await _client
              .patch(uri, headers: headers, body: requestBody)
              .timeout(_timeout);
          break;
        case HttpMethod.delete:
          response = await _client
              .delete(uri, headers: headers, body: requestBody)
              .timeout(_timeout);
          break;
      }

      AppLogger.debug('Response status: ${response.statusCode}');
      AppLogger.debug('Response body: ${response.body}');

      return _parseResponse<T>(response, fromJson: fromJson);
    } on SocketException {
      AppLogger.error('Network error: No internet connection');
      throw ApiException(
        message: 'No internet connection. Please check your network.',
        statusCode: 0,
        type: ApiExceptionType.networkError,
      );
    } on http.ClientException catch (e) {
      AppLogger.error('HTTP client error: $e');
      throw ApiException(
        message: 'Failed to connect to server. Please try again.',
        statusCode: 0,
        type: ApiExceptionType.clientError,
      );
    } on FormatException catch (e) {
      AppLogger.error('Format error: $e');
      throw ApiException(
        message: 'Invalid response format from server.',
        statusCode: 0,
        type: ApiExceptionType.parseError,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      AppLogger.error('Unexpected error: $e');
      throw ApiException(
        message: 'An unexpected error occurred. Please try again.',
        statusCode: 0,
        type: ApiExceptionType.unknown,
      );
    }
  }

  /// Parse HTTP response and handle errors
  ApiResponse<T> _parseResponse<T>(
    http.Response response, {
    T Function(dynamic)? fromJson,
  }) {
    final statusCode = response.statusCode;
    Map<String, dynamic>? jsonBody;

    try {
      if (response.body.isNotEmpty) {
        jsonBody = jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (e) {
      AppLogger.warn('Failed to parse response body: $e');
    }

    if (statusCode >= 200 && statusCode < 300) {
      return ApiResponse<T>.fromJson(
        jsonBody ?? {},
        statusCode,
        fromJsonT: fromJson,
      );
    }

    final errorMessage = _extractErrorMessage(jsonBody, statusCode);
    final exceptionType = _getExceptionType(statusCode);

    throw ApiException(
      message: errorMessage,
      statusCode: statusCode,
      type: exceptionType,
      responseBody: response.body,
    );
  }

  /// Extract error message from response body or use default
  String _extractErrorMessage(Map<String, dynamic>? body, int statusCode) {
    if (body != null) {
      if (body.containsKey('message') && body['message'] != null) {
        return body['message'].toString();
      }
      if (body.containsKey('error') && body['error'] != null) {
        return body['error'].toString();
      }
      if (body.containsKey('detail') && body['detail'] != null) {
        return body['detail'].toString();
      }
    }

    switch (statusCode) {
      case 400:
        return 'Bad request. Please check your input.';
      case 401:
        return 'Unauthorized. Please log in again.';
      case 403:
        return 'Access denied. You do not have permission.';
      case 404:
        return 'Resource not found.';
      case 409:
        return 'Conflict. The resource already exists.';
      case 422:
        return 'Validation error. Please check your input.';
      case 429:
        return 'Too many requests. Please try again later.';
      case 500:
        return 'Server error. Please try again later.';
      case 502:
        return 'Bad gateway. Service temporarily unavailable.';
      case 503:
        return 'Service unavailable. Please try again later.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  /// Determine exception type based on status code
  ApiExceptionType _getExceptionType(int statusCode) {
    if (statusCode == 0) {
      return ApiExceptionType.networkError;
    }
    if (statusCode >= 400 && statusCode < 500) {
      return ApiExceptionType.clientError;
    }
    if (statusCode >= 500) {
      return ApiExceptionType.serverError;
    }
    return ApiExceptionType.unknown;
  }

  // ============================================
  // Public HTTP Methods
  // ============================================

  /// Perform GET request
  Future<ApiResponse<T>> get<T>({
    required String endpoint,
    Map<String, String>? pathParams,
    Map<String, dynamic>? queryParams,
    bool requiresAuth = true,
    T Function(dynamic)? fromJson,
  }) {
    return _execute<T>(
      method: HttpMethod.get,
      endpoint: endpoint,
      pathParams: pathParams,
      queryParams: queryParams,
      requiresAuth: requiresAuth,
      fromJson: fromJson,
    );
  }

  /// Perform POST request
  Future<ApiResponse<T>> post<T>({
    required String endpoint,
    Map<String, String>? pathParams,
    Map<String, dynamic>? queryParams,
    dynamic body,
    bool requiresAuth = true,
    T Function(dynamic)? fromJson,
  }) {
    return _execute<T>(
      method: HttpMethod.post,
      endpoint: endpoint,
      pathParams: pathParams,
      queryParams: queryParams,
      body: body,
      requiresAuth: requiresAuth,
      fromJson: fromJson,
    );
  }

  /// Perform PUT request
  Future<ApiResponse<T>> put<T>({
    required String endpoint,
    Map<String, String>? pathParams,
    Map<String, dynamic>? queryParams,
    dynamic body,
    bool requiresAuth = true,
    T Function(dynamic)? fromJson,
  }) {
    return _execute<T>(
      method: HttpMethod.put,
      endpoint: endpoint,
      pathParams: pathParams,
      queryParams: queryParams,
      body: body,
      requiresAuth: requiresAuth,
      fromJson: fromJson,
    );
  }

  /// Perform PATCH request
  Future<ApiResponse<T>> patch<T>({
    required String endpoint,
    Map<String, String>? pathParams,
    Map<String, dynamic>? queryParams,
    dynamic body,
    bool requiresAuth = true,
    T Function(dynamic)? fromJson,
  }) {
    return _execute<T>(
      method: HttpMethod.patch,
      endpoint: endpoint,
      pathParams: pathParams,
      queryParams: queryParams,
      body: body,
      requiresAuth: requiresAuth,
      fromJson: fromJson,
    );
  }

  /// Perform DELETE request
  Future<ApiResponse<T>> delete<T>({
    required String endpoint,
    Map<String, String>? pathParams,
    Map<String, dynamic>? queryParams,
    dynamic body,
    bool requiresAuth = true,
    T Function(dynamic)? fromJson,
  }) {
    return _execute<T>(
      method: HttpMethod.delete,
      endpoint: endpoint,
      pathParams: pathParams,
      queryParams: queryParams,
      body: body,
      requiresAuth: requiresAuth,
      fromJson: fromJson,
    );
  }

  /// Upload file with multipart request
  Future<ApiResponse<T>> uploadFile<T>({
    required String endpoint,
    required File file,
    required String fieldName,
    Map<String, String>? additionalFields,
    Map<String, String>? pathParams,
    bool requiresAuth = true,
    T Function(dynamic)? fromJson,
  }) async {
    final uri = _buildUri(endpoint, pathParams: pathParams);
    final headers = _getDefaultHeaders(requiresAuth: requiresAuth);
    headers.remove('Content-Type');

    AppLogger.debug('Uploading file to: $uri');

    try {
      final request = http.MultipartRequest('POST', uri)
        ..headers.addAll(headers)
        ..files.add(await http.MultipartFile.fromPath(fieldName, file.path));

      if (additionalFields != null) {
        request.fields.addAll(additionalFields);
      }

      final streamedResponse = await request.send().timeout(_timeout);
      final response = await http.Response.fromStream(streamedResponse);

      AppLogger.debug('Upload response status: ${response.statusCode}');

      return _parseResponse<T>(response, fromJson: fromJson);
    } on SocketException {
      throw ApiException(
        message: 'No internet connection.',
        statusCode: 0,
        type: ApiExceptionType.networkError,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'File upload failed. Please try again.',
        statusCode: 0,
        type: ApiExceptionType.unknown,
      );
    }
  }

  /// Download file
  Future<http.Response> downloadFile({
    required String endpoint,
    Map<String, String>? pathParams,
    Map<String, dynamic>? queryParams,
    bool requiresAuth = true,
  }) async {
    final uri = _buildUri(endpoint, pathParams: pathParams, queryParams: queryParams);
    final headers = _getDefaultHeaders(requiresAuth: requiresAuth);

    AppLogger.debug('Downloading file from: $uri');

    try {
      return await _client.get(uri, headers: headers).timeout(_timeout);
    } on SocketException {
      throw ApiException(
        message: 'No internet connection.',
        statusCode: 0,
        type: ApiExceptionType.networkError,
      );
    }
  }

  /// Clean up resources
  void dispose() {
    _client.close();
    AppLogger.info('ApiService disposed');
  }
}
