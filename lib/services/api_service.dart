import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:fintrack/config/api_config.dart';
import 'package:fintrack/utils/exceptions.dart';
import 'package:fintrack/utils/logger.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final http.Client _client = http.Client();
  String? _authToken;
  String? _refreshToken;
  DateTime? _tokenExpiry;

  static const Duration _defaultTimeout = Duration(seconds: 30);
  static const int _maxRetries = 3;

  void setAuthToken(String token, {String? refreshToken, Duration? expiry}) {
    _authToken = token;
    _refreshToken = refreshToken;
    _tokenExpiry = expiry != null ? DateTime.now().add(expiry) : null;
    Logger.debug('Auth tokens updated');
  }

  void clearAuthToken() {
    _authToken = null;
    _refreshToken = null;
    _tokenExpiry = null;
    Logger.debug('Auth tokens cleared');
  }

  bool get isAuthenticated => _authToken != null && !_isTokenExpired();
  bool get _isTokenExpired => _tokenExpiry != null && DateTime.now().isAfter(_tokenExpiry!);

  Map<String, String> _getHeaders({bool requiresAuth = true, String? contentType}) {
    final headers = <String, String>{
      'Content-Type': contentType ?? 'application/json',
      'Accept': 'application/json',
      'X-Client-Version': ApiConfig.clientVersion,
      'X-Platform': Platform.operatingSystem,
    };

    if (requiresAuth && _authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    return headers;
  }

  Uri _buildUri(String endpoint, {Map<String, dynamic>? queryParams}) {
    final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.apiVersion}$endpoint');
    if (queryParams != null && queryParams.isNotEmpty) {
      return uri.replace(queryParameters: queryParams.map((k, v) => MapEntry(k, v.toString())));
    }
    return uri;
  }

  Future<Map<String, dynamic>> _handleResponse(http.Response response) async {
    final statusCode = response.statusCode;
    String responseBody;

    try {
      responseBody = response.body.isNotEmpty ? response.body : '{}';
      final jsonResponse = json.decode(responseBody) as Map<String, dynamic>;
      
      if (statusCode >= 200 && statusCode < 300) {
        return jsonResponse;
      }

      switch (statusCode) {
        case 400:
          throw BadRequestException(
            message: jsonResponse['message'] ?? 'Invalid request',
            errors: jsonResponse['errors'],
          );
        case 401:
          clearAuthToken();
          throw UnauthorizedException(
            message: jsonResponse['message'] ?? 'Authentication required',
            shouldRefresh: _refreshToken != null,
          );
        case 403:
          throw ForbiddenException(
            message: jsonResponse['message'] ?? 'Access denied',
          );
        case 404:
          throw NotFoundException(
            message: jsonResponse['message'] ?? 'Resource not found',
            endpoint: jsonResponse['endpoint'],
          );
        case 422:
          throw ValidationException(
            message: jsonResponse['message'] ?? 'Validation failed',
            errors: jsonResponse['errors'],
          );
        case 429:
          throw RateLimitException(
            message: jsonResponse['message'] ?? 'Too many requests',
            retryAfter: jsonResponse['retry_after'],
          );
        case 500:
        case 502:
        case 503:
          throw ServerException(
            message: jsonResponse['message'] ?? 'Server error occurred',
            statusCode: statusCode,
          );
        default:
          throw ApiException(
            message: jsonResponse['message'] ?? 'Unknown error occurred',
            statusCode: statusCode,
          );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      Logger.error('Response parsing error: $e');
      throw ApiException(
        message: 'Failed to parse server response',
        statusCode: statusCode,
      );
    }
  }

  Future<T> _executeWithRetry<T>(Future<T> Function() request) async {
    int attempts = 0;
    Duration retryDelay = const Duration(seconds: 1);

    while (true) {
      try {
        return await request();
      } on RateLimitException catch (e) {
        attempts++;
        if (attempts >= _maxRetries) rethrow;
        Logger.warn('Rate limited, retrying in ${e.retryAfter ?? 1}s...');
        await Future.delayed(Duration(seconds: e.retryAfter ?? retryDelay.inSeconds));
        retryDelay *= 2;
      } on ServerException catch (e) {
        attempts++;
        if (attempts >= _maxRetries || e.statusCode < 500) rethrow;
        Logger.warn('Server error ${e.statusCode}, retrying...');
        await Future.delayed(retryDelay);
        retryDelay *= 2;
      } on SocketException {
        attempts++;
        if (attempts >= _maxRetries) rethrow;
        Logger.warn('Network error, retrying...');
        await Future.delayed(retryDelay);
        retryDelay *= 2;
      }
    }
  }

  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
    bool requiresAuth = true,
  }) async {
    return _executeWithRetry(() async {
      final uri = _buildUri(endpoint, queryParams: queryParams);
      final requestHeaders = {..._getHeaders(requiresAuth: requiresAuth), ...?headers};
      
      Logger.debug('GET: $uri');
      final response = await _client.get(uri, headers: requestHeaders).timeout(_defaultTimeout);
      return _handleResponse(response);
    });
  }

  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
    bool requiresAuth = true,
  }) async {
    return _executeWithRetry(() async {
      final uri = _buildUri(endpoint, queryParams: queryParams);
      final requestHeaders = {..._getHeaders(requiresAuth: requiresAuth), ...?headers};
      final requestBody = body != null ? json.encode(body) : null;
      
      Logger.debug('POST: $uri');
      final response = await _client.post(uri, headers: requestHeaders, body: requestBody).timeout(_defaultTimeout);
      return _handleResponse(response);
    });
  }

  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
    bool requiresAuth = true,
  }) async {
    return _executeWithRetry(() async {
      final uri = _buildUri(endpoint, queryParams: queryParams);
      final requestHeaders = {..._getHeaders(requiresAuth: requiresAuth), ...?headers};
      final requestBody = body != null ? json.encode(body) : null;
      
      Logger.debug('PUT: $uri');
      final response = await _client.put(uri, headers: requestHeaders, body: requestBody).timeout(_defaultTimeout);
      return _handleResponse(response);
    });
  }

  Future<Map<String, dynamic>> patch(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
    bool requiresAuth = true,
  }) async {
    return _executeWithRetry(() async {
      final uri = _buildUri(endpoint, queryParams: queryParams);
      final requestHeaders = {..._getHeaders(requiresAuth: requiresAuth), ...?headers};
      final requestBody = body != null ? json.encode(body) : null;
      
      Logger.debug('PATCH: $uri');
      final response = await _client.patch(uri, headers: requestHeaders, body: requestBody).timeout(_defaultTimeout);
      return _handleResponse(response);
    });
  }

  Future<Map<String, dynamic>> delete(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
    bool requiresAuth = true,
  }) async {
    return _executeWithRetry(() async {
      final uri = _buildUri(endpoint, queryParams: queryParams);
      final requestHeaders = {..._getHeaders(requiresAuth: requiresAuth), ...?headers};
      final requestBody = body != null ? json.encode(body) : null;
      
      Logger.debug('DELETE: $uri');
      final response = await _client.delete(uri, headers: requestHeaders, body: requestBody).timeout(_defaultTimeout);
      return _handleResponse(response);
    });
  }

  Future<List<dynamic>> getList(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
    bool requiresAuth = true,
  }) async {
    return _executeWithRetry(() async {
      final uri = _buildUri(endpoint, queryParams: queryParams);
      final requestHeaders = {..._getHeaders(requiresAuth: requiresAuth), ...?headers};
      
      Logger.debug('GET LIST: $uri');
      final response = await _client.get(uri, headers: requestHeaders).timeout(_defaultTimeout);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        try {
          final decoded = json.decode(response.body);
          if (decoded is List) return decoded;
          if (decoded is Map && decoded.containsKey('data') && decoded['data'] is List) {
            return decoded['data'] as List;
          }
          throw ApiException(message: 'Unexpected response format', statusCode: response.statusCode);
        } catch (e) {
          if (e is ApiException) rethrow;
          throw ApiException(message: 'Failed to parse list response', statusCode: response.statusCode);
        }
      }
      
      await _handleResponse(response);
      return [];
    });
  }

  Future<Map<String, dynamic>> uploadFile(
    String endpoint, {
    required File file,
    required String fieldName,
    Map<String, String>? additionalFields,
    Map<String, String>? headers,
    void Function(int, int)? onProgress,
    bool requiresAuth = true,
  }) async {
    final uri = _buildUri(endpoint);
    final request = http.MultipartRequest('POST', uri);
    
    request.headers.addAll({..._getHeaders(requiresAuth: requiresAuth, contentType: null), ...?headers});
    request.files.add(await http.MultipartFile.fromPath(fieldName, file.path));
    
    if (additionalFields != null) {
      request.fields.addAll(additionalFields);
    }

    Logger.debug('UPLOAD: $uri');
    
    final streamedResponse = await request.send().timeout(const Duration(minutes: 5));
    final response = await http.Response.fromStream(streamedResponse);
    
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> downloadFile(
    String endpoint, {
    required String savePath,
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
    bool requiresAuth = true,
    void Function(int, int)? onProgress,
  }) async {
    return _executeWithRetry(() async {
      final uri = _buildUri(endpoint, queryParams: queryParams);
      final requestHeaders = {..._getHeaders(requiresAuth: requiresAuth), ...?headers};
      
      Logger.debug('DOWNLOAD: $uri');
      final request = http.Request('GET', uri);
      request.headers.addAll(requestHeaders);
      
      final streamedResponse = await _client.send(request).timeout(const Duration(minutes: 10));
      final file = File(savePath);
      final sink = file.openWrite();
      
      int received = 0;
      final contentLength = streamedResponse.contentLength ?? 0;
      
      await for (final chunk in streamedResponse.stream) {
        sink.add(chunk);
        received += chunk.length;
        onProgress?.call(received, contentLength);
      }
      
      await sink.close();
      
      if (streamedResponse.statusCode >= 200 && streamedResponse.statusCode < 300) {
        return {'path': savePath, 'size': received};
      }
      
      throw ApiException(message: 'Download failed', statusCode: streamedResponse.statusCode);
    });
  }

  void dispose() {
    _client.close();
    clearAuthToken();
    Logger.debug('ApiService disposed');
  }
}
