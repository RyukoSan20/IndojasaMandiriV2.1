import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/models.dart';
import '../utils/logger.dart';

/// Response wrapper for API calls
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final ApiError? error;
  final int statusCode;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.error,
    required this.statusCode,
  });

  factory ApiResponse.success(T data, {String? message, int statusCode = 200}) {
    return ApiResponse(
      success: true,
      data: data,
      message: message,
      statusCode: statusCode,
    );
  }

  factory ApiResponse.error(ApiError error, {int statusCode = 400}) {
    return ApiResponse(
      success: false,
      error: error,
      statusCode: statusCode,
    );
  }
}

/// API Error model
class ApiError {
  final String code;
  final String message;
  final List<FieldError>? details;

  ApiError({
    required this.code,
    required this.message,
    this.details,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      code: json['code'] ?? 'UNKNOWN_ERROR',
      message: json['message'] ?? 'An unknown error occurred',
      details: json['details'] != null
          ? (json['details'] as List)
              .map((d) => FieldError.fromJson(d))
              .toList()
          : null,
    );
  }
}

/// Field-specific error
class FieldError {
  final String field;
  final String message;

  FieldError({required this.field, required this.message});

  factory FieldError.fromJson(Map<String, dynamic> json) {
    return FieldError(
      field: json['field'] ?? '',
      message: json['message'] ?? '',
    );
  }
}

/// HTTP methods enum
enum HttpMethod { get, post, put, patch, delete }

/// Request options
class RequestOptions {
  final Map<String, dynamic>? queryParams;
  final Map<String, String>? headers;
  final Duration? timeout;
  final bool useAuth;

  RequestOptions({
    this.queryParams,
    this.headers,
    this.timeout,
    this.useAuth = true,
  });
}

/// API Service class with complete HTTP request methods, error handling, and mock data fallback
class ApiService {
  static ApiService? _instance;
  static ApiService get instance => _instance ??= ApiService._();
  
  ApiService._();

  // HTTP Client
  late http.Client _client;
  
  // Token storage
  String? _accessToken;
  String? _refreshToken;
  
  // Base URL
  late String _baseUrl;
  
  // Shared Preferences
  SharedPreferences? _prefs;
  
  // Network connectivity
  bool _isOnline = true;
  
  // Mock mode flag
  bool _useMockData = false;
  
  // Logger
  final _logger = AppLogger('ApiService');

  /// Initialize the API service
  Future<void> init({
    String? baseUrl,
    bool useMockData = false,
  }) async {
    _client = http.Client();
    _baseUrl = baseUrl ?? ApiConfig.baseUrl;
    _useMockData = useMockData || kDebugMode;
    _prefs = await SharedPreferences.getInstance();
    
    _loadTokens();
    
    _logger.info('API Service initialized with base URL: $_baseUrl');
    _logger.info('Mock data mode: $_useMockData');
  }

  /// Load tokens from storage
  void _loadTokens() {
    _accessToken = _prefs?.getString('access_token');
    _refreshToken = _prefs?.getString('refresh_token');
  }

  /// Save tokens to storage
  Future<void> _saveTokens(String accessToken, String refreshToken) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    await _prefs?.setString('access_token', accessToken);
    await _prefs?.setString('refresh_token', refreshToken);
  }

  /// Clear tokens
  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    await _prefs?.remove('access_token');
    await _prefs?.remove('refresh_token');
  }

  /// Check if user is authenticated
  bool get isAuthenticated => _accessToken != null;

  /// Set authentication tokens
  Future<void> setTokens(String accessToken, String refreshToken) async {
    await _saveTokens(accessToken, refreshToken);
  }

  /// Update network status
  void setNetworkStatus(bool isOnline) {
    _isOnline = isOnline;
    _logger.info('Network status: ${isOnline ? "Online" : "Offline"}');
  }

  // =========================================================================
  // HTTP REQUEST METHODS
  // =========================================================================

  /// Make GET request
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    RequestOptions? options,
    T Function(dynamic)? parser,
  }) async {
    return _request<T>(
      endpoint,
      HttpMethod.get,
      options: options,
      parser: parser,
    );
  }

  /// Make POST request
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    dynamic body,
    RequestOptions? options,
    T Function(dynamic)? parser,
  }) async {
    return _request<T>(
      endpoint,
      HttpMethod.post,
      body: body,
      options: options,
      parser: parser,
    );
  }

  /// Make PUT request
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    dynamic body,
    RequestOptions? options,
    T Function(dynamic)? parser,
  }) async {
    return _request<T>(
      endpoint,
      HttpMethod.put,
      body: body,
      options: options,
      parser: parser,
    );
  }

  /// Make PATCH request
  Future<ApiResponse<T>> patch<T>(
    String endpoint, {
    dynamic body,
    RequestOptions? options,
    T Function(dynamic)? parser,
  }) async {
    return _request<T>(
      endpoint,
      HttpMethod.patch,
      body: body,
      options: options,
      parser: parser,
    );
  }

  /// Make DELETE request
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    RequestOptions? options,
    T Function(dynamic)? parser,
  }) async {
    return _request<T>(
      endpoint,
      HttpMethod.delete,
      options: options,
      parser: parser,
    );
  }

  /// Core request method
  Future<ApiResponse<T>> _request<T>(
    String endpoint,
    HttpMethod method, {
    dynamic body,
    RequestOptions? options,
    T Function(dynamic)? parser,
  }) async {
    // Use mock data if enabled or offline
    if (_useMockData || !_isOnline) {
      return _handleMockRequest<T>(endpoint, method, body, parser);
    }

    try {
      // Build URL with query parameters
      final uri = _buildUri(endpoint, options?.queryParams);
      
      // Build headers
      final headers = _buildHeaders(options);
      
      // Log request
      _logger.debug('${method.name.toUpperCase()} $uri');
      if (body != null) {
        _logger.debug('Body: ${jsonEncode(body)}');
      }

      // Make request based on method
      http.Response response;
      final timeout = options?.timeout ?? const Duration(seconds: 30);

      switch (method) {
        case HttpMethod.get:
          response = await _client.get(uri, headers: headers).timeout(timeout);
          break;
        case HttpMethod.post:
          response = await _client
              .post(uri, headers: headers, body: jsonEncode(body))
              .timeout(timeout);
          break;
        case HttpMethod.put:
          response = await _client
              .put(uri, headers: headers, body: jsonEncode(body))
              .timeout(timeout);
          break;
        case HttpMethod.patch:
          response = await _client
              .patch(uri, headers: headers, body: jsonEncode(body))
              .timeout(timeout);
          break;
        case HttpMethod.delete:
          response = await _client.delete(uri, headers: headers).timeout(timeout);
          break;
      }

      // Handle response
      return _handleResponse<T>(response, parser);

    } on TimeoutException {
      _logger.error('Request timeout: $endpoint');
      return ApiResponse.error(
        ApiError(code: 'TIMEOUT', message: 'Request timed out'),
        statusCode: 408,
      );
    } on SocketException catch (e) {
      _logger.error('Network error: ${e.message}');
      _isOnline = false;
      // Fallback to mock data
      return _handleMockRequest<T>(endpoint, method, body, parser);
    } catch (e) {
      _logger.error('Request error: $e');
      return ApiResponse.error(
        ApiError(code: 'NETWORK_ERROR', message: e.toString()),
        statusCode: 500,
      );
    }
  }

  /// Build URI with query parameters
  Uri _buildUri(String endpoint, Map<String, dynamic>? queryParams) {
    var uriString = '$_baseUrl$endpoint';
    
    if (queryParams != null && queryParams.isNotEmpty) {
      final queryString = queryParams.entries
          .where((e) => e.value != null)
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value.toString())}')
          .join('&');
      uriString += '?$queryString';
    }
    
    return Uri.parse(uriString);
  }

  /// Build request headers
  Map<String, String> _buildHeaders(RequestOptions? options) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Client-Version': '1.0.0',
      'X-Platform': Platform.operatingSystem,
    };

    // Add authorization header if required
    if (options?.useAuth != false && _accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }

    // Add custom headers
    if (options?.headers != null) {
      headers.addAll(options!.headers!);
    }

    return headers;
  }

  /// Handle HTTP response
  ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(dynamic)? parser,
  ) {
    _logger.debug('Response ${response.statusCode}: ${response.body}');

    // Handle rate limiting
    if (response.statusCode == 429) {
      return ApiResponse.error(
        ApiError(code: 'RATE_LIMITED', message: 'Too many requests'),
        statusCode: 429,
      );
    }

    // Handle token expiration
    if (response.statusCode == 401) {
      _handleTokenExpiration();
      return ApiResponse.error(
        ApiError(code: 'TOKEN_EXPIRED', message: 'Session expired'),
        statusCode: 401,
      );
    }

    // Parse response body
    dynamic responseData;
    try {
      responseData = jsonDecode(response.body);
    } catch (e) {
      responseData = response.body;
    }

    // Handle success responses
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = responseData is Map && responseData.containsKey('data')
          ? responseData['data']
          : responseData;
      
      T? parsedData;
      if (parser != null && data != null) {
        parsedData = parser(data);
      } else if (data is T) {
        parsedData = data;
      }

      return ApiResponse.success(
        parsedData as T,
        message: responseData is Map ? responseData['message'] : null,
        statusCode: response.statusCode,
      );
    }

    // Handle error responses
    ApiError error;
    if (responseData is Map) {
      error = ApiError.fromJson(responseData['error'] ?? responseData);
    } else {
      error = ApiError(
        code: _getErrorCode(response.statusCode),
        message: responseData.toString(),
      );
    }

    return ApiResponse.error(error, statusCode: response.statusCode);
  }

  /// Get error code from status code
  String _getErrorCode(int statusCode) {
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
      case 500:
        return 'INTERNAL_ERROR';
      default:
        return 'UNKNOWN_ERROR';
    }
  }

  /// Handle token expiration
  Future<void> _handleTokenExpiration() async {
    if (_refreshToken == null) {
      await clearTokens();
      return;
    }

    try {
      final response = await refreshToken();
      if (!response.success) {
        await clearTokens();
      }
    } catch (e) {
      _logger.error('Token refresh failed: $e');
      await clearTokens();
    }
  }

  /// Refresh access token
  Future<ApiResponse<bool>> refreshToken() async {
    if (_refreshToken == null) {
      return ApiResponse.error(
        ApiError(code: 'NO_REFRESH_TOKEN', message: 'No refresh token available'),
      );
    }

    try {
      final uri = Uri.parse('$_baseUrl/auth/refresh');
      final response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': _refreshToken}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _saveTokens(
          data['data']['tokens']['accessToken'],
          data['data']['tokens']['refreshToken'],
        );
        return ApiResponse.success(true);
      }

      return ApiResponse.error(
        ApiError.fromJson(jsonDecode(response.body)['error'] ?? {}),
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse.error(
        ApiError(code: 'REFRESH_FAILED', message: e.toString()),
      );
    }
  }

  // =========================================================================
  // MOCK DATA HANDLING
  // =========================================================================

  /// Handle mock request
  Future<ApiResponse<T>> _handleMockRequest<T>(
    String endpoint,
    HttpMethod method,
    dynamic body,
    T Function(dynamic)? parser,
  ) async {
    _logger.info('Using mock data for: ${method.name.toUpperCase()} $endpoint');

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    // Route to appropriate mock handler
    final mockData = _getMockData<T>(endpoint, method, body, parser);
    return mockData;
  }

  /// Get mock data based on endpoint
  Future<ApiResponse<T>> _getMockData<T>(
    String endpoint,
    HttpMethod method,
    dynamic body,
    T Function(dynamic)? parser,
  ) async {
    // Auth endpoints
    if (endpoint.startsWith('/auth/')) {
      return _mockAuth<T>(endpoint, method, body, parser);
    }
    
    // Dashboard endpoints
    if (endpoint.startsWith('/dashboard/')) {
      return _mockDashboard<T>(endpoint, parser);
    }
    
    // Account endpoints
    if (endpoint.startsWith('/accounts')) {
      return _mockAccounts<T>(endpoint, method, body, parser);
    }
    
    // Transaction endpoints
    if (endpoint.startsWith('/transactions')) {
      return _mockTransactions<T>(endpoint, method, body, parser);
    }
    
    // Category endpoints
    if (endpoint.startsWith('/categories')) {
      return _mockCategories<T>(endpoint, parser);
    }
    
    // Goals endpoints
    if (endpoint.startsWith('/goals')) {
      return _mockGoals<T>(endpoint, method, body, parser);
    }
    
    // Portfolio endpoints
    if (endpoint.startsWith('/portfolio')) {
      return _mockPortfolio<T>(endpoint, method, body, parser);
    }
    
    // Watchlist endpoints
    if (endpoint.startsWith('/watchlist')) {
      return _mockWatchlist<T>(endpoint, method, body, parser);
    }
    
    // Statistics endpoints
    if (endpoint.startsWith('/stats/')) {
      return _mockStatistics<T>(endpoint, parser);
    }
    
    // User endpoints
    if (endpoint.startsWith('/users/')) {
      return _mockUser<T>(endpoint, method, body, parser);
    }

    return ApiResponse.error(
      ApiError(code: 'NOT_IMPLEMENTED', message: 'Mock data not available for this endpoint'),
    );
  }

  // =========================================================================
  // AUTH MOCK DATA
  // =========================================================================

  Future<ApiResponse<T>> _mockAuth<T>(
    String endpoint,
    HttpMethod method,
    dynamic body,
    T Function(dynamic)? parser,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (endpoint == '/auth/login' && method == HttpMethod.post) {
      final mockUser = _generateMockUser();
      final tokens = _generateMockTokens();
      return ApiResponse.success(
        parser?.call({'user': mockUser, 'tokens': tokens}) ?? 
            {'user': mockUser, 'tokens': tokens} as T,
        message: 'Login successful',
      );
    }

    if (endpoint == '/auth/register' && method == HttpMethod.post) {
      final mockUser = _generateMockUser();
      final tokens = _generateMockTokens();
      return ApiResponse.success(
        parser?.call({'user': mockUser, 'tokens': tokens}) ?? 
            {'user': mockUser, 'tokens': tokens} as T,
        message: 'Registration successful',
        statusCode: 201,
      );
    }

    if (endpoint == '/auth/me' && method == HttpMethod.get) {
      return ApiResponse.success(
        parser?.call(_generateMockUser()) ?? _generateMockUser() as T,
      );
    }

    if (endpoint == '/auth/refresh' && method == HttpMethod.post) {
      return ApiResponse.success(
        parser?.call(_generateMockTokens()) ?? _generateMockTokens() as T,
      );
    }

    return ApiResponse.success(
      {'success': true} as T,
      message: 'Success',
    );
  }

  Map<String, dynamic> _generateMockUser() {
    return {
      'id': 'usr_${DateTime.now().millisecondsSinceEpoch}',
      'email': 'demo@fintrack.app',
      'fullName': 'Demo User',
      'avatar': null,
      'currency': 'IDR',
      'timezone': 'Asia/Jakarta',
      'language': 'id',
      'emailVerified': true,
      'pinEnabled': false,
      'biometricEnabled': false,
      'settings': {
        'theme': 'light',
        'notifications': true,
        'language': 'id',
      },
      'createdAt': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  Map<String, dynamic> _generateMockTokens() {
    final accessToken = base64Encode(utf8.encode('mock_access_token_${DateTime.now().millisecondsSinceEpoch}'));
    final refreshToken = base64Encode(utf8.encode('mock_refresh_token_${DateTime.now().millisecondsSinceEpoch}'));
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'expiresIn': 900,
    };
  }

  // =========================================================================
  // DASHBOARD MOCK DATA
  // =========================================================================

  Future<ApiResponse<T>> _mockDashboard<T>(
    String endpoint,
    T Function(dynamic)? parser,
  ) async {
    if (endpoint == '/dashboard/summary') {
      return ApiResponse.success(
        parser?.call(_mockDashboardSummary()) ?? _mockDashboardSummary() as T,
      );
    }

    if (endpoint == '/dashboard/cashflow') {
      return ApiResponse.success(
        parser?.call(_mockCashflowData()) ?? _mockCashflowData() as T,
      );
    }

    if (endpoint == '/dashboard/networth') {
      return ApiResponse.success(
        parser?.call(_mockNetworthData()) ?? _mockNetworthData() as T,
      );
    }

    if (endpoint == '/dashboard/insights') {
      return ApiResponse.success(
        parser?.call(_mockInsights()) ?? _mockInsights() as T,
      );
    }

    return ApiResponse.success(
      parser?.call(_mockDashboardSummary()) ?? _mockDashboardSummary() as T,
    );
  }

  Map<String, dynamic> _mockDashboardSummary() {
    return {
      'totalBalance': 157500000,
      'totalIncome': 15000000,
      'totalExpense': 8500000,
      'totalSavings': 45000000,
      'portfolioValue': 75000000,
      'monthlyChange': 6500000,
      'monthlyChangePercent': 4.3,
      'accounts': [
        {'id': 'acc_1', 'name': 'Bank BCA', 'balance': 85000000, 'type': 'bank'},
        {'id': 'acc_2', 'name': 'OVO', 'balance': 2500000, 'type': 'ewallet'},
        {'id': 'acc_3', 'name': 'Tabungan', 'balance': 70000000, 'type': 'savings'},
      ],
      'recentTransactions': _mockTransactionList(5),
      'topCategories': [
        {'name': 'Makanan', 'amount': 2500000, 'percent': 29.4},
        {'name': 'Transportasi', 'amount': 1500000, 'percent': 17.6},
        {'name': 'Belanja', 'amount': 2000000, 'percent': 23.5},
        {'name': 'Hiburan', 'amount': 1000000, 'percent': 11.8},
        {'name': 'Tagihan', 'amount': 1500000, 'percent': 17.6},
      ],
    };
  }

  Map<String, dynamic> _mockCashflowData() {
    final months = <Map<String, dynamic>>[];
    final now = DateTime.now();
    for (int i = 5; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i, 1);
      months.add({
        'month': '${date.year}-${date.month.toString().padLeft(2, '0')}',
        'income': 10000000 + (i * 500000),
        'expense': 6000000 + (i * 300000),
        'savings': 4000000 + (i * 200000),
      });
    }
    return {
      'data': months,
      'totalIncome': 63000000,
      'totalExpense': 37800000,
      'netSavings': 25200000,
    };
  }

  Map<String, dynamic> _mockNetworthData() {
    final history = <Map<String, dynamic>>[];
    final now = DateTime.now();
    for (int i = 11; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i, 1);
      history.add({
        'month': '${date.year}-${date.month.toString().padLeft(2, '0')}',
        'assets': 100000000 + (11 - i) * 5000000,
        'liabilities': 0,
        'netWorth': 100000000 + (11 - i) * 5000000,
      });
    }
    return {
      'currentNetWorth': 157500000,
      'changePercent': 12.5,
      'history': history,
    };
  }

  List<Map<String, dynamic>> _mockInsights() {
    return [
      {
        'id': 'ins_1',
        'type': 'spending_alert',
        'title': 'Pengeluaran Meningkat',
        'message': 'Pengeluaran bulan ini 15% lebih tinggi dari rata-rata',
        'severity': 'warning',
        'actionable': true,
      },
      {
        'id': 'ins_2',
        'type': 'savings_opportunity',
        'title': 'Tabungan Bisa Ditingkatkan',
        'message': 'Dengan mengurangi hiburan 10%, Anda bisa menabung 1.5 juta/bulan',
        'severity': 'info',
        'actionable': true,
      },
      {
        'id': 'ins_3',
        'type': 'goal_progress',
        'title': '73% Menuju Target Liburan',
        'message': 'Hanya 2.7 juta lagi untuk mencapai target liburan',
        'severity': 'success',
        'actionable': false,
      },
    ];
  }

  // =========================================================================
  // ACCOUNTS MOCK DATA
  // =========================================================================

  Future<ApiResponse<T>> _mockAccounts<T>(
    String endpoint,
    HttpMethod method,
    dynamic body,
    T Function(dynamic)? parser,
  ) async {
    if (endpoint == '/accounts' && method == HttpMethod.get) {
      return ApiResponse.success(
        parser?.call(_mockAccountList()) ?? _mockAccountList() as T,
      );
    }

    if (endpoint == '/accounts' && method == HttpMethod.post) {
      final newAccount = {
        'id': 'acc_${DateTime.now().millisecondsSinceEpoch}',
        'name': (body as Map)['name'] ?? 'New Account',
        'type': (body as Map)['type'] ?? 'bank',
        'balance': (body as Map)['initialBalance'] ?? 0,
        'currency': 'IDR',
        'icon': (body as Map)['icon'] ?? 'account_balance',
        'color': (body as Map)['color'] ?? '#6366F1',
        'isActive': true,
        'createdAt': DateTime.now().toIso8601String(),
      };
      return ApiResponse.success(
        parser?.call(newAccount) ?? newAccount as T,
        message: 'Account created',
        statusCode: 201,
      );
    }

    // Single account operations
    final accountId = endpoint.split('/').length > 2 ? endpoint.split('/')[2] : null;
    if (accountId != null) {
      if (method == HttpMethod.get) {
        return ApiResponse.success(
          parser?.call(_mockAccountList().firstWhere((a) => a['id'] == accountId, orElse: () => _mockAccountList().first)) ?? 
              _mockAccountList().first as T,
        );
      }

      if (method == HttpMethod.put) {
        final account = _mockAccountList().firstWhere((a) => a['id'] == accountId, orElse: () => _mockAccountList().first);
        account.addAll(body ?? {});
        return ApiResponse.success(
          parser?.call(account) ?? account as T,
          message: 'Account updated',
        );
      }

      if (method == HttpMethod.delete) {
        return ApiResponse.success(
          parser?.call({'deleted': true}) ?? {'deleted': true} as T,
          message: 'Account deleted',
        );
      }
    }

    return ApiResponse.success(
      parser?.call(_mockAccountList()) ?? _mockAccountList() as T,
    );
  }

  List<Map<String, dynamic>> _mockAccountList() {
    return [
      {
        'id': 'acc_1',
        'userId': 'usr_1',
        'name': 'Bank BCA',
        'type': 'bank',
        'balance': 85000000,
        'currency': 'IDR',
        'icon': 'account_balance',
        'color': '#1E3A5F',
        'isActive': true,
        'includeInTotal': true,
        'cardLastDigits': '1234',
        'createdAt': DateTime.now().subtract(const Duration(days: 365)).toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      {
        'id': 'acc_2',
        'userId': 'usr_1',
        'name': 'OVO',
        'type': 'ewallet',
        'balance': 2500000,
        'currency': 'IDR',
        'icon': 'payment',
        'color': '#6B3FA0',
        'isActive': true,
        'includeInTotal': true,
        'createdAt': DateTime.now().subtract(const Duration(days: 180)).toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      {
        'id': 'acc_3',
        'userId': 'usr_1',
        'name': 'Tabungan Deposito',
        'type': 'savings',
        'balance': 70000000,
        'currency': 'IDR',
        'icon': 'savings',
        'color': '#10B981',
        'isActive': true,
        'includeInTotal': true,
        'createdAt': DateTime.now().subtract(const Duration(days: 90)).toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      {
        'id': 'acc_4',
        'userId': 'usr_1',
        'name': 'Tunai',
        'type': 'cash',
        'balance': 500000,
        'currency': 'IDR',
        'icon': 'wallet',
        'color': '#F59E0B',
        'isActive': true,
        'includeInTotal': true,
        'createdAt': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
    ];
  }

  // =========================================================================
  // TRANSACTIONS MOCK DATA
  // =========================================================================

  Future<ApiResponse<T>> _mockTransactions<T>(
    String endpoint,
    HttpMethod method,
    dynamic body,
    T Function(dynamic)? parser,
  ) async {
    if (endpoint == '/transactions' && method == HttpMethod.get) {
      return ApiResponse.success(
        parser?.call(_mockTransactionResponse()) ?? _mockTransactionResponse() as T,
      );
    }

    if (endpoint == '/transactions' && method == HttpMethod.post) {
      final newTransaction = _createTransactionFromBody(body);
      return ApiResponse.success(
        parser?.call(newTransaction) ?? newTransaction as T,
        message: 'Transaction created',
        statusCode: 201,
      );
    }

    // Single transaction operations
    final transactionId = _extractIdFromEndpoint(endpoint);
    if (transactionId != null) {
      if (method == HttpMethod.get) {
        return ApiResponse.success(
          parser?.call(_mockTransactionList(10).first) ?? _mockTransactionList(10).first as T,
        );
      }

      if (method == HttpMethod.put) {
        return ApiResponse.success(
          parser?.call(_createTransactionFromBody(body, id: transactionId)) ?? 
              _createTransactionFromBody(body, id: transactionId) as T,
          message: 'Transaction updated',
        );
      }

      if (method == HttpMethod.delete) {
        return ApiResponse.success(
          parser?.call({'deleted': true}) ?? {'deleted': true} as T,
          message: 'Transaction deleted',
        );
      }
    }

    return ApiResponse.success(
      parser?.call(_mockTransactionResponse()) ?? _mockTransactionResponse() as T,
    );
  }

  Map<String, dynamic> _createTransactionFromBody(dynamic body, {String? id}) {
    final now = DateTime.now();
    return {
      'id': id ?? 'txn_${now.millisecondsSinceEpoch}',
      'type': (body as Map)['type'] ?? 'expense',
      'amount': (body as Map)['amount'] ?? 0,
      'categoryId': (body as Map)['categoryId'] ?? 'cat_1',
      'accountId': (body as Map)['accountId'] ?? 'acc_1',
      'description': (body as Map)['description'] ?? '',
      'date': (body as Map)['date'] ?? '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
      'tags': (body as Map)['tags'] ?? [],
      'receiptUrl': null,
      'isRecurring': false,
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
    };
  }

  Map<String, dynamic> _mockTransactionResponse() {
    return {
      'data': _mockTransactionList(50),
      'meta': {
        'page': 1,
        'limit': 20,
        'total': 50,
        'totalPages': 3,
      },
    };
  }

  List<Map<String, dynamic>> _mockTransactionList(int count) {
    final categories = [
      {'id': 'cat_1', 'name': 'Makanan', 'icon': 'restaurant', 'color': '#EF4444'},
      {'id': 'cat_2', 'name': 'Transportasi', 'icon': 'car', 'color': '#F59E0B'},
      {'id': 'cat_3', 'name': 'Belanja', 'icon': 'shopping-bag', 'color': '#10B981'},
      {'id': 'cat_4', 'name': 'Hiburan', 'icon': 'film', 'color': '#8B5CF6'},
      {'id': 'cat_5', 'name': 'Kesehatan', 'icon': 'heart', 'color': '#EC4899'},
      {'id': 'cat_6', 'name': 'Gaji', 'icon': 'briefcase', 'color': '#10B981'},
      {'id': 'cat_7', 'name': 'Freelance', 'icon': 'laptop', 'color': '#F59E0B'},
    ];

    final transactions = <Map<String, dynamic>>[];
    final now = DateTime.now();

    for (int i = 0; i < count; i++) {
      final date = now.subtract(Duration(days: i ~/ 2, hours: i % 24));
      final isIncome = i % 7 == 0;
      final category = isIncome 
          ? categories[5 + (i % 2)]
          : categories[i % 5];
      
      transactions.add({
        'id': 'txn_${now.millisecondsSinceEpoch - i * 1000}',
        'type': isIncome ? 'income' : 'expense',
        'amount': isIncome 
            ? (i % 3 == 0 ? 15000000.0 : 500000.0)
            : (50000.0 + (i * 10000) % 500000),
        'category': category,
        'categoryId': category['id'],
        'accountId': 'acc_${(i % 3) + 1}',
        'accountName': ['Bank BCA', 'OVO', 'Tabungan Deposito'][(i % 3)],
        'description': isIncome 
            ? 'Pembayaran Freelance Project ${i + 1}'
            : 'Pembelian ${category['name']} #${i + 1}',
        'date': '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
        'time': '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:00',
        'tags': i % 3 == 0 ? ['重要'] : [],
        'receiptUrl': null,
        'isRecurring': false,
        'createdAt': date.toIso8601String(),
        'updatedAt': date.toIso8601String(),
      });
    }

    return transactions;
  }

  // =========================================================================
  // CATEGORIES MOCK DATA
  // =========================================================================

  Future<ApiResponse<T>> _mockCategories<T>(
    String endpoint,
    T Function(dynamic)? parser,
  ) async {
    return ApiResponse.success(
      parser?.call(_mockCategoryList()) ?? _mockCategoryList() as T,
    );
  }

  List<Map<String, dynamic>> _mockCategoryList() {
    return [
      // Expense categories
      {'id': 'cat_1', 'name': 'Makanan', 'type': 'expense', 'icon': 'restaurant', 'color': '#EF4444', 'isSystem': true},
      {'id': 'cat_2', 'name': 'Transportasi', 'type': 'expense', 'icon': 'car', 'color': '#F59E0B', 'isSystem': true},
      {'id': 'cat_3', 'name': 'Belanja', 'type': 'expense', 'icon': 'shopping-bag', 'color': '#10B981', 'isSystem': true},
      {'id': 'cat_4', 'name': 'Hiburan', 'type': 'expense', 'icon': 'film', 'color': '#8B5CF6', 'isSystem': true},
      {'id': 'cat_5', 'name': 'Kesehatan', 'type': 'expense', 'icon': 'heart', 'color': '#EC4899', 'isSystem': true},
      {'id': 'cat_6', 'name': 'Pendidikan', 'type': 'expense', 'icon': 'book', 'color': '#06B6D4', 'isSystem': true},
      {'id': 'cat_7', 'name': 'Tagihan', 'type': 'expense', 'icon': 'file-text', 'color': '#6366F1', 'isSystem': true},
      {'id': 'cat_8', 'name': 'Lainnya', 'type': 'expense', 'icon': 'more-horizontal', 'color': '#94A3B8', 'isSystem': true},
      // Income categories
      {'id': 'cat_9', 'name': 'Gaji', 'type': 'income', 'icon': 'briefcase', 'color': '#10B981', 'isSystem': true},
      {'id': 'cat_10', 'name': 'Freelance', 'type': 'income', 'icon': 'laptop', 'color': '#F59E0B', 'isSystem': true},
      {'id': 'cat_11', 'name': 'Investasi', 'type': 'income', 'icon': 'trending-up', 'color': '#6366F1', 'isSystem': true},
      {'id': 'cat_12', 'name': 'Hadiah', 'type': 'income', 'icon': 'gift', 'color': '#EC4899', 'isSystem': true},
      {'id': 'cat_13', 'name': 'Lainnya', 'type': 'income', 'icon': 'plus-circle', 'color': '#94A3B8', 'isSystem': true},
    ];
  }

  // =========================================================================
  // GOALS MOCK DATA
  // =========================================================================

  Future<ApiResponse<T>> _mockGoals<T>(
    String endpoint,
    HttpMethod method,
    dynamic body,
    T Function(dynamic)? parser,
  ) async {
    if (endpoint == '/goals' && method == HttpMethod.get) {
      return ApiResponse.success(
        parser?.call(_mockGoalsList()) ?? _mockGoalsList() as T,
      );
    }

    if (endpoint == '/goals' && method == HttpMethod.post) {
      final newGoal = _createGoalFromBody(body);
      return ApiResponse.success(
        parser?.call(newGoal) ?? newGoal as T,
        message: 'Goal created',
        statusCode: 201,
      );
    }

    // Single goal operations
    final goalId = _extractIdFromEndpoint(endpoint);
    if (goalId != null) {
      if (endpoint.contains('/contribute')) {
        // Add contribution
        final goal = _mockGoalsList().firstWhere((g) => g['id'] == goalId, orElse: () => _mockGoalsList().first);
        final contribution = {
          'id': 'contrib_${DateTime.now().millisecondsSinceEpoch}',
          'amount': (body as Map)['amount'] ?? 0,
          'date': DateTime.now().toIso8601String(),
          'note': (body as Map)['note'] ?? '',
        };
        goal['currentAmount'] = (goal['currentAmount'] as num) + contribution['amount'];
        goal['contributions'] = [...(goal['contributions'] as List), contribution];
        return ApiResponse.success(
          parser?.call(goal) ?? goal as T,
          message: 'Contribution added',
        );
      }

      if (method == HttpMethod.get) {
        return ApiResponse.success(
          parser?.call(_mockGoalsList().first) ?? _mockGoalsList().first as T,
        );
      }

      if (method == HttpMethod.put) {
        return ApiResponse.success(
          parser?.call(_createGoalFromBody(body, id: goalId)) ?? 
              _createGoalFromBody(body, id: goalId) as T,
          message: 'Goal updated',
        );
      }

      if (method == HttpMethod.delete) {
        return ApiResponse.success(
          parser?.call({'deleted': true}) ?? {'deleted': true} as T,
          message: 'Goal deleted',
        );
      }
    }

    return ApiResponse.success(
      parser?.call(_mockGoalsList()) ?? _mockGoalsList() as T,
    );
  }

  Map<String, dynamic> _createGoalFromBody(dynamic body, {String? id}) {
    final now = DateTime.now();
    return {
      'id': id ?? 'goal_${now.millisecondsSinceEpoch}',
      'name': (body as Map)['name'] ?? 'New Goal',
      'targetAmount': (body as Map)['targetAmount'] ?? 0,
      'currentAmount': (body as Map)['currentAmount'] ?? 0,
      'deadline': (body as Map)['deadline'] ?? 
          DateTime(now.year + 1, now.month, now.day).toIso8601String(),
      'icon': (body as Map)['icon'] ?? 'target',
      'color': (body as Map)['color'] ?? '#6366F1',
      'priority': (body as Map)['priority'] ?? 1,
      'status': 'active',
      'contributions': [],
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
    };
  }

  List<Map<String, dynamic>> _mockGoalsList() {
    return [
      {
        'id': 'goal_1',
        'name': 'Dana Liburan',
        'targetAmount': 10000000,
        'currentAmount': 7300000,
        'deadline': '2024-12-31',
        'icon': 'flight',
        'color': '#4CAF50',
        'priority': 1,
        'status': 'in_progress',
        'progress': 73,
        'contributions': [
          {'id': 'c1', 'amount': 1000000, 'date': '2024-01-10', 'note': 'Tabungan bulan Jan'},
          {'id': 'c2', 'amount': 1000000, 'date': '2024-02-10', 'note': 'Tabungan bulan Feb'},
          {'id': 'c3', 'amount': 1500000, 'date': '2024-03-10', 'note': 'Bonus'},
          {'id': 'c4', 'amount': 1000000, 'date': '2024-04-10', 'note': 'Tabungan bulan Apr'},
          {'id': 'c5', 'amount': 1000000, 'date': '2024-05-10', 'note': 'Tabungan bulan Mei'},
          {'id': 'c6', 'amount': 800000, 'date': '2024-06-10', 'note': 'Tabungan bulan Jun'},
          {'id': 'c7', 'amount': 1000000, 'date': '2024-07-10', 'note': 'Tabungan bulan Jul'},
        ],
        'createdAt': DateTime.now().subtract(const Duration(days: 200)).toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      {
        'id': 'goal_2',
        'name': 'Dana Darurat',
        'targetAmount': 30000000,
        'currentAmount': 15000000,
        'deadline': '2024-06-30',
        'icon': 'shield',
        'color': '#2196F3',
        'priority': 2,
        'status': 'in_progress',
        'progress': 50,
        'contributions': [
          {'id': 'c1', 'amount': 3000000, 'date': '2024-01-15', 'note': 'Initial deposit'},
          {'id': 'c2', 'amount': 2000000, 'date': '2024-02-15', 'note': 'Tabungan Feb'},
          {'id': 'c3', 'amount': 2000000, 'date': '2024-03-15', 'note': 'Tabungan Mar'},
          {'id': 'c4', 'amount': 2000000, 'date': '2024-04-15', 'note': 'Tabungan Apr'},
          {'id': 'c5', 'amount': 2000000, 'date': '2024-05-15', 'note': 'Tabungan Mei'},
          {'id': 'c6', 'amount': 2000000, 'date': '2024-06-15', 'note': 'Tabungan Jun'},
          {'id': 'c7', 'amount': 2000000, 'date': '2024-07-15', 'note': 'Tabungan Jul'},
        ],
        'createdAt': DateTime.now().subtract(const Duration(days: 180)).toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      {
        'id': 'goal_3',
        'name': 'iPhone Baru',
        'targetAmount': 15000000,
        'currentAmount': 15000000,
        'deadline': '2024-09-01',
        'icon': 'smartphone',
        'color': '#9C27B0',
        'priority': 3,
        'status': 'achieved',
        'progress': 100,
        'contributions': [
          {'id': 'c1', 'amount': 5000000, 'date': '2024-03-01', 'note': 'Initial'},
          {'id': 'c2', 'amount': 5000000, 'date': '2024-05-01', 'note': 'Saving'},
          {'id': 'c3', 'amount': 5000000, 'date': '2024-07-01', 'note': 'Final'},
        ],
        'createdAt': DateTime.now().subtract(const Duration(days: 120)).toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      {
        'id': 'goal_4',
        'name': 'Upgrade Laptop',
        'targetAmount': 25000000,
        'currentAmount': 5000000,
        'deadline': '2025-01-01',
        'icon': 'laptop',
        'color': '#FF5722',
        'priority': 4,
        'status': 'in_progress',
        'progress': 20,
        'contributions': [
          {'id': 'c1', 'amount': 5000000, 'date': '2024-06-01', 'note': 'Initial deposit'},
        ],
        'createdAt': DateTime.now().subtract(const Duration(days: 60)).toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
    ];
  }

  // =========================================================================
  // PORTFOLIO MOCK DATA
  // =========================================================================

  Future<ApiResponse<T>> _mockPortfolio<T>(
    String endpoint,
    HttpMethod method,
    dynamic body,
    T Function(dynamic)? parser,
  ) async {
    if (endpoint == '/portfolio' && method == HttpMethod.get) {
      return ApiResponse.success(
        parser?.call(_mockPortfolioSummary()) ?? _mockPortfolioSummary() as T,
      );
    }

    if (endpoint == '/portfolio/holdings') {
      if (method == HttpMethod.get) {
        return ApiResponse.success(
          parser?.call(_mockHoldingsList()) ?? _mockHoldingsList() as T,
        );
      }
      if (method == HttpMethod.post) {
        final newHolding = _createHoldingFromBody(body);
        return ApiResponse.success(
          parser?.call(newHolding) ?? newHolding as T,
          message: 'Holding added',
          statusCode: 201,
        );
      }
    }

    // Single holding operations
    final holdingId = _extractIdFromEndpoint(endpoint);
    if (holdingId != null) {
      if (method == HttpMethod.get) {
        return ApiResponse.success(
          parser?.call(_mockHoldingsList().first) ?? _mockHoldingsList().first as T,
        );
      }

      if (method == HttpMethod.put) {
        return ApiResponse.success(
          parser?.call(_createHoldingFromBody(body, id: holdingId)) ?? 
              _createHoldingFromBody(body, id: holdingId) as T,
          message: 'Holding updated',
        );
      }

      if (method == HttpMethod.delete) {
        return ApiResponse.success(
          parser?.call({'deleted': true}) ?? {'deleted': true} as T,
          message: 'Holding removed',
        );
      }

      // Buy/Sell operations
      if (endpoint.contains('/buy')) {
        return ApiResponse.success(
          parser?.call(_createHoldingFromBody(body, id: holdingId)) ?? 
              _createHoldingFromBody(body, id: holdingId) as T,
          message: 'Purchase recorded',
        );
      }

      if (endpoint.contains('/sell')) {
        return ApiResponse.success(
          parser?.call(_createHoldingFromBody(body, id: holdingId)) ?? 
              _createHoldingFromBody(body, id: holdingId) as T,
          message: 'Sale recorded',
        );
      }
    }

    if (endpoint == '/portfolio/summary') {
      return ApiResponse.success(
        parser?.call(_mockPortfolioSummary()) ?? _mockPortfolioSummary() as T,
      );
    }

    if (endpoint == '/portfolio/performance') {
      return ApiResponse.success(
        parser?.call(_mockPortfolioPerformance()) ?? _mockPortfolioPerformance() as T,
      );
    }

    return ApiResponse.success(
      parser?.call(_mockPortfolioSummary()) ?? _mockPortfolioSummary() as T,
    );
  }

  Map<String, dynamic> _createHoldingFromBody(dynamic body, {String? id}) {
    final now = DateTime.now();
    return {
      'id': id ?? 'hold_${now.millisecondsSinceEpoch}',
      'symbol': (body as Map)['symbol'] ?? 'UNKNOWN',
      'companyName': (body as Map)['companyName'] ?? 'Unknown Company',
      'shares': (body as Map)['shares'] ?? 0,
      'averagePrice': (body as Map)['averagePrice'] ?? 0,
      'currentPrice': (body as Map)['currentPrice'] ?? (body as Map)['averagePrice'] ?? 0,
      'sector': (body as Map)['sector'] ?? 'Miscellaneous',
      'exchange': (body as Map)['exchange'] ?? 'IDX',
      'lastUpdated': now.toIso8601String(),
      'createdAt': now.toIso8601String(),
    };
  }

  Map<String, dynamic> _mockPortfolioSummary() {
    return {
      'totalInvested': 68000000,
      'currentValue': 75000000,
      'totalProfitLoss': 7000000,
      'totalProfitLossPercent': 10.29,
      'dayChange': 350000,
      'dayChangePercent': 0.47,
      'bestPerformer': {
        'symbol': 'AMMN',
        'companyName': 'Ammann Mineral',
        'profitLossPercent': 25.5,
      },
      'worstPerformer': {
        'symbol': 'TLKM',
        'companyName': 'Telkom Indonesia',
        'profitLossPercent': -3.2,
      },
      'sectorAllocation': [
        {'sector': 'Financial', 'percentage': 45, 'value': 33750000},
        {'sector': 'Technology', 'percentage': 25, 'value': 18750000},
        {'sector': 'Consumer', 'percentage': 20, 'value': 15000000},
        {'sector': 'Mining', 'percentage': 10, 'value': 7500000},
      ],
      'holdings': _mockHoldingsList(),
    };
  }

  List<Map<String, dynamic>> _mockHoldingsList() {
    return [
      {
        'id': 'hold_1',
        'symbol': 'BBCA.JK',
        'companyName': 'Bank Central Asia',
        'shares': 200,
        'averagePrice': 8500,
        'currentPrice': 9200,
        'totalInvested': 1700000,
        'currentValue': 1840000,
        'profitLoss': 140000,
        'profitLossPercent': 8.24,
        'sector': 'Financial',
        'exchange': 'IDX',
        'lastUpdated': DateTime.now().toIso8601String(),
        'createdAt': DateTime.now().subtract(const Duration(days: 300)).toIso8601String(),
      },
      {
        'id': 'hold_2',
        'symbol': 'BBRI.JK',
        'companyName': 'Bank Rakyat Indonesia',
        'shares': 500,
        'averagePrice': 4800,
        'currentPrice': 5100,
        'totalInvested': 2400000,
        'currentValue': 2550000,
        'profitLoss': 150000,
        'profitLossPercent': 6.25,
        'sector': 'Financial',
        'exchange': 'IDX',
        'lastUpdated': DateTime.now().toIso8601String(),
        'createdAt': DateTime.now().subtract(const Duration(days: 250)).toIso8601String(),
      },
      {
        'id': 'hold_3',
        'symbol': 'BMRI.JK',
        'companyName': 'Bank Mandiri',
        'shares': 300,
        'averagePrice': 5200,
        'currentPrice': 5500,
        'totalInvested': 1560000,
        'currentValue': 1650000,
        'profitLoss': 90000,
        'profitLossPercent': 5.77,
        'sector': 'Financial',
        'exchange': 'IDX',
        'lastUpdated': DateTime.now().toIso8601String(),
        'createdAt': DateTime.now().subtract(const Duration(days: 200)).toIso8601String(),
      },
      {
        'id': 'hold_4',
        'symbol': 'GOTO.JK',
        'companyName': 'GoTo Gojek Tokopedia',
        'shares': 10000,
        'averagePrice': 88,
        'currentPrice': 72,
        'totalInvested': 880000,
        'currentValue': 720000,
        'profitLoss': -160000,
        'profitLossPercent': -18.18,
        'sector': 'Technology',
        'exchange': 'IDX',
        'lastUpdated': DateTime.now().toIso8601String(),
        'createdAt': DateTime.now().subtract(const Duration(days: 180)).toIso8601String(),
      },
      {
        'id': 'hold_5',
        'symbol': 'AMMN.JK',
        'companyName': 'Ammann Mineral Internasional',
        'shares': 100,
        'averagePrice': 12500,
        'currentPrice': 15675,
        'totalInvested': 1250000,
        'currentValue': 1567500,
        'profitLoss': 317500,
        'profitLossPercent': 25.4,
        'sector': 'Mining',
        'exchange': 'IDX',
        'lastUpdated': DateTime.now().toIso8601String(),
        'createdAt': DateTime.now().subtract(const Duration(days: 90)).toIso8601String(),
      },
      {
        'id': 'hold_6',
        'symbol': 'TLKM.JK',
        'companyName': 'Telekomunikasi Indonesia',
        'shares': 400,
        'averagePrice': 3100,
        'currentPrice': 3000,
        'totalInvested': 1240000,
        'currentValue': 1200000,
        'profitLoss': -40000,
        'profitLossPercent': -3.23,
        'sector': 'Technology',
        'exchange': 'IDX',
        'lastUpdated': DateTime.now().toIso8601String(),
        'createdAt': DateTime.now().subtract(const Duration(days: 150)).toIso8601String(),
      },
      {
        'id': 'hold_7',
        'symbol': 'UNVR.JK',
        'companyName': 'Unilever Indonesia',
        'shares': 200,
        'averagePrice': 4100,
        'currentPrice': 3950,
        'totalInvested': 820000,
        'currentValue': 790000,
        'profitLoss': -30000,
        'profitLossPercent': -3.66,
        'sector': 'Consumer',
        'exchange': 'IDX',
        'lastUpdated': DateTime.now().toIso8601String(),
        'createdAt': DateTime.now().subtract(const Duration(days: 120)).toIso8601String(),
      },
      {
        'id': 'hold_8',
        'symbol': 'HMSP.JK',
        'companyName': 'Hanjaya Mandala Sampoerna',
        'shares': 300,
        'averagePrice': 980,
        'currentPrice': 1050,
        'totalInvested': 294000,
        'currentValue': 315000,
        'profitLoss': 21000,
        'profitLossPercent': 7.14,
        'sector': 'Consumer',
        'exchange': 'IDX',
        'lastUpdated': DateTime.now().toIso8601String(),
        'createdAt': DateTime.now().subtract(const Duration(days: 100)).toIso8601String(),
      },
    ];
  }

  Map<String, dynamic> _mockPortfolioPerformance() {
    final history = <Map<String, dynamic>>[];
    final now = DateTime.now();
    double portfolioValue = 60000000;
    
    for (int i = 29; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      portfolioValue += (i % 3 == 0 ? 500000 : -200000) + (portfolioValue * 0.001);
      history.add({
        'date': '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
        'value': portfolioValue.round(),
        'change': i % 3 == 0 ? 500000 : -200000,
      });
    }

    return {
      'data': history,
      'totalReturn': 7000000,
      'totalReturnPercent': 10.29,
      'monthlyReturn': 2.5,
      'yearlyReturn': 25.3,
      'bestDay': {'date': '2024-07-15', 'change': 1500000, 'changePercent': 2.1},
      'worstDay': {'date': '2024-07-10', 'change': -800000, 'changePercent': -1.1},
    };
  }

  // =========================================================================
  // WATCHLIST MOCK DATA
  // =========================================================================

  Future<ApiResponse<T>> _mockWatchlist<T>(
    String endpoint,
    HttpMethod method,
    dynamic body,
    T Function(dynamic)? parser,
  ) async {
    if (endpoint == '/watchlist' && method == HttpMethod.get) {
      return ApiResponse.success(
        parser?.call(_mockWatchlistItems()) ?? _mockWatchlistItems() as T,
      );
    }

    if (endpoint == '/watchlist' && method == HttpMethod.post) {
      final newItem = {
        'id': 'watch_${DateTime.now().millisecondsSinceEpoch}',
        'symbol': (body as Map)['symbol'] ?? 'UNKNOWN',
        'companyName': (body as Map)['companyName'] ?? 'Unknown',
        'lastPrice': (body as Map)['lastPrice'] ?? 0,
        'targetPrice': (body as Map)['targetPrice'],
        'createdAt': DateTime.now().toIso8601String(),
      };
      return ApiResponse.success(
        parser?.call(newItem) ?? newItem as T,
        message: 'Added to watchlist',
        statusCode: 201,
      );
    }

    // Delete watchlist item
    final symbol = endpoint.split('/').last;
    if (symbol.isNotEmpty && method == HttpMethod.delete) {
      return ApiResponse.success(
        parser?.call({'deleted': true}) ?? {'deleted': true} as T,
        message: 'Removed from watchlist',
      );
    }

    return ApiResponse.success(
      parser?.call(_mockWatchlistItems()) ?? _mockWatchlistItems() as T,
    );
  }

  List<Map<String, dynamic>> _mockWatchlistItems() {
    return [
      {
        'id': 'watch_1',
        'symbol': 'BREN.JK',
        'companyName': 'Barito Renewables',
        'lastPrice': 13250,
        'change': 450,
        'changePercent': 3.52,
        'volume': 2500000,
        'marketCap': '250T',
        'targetPrice': 15000,
        'alertEnabled': true,
        'createdAt': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
      },
      {
        'id': 'watch_2',
        'symbol': 'CUAN.JK',
        'companyName': 'Petrokimia Gresik',
        'lastPrice': 8950,
        'change': -150,
        'changePercent': -1.65,
        'volume': 1200000,
        'marketCap': '65T',
        'targetPrice': 9500,
        'alertEnabled': true,
        'createdAt': DateTime.now().subtract(const Duration(days: 20)).toIso8601String(),
      },
      {
        'id': 'watch_3',
        'symbol': 'EXCL.JK',
        'companyName': 'XL Axiata',
        'lastPrice': 2850,
        'change': 25,
        'changePercent': 0.88,
        'volume': 800000,
        'marketCap': '35T',
        'targetPrice': 3000,
        'alertEnabled': false,
        'createdAt': DateTime.now().subtract(const Duration(days: 15)).toIso8601String(),
      },
    ];
  }

  // =========================================================================
  // STATISTICS MOCK DATA
  // =========================================================================

  Future<ApiResponse<T>> _mockStatistics<T>(
    String endpoint,
    T Function(dynamic)? parser,
  ) async {
    if (endpoint == '/stats/spending') {
      return ApiResponse.success(
        parser?.call(_mockSpendingStats()) ?? _mockSpendingStats() as T,
      );
    }

    if (endpoint == '/stats/income') {
      return ApiResponse.success(
        parser?.call(_mockIncomeStats()) ?? _mockIncomeStats() as T,
      );
    }

    if (endpoint == '/stats/categories') {
      return ApiResponse.success(
        parser?.call(_mockCategoryStats()) ?? _mockCategoryStats() as T,
      );
    }

    if (endpoint == '/stats/cashflow') {
      return ApiResponse.success(
        parser?.call(_mockCashflowStats()) ?? _mockCashflowStats() as T,
      );
    }

    if (endpoint == '/stats/assets') {
      return ApiResponse.success(
        parser?.call(_mockAssetStats()) ?? _mockAssetStats() as T,
      );
    }

    if (endpoint == '/stats/investments') {
      return ApiResponse.success(
        parser?.call(_mockInvestmentStats()) ?? _mockInvestmentStats() as T,
      );
    }

    return ApiResponse.success(
      parser?.call(_mockSpendingStats()) ?? _mockSpendingStats() as T,
    );
  }

  Map<String, dynamic> _mockSpendingStats() {
    return {
      'totalSpending': 8500000,
      'transactionCount': 45,
      'averageTransaction': 188888,
      'byCategory': [
        {'categoryId': 'cat_1', 'categoryName': 'Makanan', 'icon': 'restaurant', 'color': '#EF4444', 'total': 2500000, 'percentage': 29.4, 'transactionCount': 15},
        {'categoryId': 'cat_2', 'categoryName': 'Transportasi', 'icon': 'car', 'color': '#F59E0B', 'total': 1500000, 'percentage': 17.6, 'transactionCount': 10},
        {'categoryId': 'cat_3', 'categoryName': 'Belanja', 'icon': 'shopping-bag', 'color': '#10B981', 'total': 2000000, 'percentage': 23.5, 'transactionCount': 8},
        {'categoryId': 'cat_4', 'categoryName': 'Hiburan', 'icon': 'film', 'color': '#8B5CF6', 'total': 1000000, 'percentage': 11.8, 'transactionCount': 6},
        {'categoryId': 'cat_5', 'categoryName': 'Kesehatan', 'icon': 'heart', 'color': '#EC4899', 'total': 500000, 'percentage': 5.9, 'transactionCount': 3},
        {'categoryId': 'cat_7', 'categoryName': 'Tagihan', 'icon': 'file-text', 'color': '#6366F1', 'total': 1000000, 'percentage': 11.8, 'transactionCount': 3},
      ],
      'byDay': [
        {'date': '2024-07-01', 'total': 350000},
        {'date': '2024-07-02', 'total': 450000},
        {'date': '2024-07-03', 'total': 280000},
        {'date': '2024-07-04', 'total': 520000},
        {'date': '2024-07-05', 'total': 380000},
      ],
    };
  }

  Map<String, dynamic> _mockIncomeStats() {
    return {
      'totalIncome': 15000000,
      'transactionCount': 5,
      'averageTransaction': 3000000,
      'byCategory': [
        {'categoryId': 'cat_9', 'categoryName': 'Gaji', 'icon': 'briefcase', 'color': '#10B981', 'total': 12000000, 'percentage': 80, 'transactionCount': 1},
        {'categoryId': 'cat_10', 'categoryName': 'Freelance', 'icon': 'laptop', 'color': '#F59E0B', 'total': 3000000, 'percentage': 20, 'transactionCount': 4},
      ],
      'byDay': [
        {'date': '2024-07-01', 'total': 12000000},
        {'date': '2024-07-10', 'total': 1000000},
        {'date': '2024-07-15', 'total': 800000},
        {'date': '2024-07-20', 'total': 700000},
        {'date': '2024-07-25', 'total': 500000},
      ],
    };
  }

  Map<String, dynamic> _mockCategoryStats() {
    return {
      'expenseCategories': [
        {'categoryId': 'cat_1', 'categoryName': 'Makanan', 'total': 2500000, 'percentage': 29.4, 'trend': 5.2},
        {'categoryId': 'cat_2', 'categoryName': 'Transportasi', 'total': 1500000, 'percentage': 17.6, 'trend': -2.1},
        {'categoryId': 'cat_3', 'categoryName': 'Belanja', 'total': 2000000, 'percentage': 23.5, 'trend': 12.3},
        {'categoryId': 'cat_4', 'categoryName': 'Hiburan', 'total': 1000000, 'percentage': 11.8, 'trend': -8.5},
        {'categoryId': 'cat_5', 'categoryName': 'Kesehatan', 'total': 500000, 'percentage': 5.9, 'trend': 0},
        {'categoryId': 'cat_7', 'categoryName': 'Tagihan', 'total': 1000000, 'percentage': 11.8, 'trend': 3.2},
      ],
      'incomeCategories': [
        {'categoryId': 'cat_9', 'categoryName': 'Gaji', 'total': 12000000, 'percentage': 80, 'trend': 0},
        {'categoryId': 'cat_10', 'categoryName': 'Freelance', 'total': 3000000, 'percentage': 20, 'trend': 15},
      ],
    };
  }

  Map<String, dynamic> _mockCashflowStats() {
    return {
      'totalIncome': 15000000,
      'totalSpending': 8500000,
      'netCashflow': 6500000,
      'savingsRate': 43.3,
      'byMonth': [
        {'month': '2024-01', 'income': 12000000, 'spending': 9000000, 'net': 3000000},
        {'month': '2024-02', 'income': 12000000, 'spending': 8500000, 'net': 3500000},
        {'month': '2024-03', 'income': 13500000, 'spending': 9200000, 'net': 4300000},
        {'month': '2024-04', 'income': 12000000, 'spending': 8800000, 'net': 3200000},
        {'month': '2024-05', 'income': 12000000, 'spending': 8000000, 'net': 4000000},
        {'month': '2024-06', 'income': 15000000, 'spending': 8500000, 'net': 6500000},
      ],
      'projectedSavings': 78000000,
    };
  }

  Map<String, dynamic> _mockAssetStats() {
    return {
      'totalAssets': 158000000,
      'totalLiabilities': 0,
      'netWorth': 158000000,
      'assetAllocation': {
        'cash': 500000,
        'bankAccounts': 85000000,
        'savings': 70000000,
        'investments': 2500000,
      },
      'changePercentage': 8.5,
      'history': [
        {'date': '2024-01-01', 'netWorth': 120000000},
        {'date': '2024-02-01', 'netWorth': 125000000},
        {'date': '2024-03-01', 'netWorth': 132000000},
        {'date': '2024-04-01', 'netWorth': 138000000},
        {'date': '2024-05-01', 'netWorth': 145000000},
        {'date': '2024-06-01', 'netWorth': 152000000},
        {'date': '2024-07-01', 'netWorth': 158000000},
      ],
    };
  }

  Map<String, dynamic> _mockInvestmentStats() {
    return {
      'totalPortfolioValue': 75000000,
      'totalInvested': 68000000,
      'totalGainLoss': 7000000,
      'totalReturnPercentage': 10.29,
      'dayChange': 350000,
      'dayChangePercentage': 0.47,
      'bestPerformer': {'symbol': 'AMMN', 'returnPercentage': 25.4},
      'worstPerformer': {'symbol': 'GOTO', 'returnPercentage': -18.18},
      'allocation': [
        {'symbol': 'BBCA', 'shares': 200, 'value': 1840000, 'percentage': 2.45},
        {'symbol': 'BBRI', 'shares': 500, 'value': 2550000, 'percentage': 3.4},
        {'symbol': 'BMRI', 'shares': 300, 'value': 1650000, 'percentage': 2.2},
        {'symbol': 'GOTO', 'shares': 10000, 'value': 720000, 'percentage': 0.96},
        {'symbol': 'AMMN', 'shares': 100, 'value': 1567500, 'percentage': 2.09},
        {'symbol': 'TLKM', 'shares': 400, 'value': 1200000, 'percentage': 1.6},
        {'symbol': 'UNVR', 'shares': 200, 'value': 790000, 'percentage': 1.05},
        {'symbol': 'HMSP', 'shares': 300, 'value': 315000, 'percentage': 0.42},
      ],
    };
  }

  // =========================================================================
  // USER MOCK DATA
  // =========================================================================

  Future<ApiResponse<T>> _mockUser<T>(
    String endpoint,
    HttpMethod method,
    dynamic body,
    T Function(dynamic)? parser,
  ) async {
    if (endpoint == '/users/profile') {
      if (method == HttpMethod.get) {
        return ApiResponse.success(
          parser?.call(_generateMockUser()) ?? _generateMockUser() as T,
        );
      }
      if (method == HttpMethod.put) {
        return ApiResponse.success(
          parser?.call({..._generateMockUser(), ...(body as Map? ?? {})}) ?? 
              {..._generateMockUser(), ...(body as Map? ?? {})} as T,
          message: 'Profile updated',
        );
      }
    }

    if (endpoint == '/users/settings') {
      if (method == HttpMethod.get) {
        return ApiResponse.success(
          parser?.call(_mockUserSettings()) ?? _mockUserSettings() as T,
        );
      }
      if (method == HttpMethod.put) {
        return ApiResponse.success(
          parser?.call({..._mockUserSettings(), ...(body as Map? ?? {})}) ?? 
              {..._mockUserSettings(), ...(body as Map? ?? {})} as T,
          message: 'Settings updated',
        );
      }
    }

    return ApiResponse.success(
      parser?.call(_generateMockUser()) ?? _generateMockUser() as T,
    );
  }

  Map<String, dynamic> _mockUserSettings() {
    return {
      'theme': 'light',
      'notifications': {
        'dailyReminder': true,
        'reminderTime': '20:00',
        'transactionAlerts': true,
        'portfolioAlerts': true,
        'savingsMilestones': true,
      },
      'security': {
        'biometricEnabled': false,
        'pinEnabled': false,
      },
      'display': {
        'currencySymbol': 'Rp',
        'dateFormat': 'DD/MM/YYYY',
        'startOfWeek': 'monday',
      },
      'sync': {
        'autoSync': true,
        'syncFrequency': 'realtime',
      },
    };
  }

  // =========================================================================
  // UTILITY METHODS
  // =========================================================================

  /// Extract ID from endpoint
  String? _extractIdFromEndpoint(String endpoint) {
    final parts = endpoint.split('/');
    if (parts.length > 2 && parts[2].isNotEmpty) {
      return parts[2];
    }
    return null;
  }

  /// Upload file
  Future<ApiResponse<Map<String, dynamic>>> uploadFile(
    String endpoint, {
    required String filePath,
    required String fieldName,
    Map<String, String>? additionalFields,
    Map<String, String>? headers,
  }) async {
    if (_useMockData || !_isOnline) {
      await Future.delayed(const Duration(seconds: 1));
      return ApiResponse.success({
        'url': 'https://mock-storage.fintrack.app/uploads/${DateTime.now().millisecondsSinceEpoch}.jpg',
        'thumbnailUrl': 'https://mock-storage.fintrack.app/thumbnails/${DateTime.now().millisecondsSinceEpoch}.jpg',
      });
    }

    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      final request = http.MultipartRequest('POST', uri);
      
      // Add headers
      request.headers.addAll({
        'Accept': 'application/json',
        'X-Client-Version': '1.0.0',
      });
      
      // Add auth header
      if (_accessToken != null) {
        request.headers['Authorization'] = 'Bearer $_accessToken';
      }
      
      // Add custom headers
      if (headers != null) {
        request.headers.addAll(headers);
      }
      
      // Add file
      request.files.add(await http.MultipartFile.fromPath(fieldName, filePath));
      
      // Add additional fields
      if (additionalFields != null) {
        request.fields.addAll(additionalFields);
      }
      
      final streamedResponse = await request.send().timeout(
        const Duration(minutes: 5),
      );
      final response = await http.Response.fromStream(streamedResponse);
      
      return _handleResponse<Map<String, dynamic>>(response, (data) => data);
    } catch (e) {
      _logger.error('Upload error: $e');
      return ApiResponse.error(
        ApiError(code: 'UPLOAD_ERROR', message: e.toString()),
      );
    }
  }

  /// Download file
  Future<ApiResponse<Uint8List>> downloadFile(String url) async {
    try {
      final response = await _client.get(
        Uri.parse(url),
        headers: {'Authorization': _accessToken != null ? 'Bearer $_accessToken' : ''},
      ).timeout(const Duration(minutes: 5));

      if (response.statusCode == 200) {
        return ApiResponse.success(
          response.bodyBytes,
          statusCode: 200,
        );
      }

      return ApiResponse.error(
        ApiError(code: 'DOWNLOAD_ERROR', message: 'Failed to download file'),
        statusCode: response.statusCode,
      );
    } catch (e) {
      _logger.error('Download error: $e');
      return ApiResponse.error(
        ApiError(code: 'DOWNLOAD_ERROR', message: e.toString()),
      );
    }
  }

  /// Cancel all pending requests
  void cancelAllRequests() {
    _client.close();
    _client = http.Client();
    _logger.info('All requests cancelled');
  }

  /// Dispose the service
  void dispose() {
    _client.close();
    _instance = null;
    _logger.info('API Service disposed');
  }
}

// ============================================================================
// API SERVICE EXTENSION FOR TYPED REQUESTS
// ============================================================================

extension TypedApiService on ApiService {
  // Auth API
  Future<ApiResponse<Map<String, dynamic>>> login(String email, String password) async {
    return post<Map<String, dynamic>>(
      '/auth/login',
      body: {'email': email, 'password': password},
      parser: (data) => data as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> register({
    required String email,
    required String password,
    required String fullName,
    String? currency,
    String? timezone,
  }) async {
    return post<Map<String, dynamic>>(
      '/auth/register',
      body: {
        'email': email,
        'password': password,
        'fullName': fullName,
        if (currency != null) 'currency': currency,
        if (timezone != null) 'timezone': timezone,
      },
      parser: (data) => data as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> loginWithGoogle(String idToken) async {
    return post<Map<String, dynamic>>(
      '/auth/google',
      body: {'idToken': idToken},
      parser: (data) => data as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<bool>> logout() async {
    return post<bool>(
      '/auth/logout',
      parser: (_) => true,
    );
  }

  // Dashboard API
  Future<ApiResponse<Map<String, dynamic>>> getDashboardSummary() async {
    return get<Map<String, dynamic>>(
      '/dashboard/summary',
      parser: (data) => data as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> getCashflow({String? period}) async {
    return get<Map<String, dynamic>>(
      '/dashboard/cashflow',
      options: RequestOptions(
        queryParams: period != null ? {'period': period} : null,
      ),
      parser: (data) => data as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> getNetworth() async {
    return get<Map<String, dynamic>>(
      '/dashboard/networth',
      parser: (data) => data as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> getInsights() async {
    return get<List<Map<String, dynamic>>>(
      '/dashboard/insights',
      parser: (data) => (data as List).cast<Map<String, dynamic>>(),
    );
  }

  // Accounts API
  Future<ApiResponse<List<Map<String, dynamic>>>> getAccounts() async {
    return get<List<Map<String, dynamic>>>(
      '/accounts',
      parser: (data) => (data as List).cast<Map<String, dynamic>>(),
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> createAccount({
    required String name,
    required String type,
    required double initialBalance,
    String? icon,
    String? color,
    String? currency,
    bool includeInTotal = true,
  }) async {
    return post<Map<String, dynamic>>(
      '/accounts',
      body: {
        'name': name,
        'type': type,
        'initialBalance': initialBalance,
        if (icon != null) 'icon': icon,
        if (color != null) 'color': color,
        if (currency != null) 'currency': currency,
        'includeInTotal': includeInTotal,
      },
      parser: (data) => data as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> updateAccount(
    String accountId, {
    String? name,
    double? balance,
    String? icon,
    String? color,
    bool? isActive,
  }) async {
    return put<Map<String, dynamic>>(
      '/accounts/$accountId',
      body: {
        if (name != null) 'name': name,
        if (balance != null) 'balance': balance,
        if (icon != null) 'icon': icon,
        if (color != null) 'color': color,
        if (isActive != null) 'isActive': isActive,
      },
      parser: (data) => data as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<bool>> deleteAccount(String accountId) async {
    return delete<bool>(
      '/accounts/$accountId',
      parser: (_) => true,
    );
  }

  // Transactions API
  Future<ApiResponse<Map<String, dynamic>>> getTransactions({
    String? type,
    String? categoryId,
    String? accountId,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int limit = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (type != null) 'type': type,
      if (categoryId != null) 'categoryId': categoryId,
      if (accountId != null) 'accountId': accountId,
      if (startDate != null) 'startDate': startDate.toIso8601String().split('T')[0],
      if (endDate != null) 'endDate': endDate.toIso8601String().split('T')[0],
    };

    return get<Map<String, dynamic>>(
      '/transactions',
      options: RequestOptions(queryParams: queryParams),
      parser: (data) => data as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> createTransaction({
    required String type,
    required double amount,
    required String categoryId,
    required String accountId,
    String? description,
    required DateTime date,
    List<String>? tags,
  }) async {
    return post<Map<String, dynamic>>(
      '/transactions',
      body: {
        'type': type,
        'amount': amount,
        'categoryId': categoryId,
        'accountId': accountId,
        if (description != null) 'description': description,
        'date': date.toIso8601String().split('T')[0],
        if (tags != null) 'tags': tags,
      },
      parser: (data) => data as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> updateTransaction(
    String transactionId, {
    String? type,
    double? amount,
    String? categoryId,
    String? accountId,
    String? description,
    DateTime? date,
    List<String>? tags,
  }) async {
    return put<Map<String, dynamic>>(
      '/transactions/$transactionId',
      body: {
        if (type != null) 'type': type,
        if (amount != null) 'amount': amount,
        if (categoryId != null) 'categoryId': categoryId,
        if (accountId != null) 'accountId': accountId,
        if (description != null) 'description': description,
        if (date != null) 'date': date.toIso8601String().split('T')[0],
        if (tags != null) 'tags': tags,
      },
      parser: (data) => data as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<bool>> deleteTransaction(String transactionId) async {
    return delete<bool>(
      '/transactions/$transactionId',
      parser: (_) => true,
    );
  }

  // Categories API
  Future<ApiResponse<List<Map<String, dynamic>>>> getCategories({String? type}) async {
    return get<List<Map<String, dynamic>>>(
      '/categories',
      options: RequestOptions(
        queryParams: type != null ? {'type': type} : null,
      ),
      parser: (data) => (data as List).cast<Map<String, dynamic>>(),
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> createCategory({
    required String name,
    required String type,
    required String icon,
    required String color,
  }) async {
    return post<Map<String, dynamic>>(
      '/categories',
      body: {
        'name': name,
        'type': type,
        'icon': icon,
        'color': color,
      },
      parser: (data) => data as Map<String, dynamic>,
    );
  }

  // Goals API
  Future<ApiResponse<List<Map<String, dynamic>>>> getGoals() async {
    return get<List<Map<String, dynamic>>>(
      '/goals',
      parser: (data) => (data as List).cast<Map<String, dynamic>>(),
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> createGoal({
    required String name,
    required double targetAmount,
    DateTime? deadline,
    String? icon,
    String? color,
    int priority = 1,
  }) async {
    return post<Map<String, dynamic>>(
      '/goals',
      body: {
        'name': name,
        'targetAmount': targetAmount,
        if (deadline != null) 'deadline': deadline.toIso8601String().split('T')[0],
        if (icon != null) 'icon': icon,
        if (color != null) 'color': color,
        'priority': priority,
      },
      parser: (data) => data as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> addGoalContribution(
    String goalId, {
    required double amount,
    String? note,
  }) async {
    return post<Map<String, dynamic>>(
      '/goals/$goalId/contribute',
      body: {
        'amount': amount,
        if (note != null) 'note': note,
      },
      parser: (data) => data as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<bool>> deleteGoal(String goalId) async {
    return delete<bool>(
      '/goals/$goalId',
      parser: (_) => true,
    );
  }

  // Portfolio API
  Future<ApiResponse<Map<String, dynamic>>> getPortfolioSummary() async {
    return get<Map<String, dynamic>>(
      '/portfolio/summary',
      parser: (data) => data as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> getHoldings() async {
    return get<List<Map<String, dynamic>>>(
      '/portfolio/holdings',
      parser: (data) => (data as List).cast<Map<String, dynamic>>(),
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> addHolding({
    required String symbol,
    required String companyName,
    required double shares,
    required double buyPrice,
    DateTime? buyDate,
    String? sector,
    double? fees,
  }) async {
    return post<Map<String, dynamic>>(
      '/portfolio/holdings',
      body: {
        'symbol': symbol,
        'companyName': companyName,
        'shares': shares,
        'averagePrice': buyPrice,
        if (buyDate != null) 'buyDate': buyDate.toIso8601String().split('T')[0],
        if (sector != null) 'sector': sector,
        if (fees != null) 'fees': fees,
      },
      parser: (data) => data as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> recordBuy(
    String holdingId, {
    required double shares,
    required double price,
    required DateTime date,
    double? fees,
    String? broker,
  }) async {
    return post<Map<String, dynamic>>(
      '/portfolio/holdings/$holdingId/buy',
      body: {
        'shares': shares,
        'price': price,
        'date': date.toIso8601String().split('T')[0],
        if (fees != null) 'fees': fees,
        if (broker != null) 'broker': broker,
      },
      parser: (data) => data as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> recordSell(
    String holdingId, {
    required double shares,
    required double price,
    required DateTime date,
    double? fees,
    String? broker,
  }) async {
    return post<Map<String, dynamic>>(
      '/portfolio/holdings/$holdingId/sell',
      body: {
        'shares': shares,
        'price': price,
        'date': date.toIso8601String().split('T')[0],
        if (fees != null) 'fees': fees,
        if (broker != null) 'broker': broker,
      },
      parser: (data) => data as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<bool>> removeHolding(String holdingId) async {
    return delete<bool>(
      '/portfolio/holdings/$holdingId',
      parser: (_) => true,
    );
  }

  // Watchlist API
  Future<ApiResponse<List<Map<String, dynamic>>>> getWatchlist() async {
    return get<List<Map<String, dynamic>>>(
      '/watchlist',
      parser: (data) => (data as List).cast<Map<String, dynamic>>(),
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> addToWatchlist({
    required String symbol,
    required String companyName,
    double? targetPrice,
  }) async {
    return post<Map<String, dynamic>>(
      '/watchlist',
      body: {
        'symbol': symbol,
        'companyName': companyName,
        if (targetPrice != null) 'targetPrice': targetPrice,
      },
      parser: (data) => data as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<bool>> removeFromWatchlist(String symbol) async {
    return delete<bool>(
      '/watchlist/$symbol',
      parser: (_) => true,
    );
  }

  // Statistics API
  Future<ApiResponse<Map<String, dynamic>>> getSpendingStats({
    String period = 'monthly',
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return get<Map<String, dynamic>>(
      '/stats/spending',
      options: RequestOptions(
        queryParams: {
          'period': period,
          if (startDate != null) 'startDate': startDate.toIso8601String().split('T')[0],
          if (endDate != null) 'endDate': endDate.toIso8601String().split('T')[0],
        },
      ),
      parser: (data) => data as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> getIncomeStats({
    String period = 'monthly',
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return get<Map<String, dynamic>>(
      '/stats/income',
      options: RequestOptions(
        queryParams: {
          'period': period,
          if (startDate != null) 'startDate': startDate.toIso8601String().split('T')[0],
          if (endDate != null) 'endDate': endDate.toIso8601String().split('T')[0],
        },
      ),
      parser: (data) => data as Map<String, dynamic>,
    );
  }

  // User API
  Future<ApiResponse<Map<String, dynamic>>> getUserProfile() async {
    return get<Map<String, dynamic>>(
      '/users/profile',
      parser: (data) => data as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> updateUserProfile({
    String? name,
    String? phone,
    String? avatar,
    String? currency,
    String? timezone,
    String? language,
  }) async {
    return put<Map<String, dynamic>>(
      '/users/profile',
      body: {
        if (name != null) 'name': name,
        if (phone != null) 'phone': phone,
        if (avatar != null) 'avatar': avatar,
        if (currency != null) 'currency': currency,
        if (timezone != null) 'timezone': timezone,
        if (language != null) 'language': language,
      },
      parser: (data) => data as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> getUserSettings() async {
    return get<Map<String, dynamic>>(
      '/users/settings',
      parser: (data) => data as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> updateUserSettings(
    Map<String, dynamic> settings,
  ) async {
    return put<Map<String, dynamic>>(
      '/users/settings',
      body: settings,
      parser: (data) => data as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<bool>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    return post<bool>(
      '/users/change-password',
      body: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
      parser: (_) => true,
    );
  }

  // Upload API
  Future<ApiResponse<Map<String, dynamic>>> uploadReceipt(String filePath) async {
    return uploadFile(
      '/utilities/receipts',
      filePath: filePath,
      fieldName: 'file',
    );
  }
}
