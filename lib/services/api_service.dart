import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fintrack/core/constants/api_constants.dart';
import 'package:fintrack/core/constants/app_constants.dart';
import 'package:fintrack/core/error/exceptions.dart';
import 'package:fintrack/core/utils/logger.dart';

class ApiService {
  final http.Client _client;
  final String _baseUrl;
  String? _authToken;

  ApiService({
    http.Client? client,
    String? baseUrl,
  })  : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? ApiConstants.baseUrl;

  void setAuthToken(String? token) {
    _authToken = token;
  }

  void clearAuthToken() {
    _authToken = null;
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

  Future<dynamic> get(
    String endpoint, {
    Map<String, String>? queryParams,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParams);
      final mergedHeaders = {..._headers, ...?headers};

      AppLogger.debug('GET Request: $uri');
      AppLogger.debug('Headers: $mergedHeaders');

      final response = await _client
          .get(uri, headers: mergedHeaders)
          .timeout(const Duration(seconds: AppConstants.apiTimeout));

      return _handleResponse(response);
    } catch (e) {
      AppLogger.error('GET Error: $e');
      rethrow;
    }
  }

  Future<dynamic> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParams);
      final mergedHeaders = {..._headers, ...?headers};
      final requestBody = body != null ? jsonEncode(body) : null;

      AppLogger.debug('POST Request: $uri');
      AppLogger.debug('Body: $requestBody');

      final response = await _client
          .post(uri, headers: mergedHeaders, body: requestBody)
          .timeout(const Duration(seconds: AppConstants.apiTimeout));

      return _handleResponse(response);
    } catch (e) {
      AppLogger.error('POST Error: $e');
      rethrow;
    }
  }

  Future<dynamic> put(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParams);
      final mergedHeaders = {..._headers, ...?headers};
      final requestBody = body != null ? jsonEncode(body) : null;

      AppLogger.debug('PUT Request: $uri');
      AppLogger.debug('Body: $requestBody');

      final response = await _client
          .put(uri, headers: mergedHeaders, body: requestBody)
          .timeout(const Duration(seconds: AppConstants.apiTimeout));

      return _handleResponse(response);
    } catch (e) {
      AppLogger.error('PUT Error: $e');
      rethrow;
    }
  }

  Future<dynamic> patch(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParams);
      final mergedHeaders = {..._headers, ...?headers};
      final requestBody = body != null ? jsonEncode(body) : null;

      AppLogger.debug('PATCH Request: $uri');
      AppLogger.debug('Body: $requestBody');

      final response = await _client
          .patch(uri, headers: mergedHeaders, body: requestBody)
          .timeout(const Duration(seconds: AppConstants.apiTimeout));

      return _handleResponse(response);
    } catch (e) {
      AppLogger.error('PATCH Error: $e');
      rethrow;
    }
  }

  Future<dynamic> delete(
    String endpoint, {
    Map<String, String>? queryParams,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParams);
      final mergedHeaders = {..._headers, ...?headers};

      AppLogger.debug('DELETE Request: $uri');

      final response = await _client
          .delete(uri, headers: mergedHeaders)
          .timeout(const Duration(seconds: AppConstants.apiTimeout));

      return _handleResponse(response);
    } catch (e) {
      AppLogger.error('DELETE Error: $e');
      rethrow;
    }
  }

  Future<dynamic> uploadFile(
    String endpoint, {
    required String filePath,
    required String fileFieldName,
    Map<String, String>? fields,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = _buildUri(endpoint, null);
      final mergedHeaders = {..._headers, ...?headers};

      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(mergedHeaders);

      if (fields != null) {
        request.fields.addAll(fields);
      }

      request.files.add(await http.MultipartFile.fromPath(
        fileFieldName,
        filePath,
      ));

      AppLogger.debug('FILE UPLOAD Request: $endpoint');
      AppLogger.debug('File: $filePath');

      final streamedResponse = await _client
          .send(request)
          .timeout(const Duration(seconds: AppConstants.fileUploadTimeout));

      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } catch (e) {
      AppLogger.error('File Upload Error: $e');
      rethrow;
    }
  }

  Future<dynamic> downloadFile(
    String endpoint, {
    String? savePath,
    Map<String, String>? queryParams,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParams);
      final mergedHeaders = {..._headers, ...?headers};

      AppLogger.debug('FILE DOWNLOAD Request: $uri');

      final response = await _client
          .get(uri, headers: mergedHeaders)
          .timeout(const Duration(seconds: AppConstants.fileUploadTimeout));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response.bodyBytes;
      } else {
        throw ApiException(
          message: _parseErrorMessage(response.body),
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      AppLogger.error('File Download Error: $e');
      rethrow;
    }
  }

  Uri _buildUri(String endpoint, Map<String, String>? queryParams) {
    final uri = Uri.parse('$_baseUrl$endpoint');
    if (queryParams != null && queryParams.isNotEmpty) {
      return uri.replace(queryParameters: queryParams);
    }
    return uri;
  }

  dynamic _handleResponse(http.Response response) {
    AppLogger.debug('Response Status: ${response.statusCode}');
    AppLogger.debug('Response Body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return {'success': true};
      }
      final decodedBody = jsonDecode(response.body);
      return decodedBody;
    } else {
      throw ApiException(
        message: _parseErrorMessage(response.body),
        statusCode: response.statusCode,
      );
    }
  }

  String _parseErrorMessage(String responseBody) {
    try {
      final decoded = jsonDecode(responseBody);
      if (decoded is Map) {
        return decoded['message'] ??
            decoded['error'] ??
            decoded['errors']?.toString() ??
            'An unexpected error occurred';
      }
      return 'An unexpected error occurred';
    } catch (_) {
      return 'An unexpected error occurred';
    }
  }

  void dispose() {
    _client.close();
    _authToken = null;
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException({
    required this.message,
    this.statusCode,
  });

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';

  bool get isNetworkError => statusCode == null;
  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;
  bool get isServerError => statusCode != null && statusCode! >= 500;
  bool get isBadRequest => statusCode == 400;
}
