import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final http.Client _client = http.Client();
  String? _authToken;
  String? _refreshToken;

  static const Duration _defaultTimeout = Duration(seconds: 30);
  static const int _maxRetries = 3;

  void setAuthToken(String token) {
    _authToken = token;
    Logger.info('Auth token set successfully');
  }

  void setRefreshToken(String token) {
    _refreshToken = token;
    Logger.info('Refresh token set successfully');
  }

  void clearTokens() {
    _authToken = null;
    _refreshToken = null;
    Logger.info('Auth tokens cleared');
  }

  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Client-Version': ApiConfig.clientVersion,
      'X-Platform': Platform.operatingSystem,
    };
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? queryParams,
    Map<String, String>? headers,
    T Function(dynamic)? parser,
    Duration? timeout,
  }) async {
    return _request<T>(
      'GET',
      endpoint,
      queryParams: queryParams,
      headers: headers,
      parser: parser,
      timeout: timeout,
    );
  }

  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    dynamic body,
    Map<String, String>? queryParams,
    Map<String, String>? headers,
    T Function(dynamic)? parser,
    Duration? timeout,
  }) async {
    return _request<T>(
      'POST',
      endpoint,
      body: body,
      queryParams: queryParams,
      headers: headers,
      parser: parser,
      timeout: timeout,
    );
  }

  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    dynamic body,
    Map<String, String>? queryParams,
    Map<String, String>? headers,
    T Function(dynamic)? parser,
    Duration? timeout,
  }) async {
    return _request<T>(
      'PUT',
      endpoint,
      body: body,
      queryParams: queryParams,
      headers: headers,
      parser: parser,
      timeout: timeout,
    );
  }

  Future<ApiResponse<T>> patch<T>(
    String endpoint, {
    dynamic body,
    Map<String, String>? queryParams,
    Map<String, String>? headers,
    T Function(dynamic)? parser,
    Duration? timeout,
  }) async {
    return _request<T>(
      'PATCH',
      endpoint,
      body: body,
      queryParams: queryParams,
      headers: headers,
      parser: parser,
      timeout: timeout,
    );
  }

  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    dynamic body,
    Map<String, String>? queryParams,
    Map<String, String>? headers,
    T Function(dynamic)? parser,
    Duration? timeout,
  }) async {
    return _request<T>(
      'DELETE',
      endpoint,
      body: body,
      queryParams: queryParams,
      headers: headers,
      parser: parser,
      timeout: timeout,
    );
  }

  Future<ApiResponse<T>> uploadFile<T>(
    String endpoint, {
    required String filePath,
    required String fieldName,
    Map<String, String>? fields,
    Map<String, String>? headers,
    T Function(dynamic)? parser,
    Duration? timeout,
  }) async {
    final uri = _buildUri(endpoint);
    Logger.info('Uploading file to: ${uri.toString()}');

    try {
      final request = http.MultipartRequest('POST', uri);

      request.headers.addAll({..._headers, ...?headers});
      request.headers.remove('Content-Type');

      if (fields != null) {
        request.fields.addAll(fields);
      }

      request.files.add(
        await http.MultipartFile.fromPath(fieldName, filePath),
      );

      final streamedResponse = await _client.send(request).timeout(
        timeout ?? _defaultTimeout,
      );

      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse<T>(response, parser);
    } on SocketException catch (e) {
      Logger.error('Network error during file upload: ${e.message}');
      throw NetworkException('No internet connection. Please check your network.');
    } catch (e) {
      Logger.error('File upload error: $e');
      rethrow;
    }
  }

  Future<ApiResponse<T>> downloadFile<T>(
    String endpoint, {
    required String savePath,
    Map<String, String>? headers,
    void Function(int, int)? onProgress,
    Duration? timeout,
  }) async {
    final uri = _buildUri(endpoint);
    Logger.info('Downloading file from: ${uri.toString()}');

    try {
      final request = http.Request('GET', uri);
      request.headers.addAll({..._headers, ...?headers});

      final streamedResponse = await _client.send(request).timeout(
        timeout ?? _defaultTimeout,
      );

      final contentLength = streamedResponse.contentLength ?? 0;
      final file = File(savePath);
      final sink = file.openWrite();

      int received = 0;

      await for (final chunk in streamedResponse.stream) {
        sink.add(chunk);
        received += chunk.length;
        onProgress?.call(received, contentLength);
      }

      await sink.close();

      Logger.info('File downloaded successfully to: $savePath');
      return ApiResponse<T>(
        success: true,
        data: null,
        message: 'File downloaded successfully',
      );
    } on SocketException catch (e) {
      Logger.error('Network error during file download: ${e.message}');
      throw NetworkException('No internet connection. Please check your network.');
    } catch (e) {
      Logger.error('File download error: $e');
      rethrow;
    }
  }

  Future<ApiResponse<T>> _request<T>(
    String method,
    String endpoint, {
    dynamic body,
    Map<String, String>? queryParams,
    Map<String, String>? headers,
    T Function(dynamic)? parser,
    Duration? timeout,
    int retryCount = 0,
  }) async {
    final uri = _buildUri(endpoint, queryParams);
    Logger.info('[$method] Request to: ${uri.toString()}');

    if (body != null) {
      Logger.debug('Request body: ${jsonEncode(body)}');
    }

    try {
      final response = await _executeRequest(
        method,
        uri,
        body: body,
        headers: {..._headers, ...?headers},
        timeout: timeout,
      );

      return _handleResponse<T>(response, parser);
    } on UnauthorizedException catch (e) {
      if (retryCount < _maxRetries && _refreshToken != null) {
        Logger.warning('Unauthorized, attempting token refresh...');
        final refreshed = await _refreshAuthToken();
        if (refreshed) {
          return _request<T>(
            method,
            endpoint,
            body: body,
            queryParams: queryParams,
            headers: headers,
            parser: parser,
            timeout: timeout,
            retryCount: retryCount + 1,
          );
        }
      }
      clearTokens();
      rethrow;
    } on NetworkException {
      if (retryCount < _maxRetries) {
        Logger.warning('Retrying request (attempt ${retryCount + 1}/$_maxRetries)...');
        await Future.delayed(Duration(seconds: retryCount + 1));
        return _request<T>(
          method,
          endpoint,
          body: body,
          queryParams: queryParams,
          headers: headers,
          parser: parser,
          timeout: timeout,
          retryCount: retryCount + 1,
        );
      }
      rethrow;
    } catch (e) {
      Logger.error('Request error: $e');
      rethrow;
    }
  }

  Future<http.Response> _executeRequest(
    String method,
    Uri uri, {
    dynamic body,
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    switch (method) {
      case 'GET':
        return await _client.get(uri, headers: headers).timeout(timeout ?? _defaultTimeout);
      case 'POST':
        return await _client.post(
          uri,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        ).timeout(timeout ?? _defaultTimeout);
      case 'PUT':
        return await _client.put(
          uri,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        ).timeout(timeout ?? _defaultTimeout);
      case 'PATCH':
        return await _client.patch(
          uri,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        ).timeout(timeout ?? _defaultTimeout);
      case 'DELETE':
        return await _client.delete(
          uri,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        ).timeout(timeout ?? _defaultTimeout);
      default:
        throw ArgumentError('Unsupported HTTP method: $method');
    }
  }

  Future<http.Response> _executeRequestWithTimeout(
    String method,
    Uri uri, {
    dynamic body,
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    final effectiveTimeout = timeout ?? _defaultTimeout;

    switch (method) {
      case 'GET':
        return await _client.get(uri, headers: headers).timeout(effectiveTimeout);
      case 'POST':
        return await _client.post(
          uri,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        ).timeout(effectiveTimeout);
      case 'PUT':
        return await _client.put(
          uri,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        ).timeout(effectiveTimeout);
      case 'PATCH':
        return await _client.patch(
          uri,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        ).timeout(effectiveTimeout);
      case 'DELETE':
        return await _client.delete(
          uri,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        ).timeout(effectiveTimeout);
      default:
        throw ArgumentError('Unsupported HTTP method: $method');
    }
  }

  Uri _buildUri(String endpoint, [Map<String, String>? queryParams]) {
    String cleanEndpoint = endpoint;
    if (cleanEndpoint.startsWith('/')) {
      cleanEndpoint = cleanEndpoint.substring(1);
    }

    final baseUri = Uri.parse(ApiConfig.baseUrl);
    final uri = baseUri.resolve(cleanEndpoint);

    if (queryParams != null && queryParams.isNotEmpty) {
      return uri.replace(queryParameters: {...uri.queryParameters, ...queryParams});
    }

    return uri;
  }

  ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(dynamic)? parser,
  ) {
    Logger.info('Response status: ${response.statusCode}');
    Logger.debug('Response body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return ApiResponse<T>(
          success: true,
          data: null,
          message: 'Success',
          statusCode: response.statusCode,
        );
      }

      try {
        final decodedBody = jsonDecode(response.body);
        final data = parser != null ? parser(decodedBody) : decodedBody as T?;

        return ApiResponse<T>(
          success: true,
          data: data,
          message: _extractMessage(decodedBody),
          statusCode: response.statusCode,
        );
      } catch (e) {
        Logger.error('Response parsing error: $e');
        return ApiResponse<T>(
          success: true,
          data: response.body as T?,
          message: 'Success',
          statusCode: response.statusCode,
        );
      }
    }

    _handleErrorResponse(response);
    return ApiResponse<T>(
      success: false,
      data: null,
      message: 'Request failed',
      statusCode: response.statusCode,
    );
  }

  String _extractMessage(dynamic body) {
    if (body is Map<String, dynamic>) {
      return body['message'] as String? ??
             body['error'] as String? ??
             body['msg'] as String? ??
             'Success';
    }
    return 'Success';
  }

  void _handleErrorResponse(http.Response response) {
    String message;
    int? errorCode;

    try {
      final body = jsonDecode(response.body);
      message = body['message'] ?? body['error'] ?? 'An error occurred';
      errorCode = body['code'];
    } catch (_) {
      message = 'An error occurred';
    }

    Logger.error('API Error [${response.statusCode}]: $message');

    switch (response.statusCode) {
      case 400:
        throw BadRequestException(message, errorCode: errorCode);
      case 401:
        throw UnauthorizedException(message, errorCode: errorCode);
      case 403:
        throw ForbiddenException(message, errorCode: errorCode);
      case 404:
        throw NotFoundException(message, endpoint: response.request?.url.toString(), errorCode: errorCode);
      case 409:
        throw ConflictException(message, errorCode: errorCode);
      case 422:
        throw ValidationException(message, errorCode: errorCode);
      case 429:
        throw RateLimitException(message, errorCode: errorCode);
      case 500:
      case 502:
      case 503:
        throw ServerException(message, statusCode: response.statusCode, errorCode: errorCode);
      default:
        throw ApiException(message, statusCode: response.statusCode, errorCode: errorCode);
    }
  }

  Future<bool> _refreshAuthToken() async {
    if (_refreshToken == null) return false;

    try {
      final uri = _buildUri('${ApiConfig.apiVersion}/auth/refresh');
      Logger.info('Refreshing auth token...');

      final response = await _client.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_refreshToken',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final newToken = body['access_token'] as String?;
        final newRefreshToken = body['refresh_token'] as String?;

        if (newToken != null) {
          setAuthToken(newToken);
          if (newRefreshToken != null) {
            setRefreshToken(newRefreshToken);
          }
          Logger.info('Auth token refreshed successfully');
          return true;
        }
      }

      Logger.warning('Token refresh failed with status: ${response.statusCode}');
      return false;
    } catch (e) {
      Logger.error('Token refresh error: $e');
      return false;
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> healthCheck() async {
    try {
      final uri = _buildUri('health');
      final response = await _client.get(uri).timeout(const Duration(seconds: 5));

      return ApiResponse<Map<String, dynamic>>(
        success: response.statusCode == 200,
        data: response.statusCode == 200 ? jsonDecode(response.body) : null,
        message: response.statusCode == 200 ? 'Healthy' : 'Unhealthy',
        statusCode: response.statusCode,
      );
    } catch (e) {
      Logger.error('Health check failed: $e');
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        data: null,
        message: 'Health check failed: $e',
        statusCode: 0,
      );
    }
  }

  void dispose() {
    _client.close();
    clearTokens();
    Logger.info('ApiService disposed');
  }
}

class ApiResponse<T> {
  final bool success;
  final T? data;
  final String message;
  final int statusCode;

  ApiResponse({
    required this.success,
    this.data,
    required this.message,
    required this.statusCode,
  });

  @override
  String toString() {
    return 'ApiResponse(success: $success, message: $message, statusCode: $statusCode, data: $data)';
  }

  bool get isSuccess => success;
  bool get isError => !success;
  bool get isUnauthorized => statusCode == 401;
  bool get isServerError => statusCode >= 500;
}
