import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../core/constants.dart';
import '../core/exceptions.dart';

/// API Service for FinTrack application
/// Handles all HTTP requests with error handling, token management, and mock data fallback
class ApiService {
  static ApiService? _instance;
  late final Dio _dio;
  
  // Token storage
  String? _accessToken;
  String? _refreshToken;
  
  // Mock mode flag
  bool _useMockData = false;
  
  // Singleton pattern
  ApiService._internal() {
    _dio = Dio(_baseOptions);
    _setupInterceptors();
  }
  
  factory ApiService({bool useMockData = false}) {
    _instance ??= ApiService._internal();
    _instance!._useMockData = useMockData;
    return _instance!;
  }
  
  /// Base Dio options
  BaseOptions get _baseOptions => BaseOptions(
    baseUrl: ApiConfig.baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-App-Version': ApiConfig.appVersion,
    },
  );
  
  /// Setup Dio interceptors
  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add auth token to headers
          if (_accessToken != null) {
            options.headers['Authorization'] = 'Bearer $_accessToken';
          }
          // Add request ID for tracing
          options.headers['X-Request-ID'] = _generateRequestId();
          // Add timezone
          options.headers['X-Timezone'] = 'Asia/Jakarta';
          
          if (kDebugMode) {
            print('🌐 REQUEST[${options.method}] => PATH: ${options.path}');
            print('Headers: ${options.headers}');
            if (options.data != null) {
              print('Body: ${options.data}');
            }
          }
          
          handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            print('✅ RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
          }
          handler.next(response);
        },
        onError: (error, handler) async {
          if (kDebugMode) {
            print('❌ ERROR[${error.response?.statusCode}] => PATH: ${error.requestOptions.path}');
            print('Error: ${error.message}');
          }
          
          // Handle token expiration
          if (error.response?.statusCode == 401) {
            final refreshed = await _handleTokenRefresh();
            if (refreshed) {
              // Retry the original request
              final retryResponse = await _retryRequest(error.requestOptions);
              return handler.resolve(retryResponse);
            }
          }
          
          handler.next(error);
        },
      ),
    );
    
    // Add logging interceptor for debug mode
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        logPrint: (obj) => debugPrint(obj.toString()),
      ));
    }
  }
  
  // ==================== TOKEN MANAGEMENT ====================
  
  /// Set authentication tokens
  void setTokens({required String accessToken, required String refreshToken}) {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
  }
  
  /// Clear authentication tokens
  void clearTokens() {
    _accessToken = null;
    _refreshToken = null;
  }
  
  /// Check if user is authenticated
  bool get isAuthenticated => _accessToken != null;
  
  /// Handle token refresh
  Future<bool> _handleTokenRefresh() async {
    if (_refreshToken == null) return false;
    
    try {
      final response = await _dio.post(
        '/auth/refresh',
        data: {'refreshToken': _refreshToken},
        options: Options(headers: {'Authorization': ''}),
      );
      
      if (response.statusCode == 200) {
        final data = response.data['data'];
        setTokens(
          accessToken: data['tokens']['accessToken'],
          refreshToken: data['tokens']['refreshToken'],
        );
        return true;
      }
    } catch (e) {
      if (kDebugMode) print('Token refresh failed: $e');
    }
    
    clearTokens();
    return false;
  }
  
  /// Retry a failed request
  Future<Response> _retryRequest(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: {
        ...requestOptions.headers,
        'Authorization': 'Bearer $_accessToken',
      },
    );
    
    return _dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }
  
  /// Generate unique request ID
  String _generateRequestId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
  
  // ==================== GENERIC REQUEST METHODS ====================
  
  /// GET request
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic>)? parser,
  }) async {
    if (_useMockData) {
      return _getMockResponse<T>(path, 'GET', parser: parser);
    }
    
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return _handleResponse<T>(response, parser);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// POST request
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic>)? parser,
  }) async {
    if (_useMockData) {
      return _getMockResponse<T>(path, 'POST', parser: parser);
    }
    
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return _handleResponse<T>(response, parser);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// PUT request
  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic>)? parser,
  }) async {
    if (_useMockData) {
      return _getMockResponse<T>(path, 'PUT', parser: parser);
    }
    
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return _handleResponse<T>(response, parser);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// PATCH request
  Future<ApiResponse<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic>)? parser,
  }) async {
    if (_useMockData) {
      return _getMockResponse<T>(path, 'PATCH', parser: parser);
    }
    
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return _handleResponse<T>(response, parser);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// DELETE request
  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic>)? parser,
  }) async {
    if (_useMockData) {
      return _getMockResponse<T>(path, 'DELETE', parser: parser);
    }
    
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return _handleResponse<T>(response, parser);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// Upload file
  Future<ApiResponse<T>> uploadFile<T>(
    String path, {
    required String filePath,
    required String fieldName,
    Map<String, dynamic>? additionalFields,
    T Function(Map<String, dynamic>)? parser,
  }) async {
    if (_useMockData) {
      return _getMockResponse<T>(path, 'POST', parser: parser);
    }
    
    try {
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(filePath),
        ...?additionalFields,
      });
      
      final response = await _dio.post(
        path,
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      );
      
      return _handleResponse<T>(response, parser);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// Handle API response
  ApiResponse<T> _handleResponse<T>(
    Response response,
    T Function(Map<String, dynamic>)? parser,
  ) {
    final data = response.data;
    
    if (data['success'] == true) {
      return ApiResponse<T>.success(
        data: parser != null && data['data'] != null 
          ? parser(data['data']) 
          : data['data'] as T?,
        meta: data['meta'] != null 
          ? ResponseMeta.fromJson(data['meta']) 
          : null,
      );
    } else {
      throw ApiException(
        code: data['error']['code'] ?? 'UNKNOWN_ERROR',
        message: data['error']['message'] ?? 'An unknown error occurred',
        details: data['error']['details'] != null 
          ? List<ErrorDetail>.from(
              data['error']['details'].map((d) => ErrorDetail.fromJson(d)),
            )
          : null,
      );
    }
  }
  
  /// Handle Dio errors
  ApiException _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          code: 'TIMEOUT_ERROR',
          message: 'Connection timed out. Please try again.',
        );
      
      case DioExceptionType.connectionError:
        return ApiException(
          code: 'NETWORK_ERROR',
          message: 'No internet connection. Please check your network.',
        );
      
      case DioExceptionType.badResponse:
        return _parseErrorResponse(error.response);
      
      case DioExceptionType.cancel:
        return ApiException(
          code: 'REQUEST_CANCELLED',
          message: 'Request was cancelled.',
        );
      
      default:
        return ApiException(
          code: 'INTERNAL_ERROR',
          message: 'An internal error occurred. Please try again.',
        );
    }
  }
  
  /// Parse error response from server
  ApiException _parseErrorResponse(Response? response) {
    if (response == null) {
      return ApiException(
        code: 'NO_RESPONSE',
        message: 'No response from server.',
      );
    }
    
    final data = response.data;
    
    if (data is Map && data.containsKey('error')) {
      return ApiException(
        code: data['error']['code'] ?? 'SERVER_ERROR',
        message: data['error']['message'] ?? 'Server error occurred',
        details: data['error']['details'] != null 
          ? List<ErrorDetail>.from(
              data['error']['details'].map((d) => ErrorDetail.fromJson(d)),
            )
          : null,
        statusCode: response.statusCode,
      );
    }
    
    switch (response.statusCode) {
      case 400:
        return ApiException(
          code: 'BAD_REQUEST',
          message: 'Invalid request. Please check your input.',
          statusCode: 400,
        );
      case 401:
        return ApiException(
          code: 'UNAUTHORIZED',
          message: 'Authentication required. Please login.',
          statusCode: 401,
        );
      case 403:
        return ApiException(
          code: 'FORBIDDEN',
          message: 'You do not have permission to perform this action.',
          statusCode: 403,
        );
      case 404:
        return ApiException(
          code: 'NOT_FOUND',
          message: 'Resource not found.',
          statusCode: 404,
        );
      case 409:
        return ApiException(
          code: 'CONFLICT',
          message: 'Resource already exists.',
          statusCode: 409,
        );
      case 422:
        return ApiException(
          code: 'VALIDATION_ERROR',
          message: 'Validation failed. Please check your input.',
          statusCode: 422,
        );
      case 429:
        return ApiException(
          code: 'RATE_LIMITED',
          message: 'Too many requests. Please try again later.',
          statusCode: 429,
        );
      case 500:
      default:
        return ApiException(
          code: 'SERVER_ERROR',
          message: 'Server error. Please try again later.',
          statusCode: response.statusCode ?? 500,
        );
    }
  }
  
  // ==================== MOCK DATA FALLBACK ====================
  
  /// Get mock response based on path
  Future<ApiResponse<T>> _getMockResponse<T>(
    String path,
    String method, {
    T Function(Map<String, dynamic>)? parser,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    
    Map<String, dynamic>? mockData;
    
    // Route-based mock data selection
    if (path.startsWith('/auth')) {
      mockData = _getMockAuthData(path, method);
    } else if (path.startsWith('/accounts')) {
      mockData = _getMockAccountsData(path, method);
    } else if (path.startsWith('/transactions')) {
      mockData = _getMockTransactionsData(path, method);
    } else if (path.startsWith('/categories')) {
      mockData = _getMockCategoriesData(path, method);
    } else if (path.startsWith('/goals') || path.startsWith('/savings-goals')) {
      mockData = _getMockSavingsGoalsData(path, method);
    } else if (path.startsWith('/portfolio')) {
      mockData = _getMockPortfolioData(path, method);
    } else if (path.startsWith('/watchlist')) {
      mockData = _getMockWatchlistData(path, method);
    } else if (path.startsWith('/dashboard')) {
      mockData = _getMockDashboardData(path);
    } else if (path.startsWith('/statistics') || path.startsWith('/stats')) {
      mockData = _getMockStatisticsData(path);
    } else if (path.startsWith('/users')) {
      mockData = _getMockUserData(path, method);
    } else {
      mockData = {'success': true, 'data': null};
    }
    
    if (mockData == null) {
      throw ApiException(
        code: 'NOT_IMPLEMENTED',
        message: 'Mock data not available for this endpoint.',
      );
    }
    
    return ApiResponse<T>.success(
      data: mockData['data'] != null && parser != null
        ? parser(mockData['data'])
        : mockData['data'] as T?,
      meta: mockData['meta'] != null
        ? ResponseMeta.fromJson(mockData['meta'])
        : null,
    );
  }
  
  /// Mock Authentication data
  Map<String, dynamic>? _getMockAuthData(String path, String method) {
    if (path.contains('/register') && method == 'POST') {
      return {
        'success': true,
        'data': {
          'user': _mockUser,
          'tokens': {
            'accessToken': 'mock_access_token_${DateTime.now().millisecondsSinceEpoch}',
            'refreshToken': 'mock_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
            'expiresIn': 900,
          },
        },
      };
    }
    
    if (path.contains('/login') && method == 'POST') {
      return {
        'success': true,
        'data': {
          'user': _mockUser,
          'tokens': {
            'accessToken': 'mock_access_token_${DateTime.now().millisecondsSinceEpoch}',
            'refreshToken': 'mock_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
            'expiresIn': 900,
          },
        },
      };
    }
    
    if (path.contains('/me') && method == 'GET') {
      return {
        'success': true,
        'data': _mockUser,
      };
    }
    
    if (path.contains('/refresh') && method == 'POST') {
      return {
        'success': true,
        'data': {
          'tokens': {
            'accessToken': 'mock_access_token_${DateTime.now().millisecondsSinceEpoch}',
            'refreshToken': 'mock_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
            'expiresIn': 900,
          },
        },
      };
    }
    
    return {'success': true, 'data': null};
  }
  
  /// Mock User data
  Map<String, dynamic> get _mockUser => {
    'id': 'usr_${DateTime.now().millisecondsSinceEpoch}',
    'email': 'demo@fintrack.app',
    'fullName': 'Demo User',
    'avatar': null,
    'currency': 'IDR',
    'timezone': 'Asia/Jakarta',
    'language': 'id',
    'pinEnabled': false,
    'biometricEnabled': false,
    'emailVerified': true,
    'isPremium': false,
    'createdAt': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
    'updatedAt': DateTime.now().toIso8601String(),
  };
  
  /// Mock Accounts data
  Map<String, dynamic>? _getMockAccountsData(String path, String method) {
    if (path == '/accounts' && method == 'GET') {
      return {
        'success': true,
        'data': _mockAccounts,
        'meta': {'page': 1, 'limit': 20, 'total': _mockAccounts.length},
      };
    }
    
    if (path == '/accounts' && method == 'POST') {
      return {
        'success': true,
        'data': {
          'id': 'acc_${DateTime.now().millisecondsSinceEpoch}',
          'name': 'New Account',
          'type': 'bank',
          'balance': 0,
          'currency': 'IDR',
          'icon': 'account_balance',
          'color': '#2563EB',
          'isActive': true,
          'createdAt': DateTime.now().toIso8601String(),
        },
      };
    }
    
    if (path.contains('/accounts/') && path.contains('/balance') && method == 'GET') {
      return {
        'success': true,
        'data': {
          'totalBalance': 45000000,
          'byType': {
            'cash': 5000000,
            'bank': 25000000,
            'ewallet': 5000000,
            'savings': 10000000,
            'investment': 0,
          },
        },
      };
    }
    
    return {'success': true, 'data': _mockAccounts};
  }
  
  /// Mock accounts list
  List<Map<String, dynamic>> get _mockAccounts => [
    {
      'id': 'acc_001',
      'name': 'Bank BCA',
      'type': 'bank',
      'balance': 15000000,
      'currency': 'IDR',
      'icon': 'account_balance',
      'color': '#1E3A5F',
      'isActive': true,
      'createdAt': DateTime.now().subtract(const Duration(days: 60)).toIso8601String(),
    },
    {
      'id': 'acc_002',
      'name': 'OVO E-Wallet',
      'type': 'ewallet',
      'balance': 2500000,
      'currency': 'IDR',
      'icon': 'smartphone',
      'color': '#6B3FA0',
      'isActive': true,
      'createdAt': DateTime.now().subtract(const Duration(days: 45)).toIso8601String(),
    },
    {
      'id': 'acc_003',
      'name': 'Tabungan Hari Tua',
      'type': 'savings',
      'balance': 10000000,
      'currency': 'IDR',
      'icon': 'savings',
      'color': '#10B981',
      'isActive': true,
      'createdAt': DateTime.now().subtract(const Duration(days: 90)).toIso8601String(),
    },
    {
      'id': 'acc_004',
      'name': 'Uang Tunai',
      'type': 'cash',
      'balance': 500000,
      'currency': 'IDR',
      'icon': 'wallet',
      'color': '#F59E0B',
      'isActive': true,
      'createdAt': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
    },
  ];
  
  /// Mock Transactions data
  Map<String, dynamic>? _getMockTransactionsData(String path, String method) {
    if (path == '/transactions' && method == 'GET') {
      return {
        'success': true,
        'data': _mockTransactions,
        'meta': {'page': 1, 'limit': 20, 'total': _mockTransactions.length},
      };
    }
    
    if (path == '/transactions' && method == 'POST') {
      return {
        'success': true,
        'data': {
          'id': 'txn_${DateTime.now().millisecondsSinceEpoch}',
          'type': 'expense',
          'amount': 50000,
          'category': 'Makanan',
          'description': 'Test Transaction',
          'accountId': 'acc_001',
          'date': DateTime.now().toIso8601String(),
          'createdAt': DateTime.now().toIso8601String(),
        },
      };
    }
    
    return {'success': true, 'data': _mockTransactions};
  }
  
  /// Mock transactions list
  List<Map<String, dynamic>> get _mockTransactions => [
    {
      'id': 'txn_001',
      'type': 'income',
      'amount': 15000000,
      'category': 'Gaji',
      'categoryId': 'cat_income_001',
      'description': 'Gaji Bulanan Januari',
      'accountId': 'acc_001',
      'date': DateTime.now().subtract(const Duration(days: 5)).toIso8601String().split('T')[0],
      'createdAt': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
    },
    {
      'id': 'txn_002',
      'type': 'expense',
      'amount': 250000,
      'category': 'Makanan',
      'categoryId': 'cat_expense_001',
      'description': 'Makan siang tim',
      'accountId': 'acc_001',
      'date': DateTime.now().subtract(const Duration(days: 3)).toIso8601String().split('T')[0],
      'createdAt': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
    },
    {
      'id': 'txn_003',
      'type': 'expense',
      'amount': 150000,
      'category': 'Transportasi',
      'categoryId': 'cat_expense_002',
      'description': 'Grab ke kantor',
      'accountId': 'acc_002',
      'date': DateTime.now().subtract(const Duration(days: 2)).toIso8601String().split('T')[0],
      'createdAt': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
    },
    {
      'id': 'txn_004',
      'type': 'expense',
      'amount': 75000,
      'category': 'Hiburan',
      'categoryId': 'cat_expense_004',
      'description': 'Netflix Premium',
      'accountId': 'acc_001',
      'date': DateTime.now().subtract(const Duration(days: 1)).toIso8601String().split('T')[0],
      'recurring': true,
      'createdAt': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
    },
    {
      'id': 'txn_005',
      'type': 'expense',
      'amount': 500000,
      'category': 'Belanja',
      'categoryId': 'cat_expense_003',
      'description': 'Groceries mingguan',
      'accountId': 'acc_001',
      'date': DateTime.now().toIso8601String().split('T')[0],
      'createdAt': DateTime.now().toIso8601String(),
    },
  ];
  
  /// Mock Categories data
  Map<String, dynamic>? _getMockCategoriesData(String path, String method) {
    return {
      'success': true,
      'data': _mockCategories,
      'meta': {'page': 1, 'limit': 50, 'total': _mockCategories.length},
    };
  }
  
  /// Mock categories list
  List<Map<String, dynamic>> get _mockCategories => [
    // Income categories
    {'id': 'cat_income_001', 'name': 'Gaji', 'type': 'income', 'icon': 'briefcase', 'color': '#10B981', 'isSystem': true},
    {'id': 'cat_income_002', 'name': 'Freelance', 'type': 'income', 'icon': 'laptop', 'color': '#F59E0B', 'isSystem': true},
    {'id': 'cat_income_003', 'name': 'Investasi', 'type': 'income', 'icon': 'trending-up', 'color': '#6366F1', 'isSystem': true},
    {'id': 'cat_income_004', 'name': 'Hadiah', 'type': 'income', 'icon': 'gift', 'color': '#EC4899', 'isSystem': true},
    // Expense categories
    {'id': 'cat_expense_001', 'name': 'Makanan', 'type': 'expense', 'icon': 'utensils', 'color': '#EF4444', 'isSystem': true},
    {'id': 'cat_expense_002', 'name': 'Transportasi', 'type': 'expense', 'icon': 'car', 'color': '#F59E0B', 'isSystem': true},
    {'id': 'cat_expense_003', 'name': 'Belanja', 'type': 'expense', 'icon': 'shopping-bag', 'color': '#10B981', 'isSystem': true},
    {'id': 'cat_expense_004', 'name': 'Hiburan', 'type': 'expense', 'icon': 'film', 'color': '#8B5CF6', 'isSystem': true},
    {'id': 'cat_expense_005', 'name': 'Kesehatan', 'type': 'expense', 'icon': 'heart', 'color': '#EC4899', 'isSystem': true},
    {'id': 'cat_expense_006', 'name': 'Pendidikan', 'type': 'expense', 'icon': 'book', 'color': '#06B6D4', 'isSystem': true},
    {'id': 'cat_expense_007', 'name': 'Tagihan', 'type': 'expense', 'icon': 'file-text', 'color': '#6366F1', 'isSystem': true},
    {'id': 'cat_expense_008', 'name': 'Lainnya', 'type': 'expense', 'icon': 'more-horizontal', 'color': '#94A3B8', 'isSystem': true},
  ];
  
  /// Mock Savings Goals data
  Map<String, dynamic>? _getMockSavingsGoalsData(String path, String method) {
    if ((path == '/goals' || path == '/savings-goals') && method == 'GET') {
      return {
        'success': true,
        'data': _mockSavingsGoals,
        'meta': {'page': 1, 'limit': 20, 'total': _mockSavingsGoals.length},
      };
    }
    
    if ((path == '/goals' || path == '/savings-goals') && method == 'POST') {
      return {
        'success': true,
        'data': {
          'id': 'goal_${DateTime.now().millisecondsSinceEpoch}',
          'name': 'New Savings Goal',
          'targetAmount': 10000000,
          'currentAmount': 0,
          'deadline': DateTime.now().add(const Duration(days: 180)).toIso8601String().split('T')[0],
          'icon': 'target',
          'color': '#2563EB',
          'status': 'active',
          'createdAt': DateTime.now().toIso8601String(),
        },
      };
    }
    
    return {'success': true, 'data': _mockSavingsGoals};
  }
  
  /// Mock savings goals list
  List<Map<String, dynamic>> get _mockSavingsGoals => [
    {
      'id': 'goal_001',
      'name': 'Dana Darurat',
      'targetAmount': 36000000,
      'currentAmount': 18000000,
      'deadline': DateTime.now().add(const Duration(days: 180)).toIso8601String().split('T')[0],
      'icon': 'shield',
      'color': '#2563EB',
      'status': 'active',
      'progress': 50,
      'createdAt': DateTime.now().subtract(const Duration(days: 90)).toIso8601String(),
    },
    {
      'id': 'goal_002',
      'name': 'Liburan',
      'targetAmount': 10000000,
      'currentAmount': 7500000,
      'deadline': DateTime.now().add(const Duration(days: 60)).toIso8601String().split('T')[0],
      'icon': 'flight',
      'color': '#10B981',
      'status': 'active',
      'progress': 75,
      'createdAt': DateTime.now().subtract(const Duration(days: 60)).toIso8601String(),
    },
    {
      'id': 'goal_003',
      'name': 'Laptop Baru',
      'targetAmount': 20000000,
      'currentAmount': 20000000,
      'deadline': DateTime.now().subtract(const Duration(days: 10)).toIso8601String().split('T')[0],
      'icon': 'laptop',
      'color': '#F59E0B',
      'status': 'completed',
      'progress': 100,
      'completedAt': DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
      'createdAt': DateTime.now().subtract(const Duration(days: 120)).toIso8601String(),
    },
  ];
  
  /// Mock Portfolio data
  Map<String, dynamic>? _getMockPortfolioData(String path, String method) {
    if (path == '/portfolio' && method == 'GET') {
      return {
        'success': true,
        'data': {
          'holdings': _mockPortfolioHoldings,
          'summary': _mockPortfolioSummary,
        },
      };
    }
    
    if (path == '/portfolio' && method == 'POST') {
      return {
        'success': true,
        'data': {
          'id': 'hold_${DateTime.now().millisecondsSinceEpoch}',
          'symbol': 'BBCA',
          'companyName': 'Bank Central Asia',
          'shares': 100,
          'averagePrice': 8500,
          'currentPrice': 9200,
          'totalValue': 920000,
          'profitLoss': 70000,
          'profitLossPercent': 8.24,
          'createdAt': DateTime.now().toIso8601String(),
        },
      };
    }
    
    if (path == '/portfolio/summary') {
      return {
        'success': true,
        'data': _mockPortfolioSummary,
      };
    }
    
    return {'success': true, 'data': {'holdings': _mockPortfolioHoldings}};
  }
  
  /// Mock portfolio holdings
  List<Map<String, dynamic>> get _mockPortfolioHoldings => [
    {
      'id': 'hold_001',
      'symbol': 'BBCA',
      'companyName': 'Bank Central Asia',
      'shares': 100,
      'averagePrice': 8500,
      'currentPrice': 9200,
      'totalValue': 920000,
      'totalInvested': 850000,
      'profitLoss': 70000,
      'profitLossPercent': 8.24,
      'sector': 'Financial Services',
      'exchange': 'IDX',
      'lastUpdated': DateTime.now().toIso8601String(),
    },
    {
      'id': 'hold_002',
      'symbol': 'TLKM',
      'companyName': 'Telkom Indonesia',
      'shares': 500,
      'averagePrice': 3100,
      'currentPrice': 2950,
      'totalValue': 1475000,
      'totalInvested': 1550000,
      'profitLoss': -75000,
      'profitLossPercent': -4.84,
      'sector': 'Communication Services',
      'exchange': 'IDX',
      'lastUpdated': DateTime.now().toIso8601String(),
    },
    {
      'id': 'hold_003',
      'symbol': 'UNVR',
      'companyName': 'Unilever Indonesia',
      'shares': 200,
      'averagePrice': 4200,
      'currentPrice': 4500,
      'totalValue': 900000,
      'totalInvested': 840000,
      'profitLoss': 60000,
      'profitLossPercent': 7.14,
      'sector': 'Consumer Goods',
      'exchange': 'IDX',
      'lastUpdated': DateTime.now().toIso8601String(),
    },
  ];
  
  /// Mock portfolio summary
  Map<String, dynamic> get _mockPortfolioSummary => {
    'totalInvested': 3240000,
    'currentValue': 3295000,
    'totalProfitLoss': 55000,
    'totalProfitLossPercent': 1.70,
    'dayChange': 15000,
    'dayChangePercent': 0.46,
    'bestPerformer': {'symbol': 'BBCA', 'profitLossPercent': 8.24},
    'worstPerformer': {'symbol': 'TLKM', 'profitLossPercent': -4.84},
    'sectorAllocation': [
      {'sector': 'Financial', 'percentage': 28, 'value': 920000},
      {'sector': 'Communication', 'percentage': 45, 'value': 1475000},
      {'sector': 'Consumer', 'percentage': 27, 'value': 900000},
    ],
  };
  
  /// Mock Watchlist data
  Map<String, dynamic>? _getMockWatchlistData(String path, String method) {
    return {
      'success': true,
      'data': _mockWatchlist,
      'meta': {'page': 1, 'limit': 50, 'total': _mockWatchlist.length},
    };
  }
  
  /// Mock watchlist
  List<Map<String, dynamic>> get _mockWatchlist => [
    {
      'id': 'watch_001',
      'symbol': 'AMMN',
      'companyName': 'Ammann Mineral Internasional',
      'lastPrice': 12500,
      'change': 450,
      'changePercent': 3.74,
      'volume': 1500000,
      'targetPrice': 15000,
      'alertEnabled': true,
      'addedAt': DateTime.now().subtract(const Duration(days: 7)).toIso8601String(),
    },
    {
      'id': 'watch_002',
      'symbol': 'ANTM',
      'companyName': 'Aneka Tambang',
      'lastPrice': 1850,
      'change': -25,
      'changePercent': -1.33,
      'volume': 800000,
      'targetPrice': 2000,
      'alertEnabled': false,
      'addedAt': DateTime.now().subtract(const Duration(days: 14)).toIso8601String(),
    },
  ];
  
  /// Mock Dashboard data
  Map<String, dynamic>? _getMockDashboardData(String path) {
    if (path == '/dashboard/summary') {
      return {
        'success': true,
        'data': {
          'totalBalance': 45000000,
          'monthlyIncome': 15000000,
          'monthlyExpense': 4500000,
          'totalSavings': 28000000,
          'portfolioValue': 3295000,
          'savingsRate': 70,
          'cashflow': _mockCashflowData,
          'netWorth': _mockNetWorthData,
        },
      };
    }
    
    if (path == '/dashboard/cashflow') {
      return {
        'success': true,
        'data': _mockCashflowData,
      };
    }
    
    if (path == '/dashboard/networth') {
      return {
        'success': true,
        'data': _mockNetWorthData,
      };
    }
    
    if (path == '/dashboard/insights') {
      return {
        'success': true,
        'data': _mockInsights,
      };
    }
    
    return {'success': true, 'data': null};
  }
  
  /// Mock cashflow data
  Map<String, dynamic> get _mockCashflowData => {
    'labels': ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
    'income': [15000000, 15000000, 18000000, 15000000, 15000000, 16000000],
    'expense': [3500000, 4200000, 3800000, 4500000, 4000000, 4500000],
  };
  
  /// Mock net worth data
  Map<String, dynamic> get _mockNetWorthData => {
    'current': 48295000,
    'change': 2500000,
    'changePercent': 5.46,
    'history': [
      {'date': '2024-01', 'value': 43000000},
      {'date': '2024-02', 'value': 44200000},
      {'date': '2024-03', 'value': 45100000},
      {'date': '2024-04', 'value': 45700000},
      {'date': '2024-05', 'value': 46500000},
      {'date': '2024-06', 'value': 48295000},
    ],
  };
  
  /// Mock insights
  List<Map<String, dynamic>> get _mockInsights => [
    {
      'id': 'insight_001',
      'type': 'positive',
      'title': 'Tabungan Meningkat',
      'message': 'Tabungan Anda meningkat 15% dari bulan lalu. Pertahankan!',
      'icon': 'trending-up',
    },
    {
      'id': 'insight_002',
      'type': 'warning',
      'title': 'Pengeluaran Hiburan Tinggi',
      'message': 'Pengeluaran hiburan Anda 20% lebih tinggi dari rata-rata.',
      'icon': 'alert-triangle',
    },
    {
      'id': 'insight_003',
      'type': 'info',
      'title': 'Target Dana Darurat',
      'message': 'Anda sudah mencapai 50% target dana darurat. Hanya 6 bulan lagi!',
      'icon': 'target',
    },
  ];
  
  /// Mock Statistics data
  Map<String, dynamic>? _getMockStatisticsData(String path) {
    if (path.contains('spending') || path.contains('expenses')) {
      return {
        'success': true,
        'data': {
          'totalSpending': 4500000,
          'transactionCount': 45,
          'averageTransaction': 100000,
          'byCategory': [
            {'category': 'Makanan', 'total': 1500000, 'percentage': 33.3},
            {'category': 'Transportasi', 'total': 800000, 'percentage': 17.8},
            {'category': 'Belanja', 'total': 1200000, 'percentage': 26.7},
            {'category': 'Hiburan', 'total': 600000, 'percentage': 13.3},
            {'category': 'Lainnya', 'total': 400000, 'percentage': 8.9},
          ],
          'byDay': [
            {'date': '2024-06-01', 'total': 150000},
            {'date': '2024-06-02', 'total': 200000},
            {'date': '2024-06-03', 'total': 100000},
          ],
        },
      };
    }
    
    if (path.contains('income')) {
      return {
        'success': true,
        'data': {
          'totalIncome': 15000000,
          'transactionCount': 5,
          'averageTransaction': 3000000,
          'byCategory': [
            {'category': 'Gaji', 'total': 12000000, 'percentage': 80},
            {'category': 'Freelance', 'total': 3000000, 'percentage': 20},
          ],
        },
      };
    }
    
    if (path.contains('networth')) {
      return {
        'success': true,
        'data': {
          'totalAssets': 48295000,
          'totalLiabilities': 0,
          'netWorth': 48295000,
          'assetAllocation': {
            'cash': 500000,
            'bank': 25000000,
            'ewallet': 2500000,
            'savings': 10000000,
            'portfolio': 3295000,
          },
          'changePercent': 5.46,
          'history': _mockNetWorthData['history'],
        },
      };
    }
    
    return {
      'success': true,
      'data': {
        'totalSpending': 4500000,
        'totalIncome': 15000000,
        'netCashflow': 10500000,
        'savingsRate': 70,
      },
    };
  }
  
  /// Mock User data
  Map<String, dynamic>? _getMockUserData(String path, String method) {
    if (path.contains('/profile') || path == '/users/me') {
      return {
        'success': true,
        'data': _mockUser,
      };
    }
    
    if (path.contains('/settings')) {
      return {
        'success': true,
        'data': {
          'theme': 'system',
          'currency': 'IDR',
          'language': 'id',
          'notifications': {
            'dailyReminder': true,
            'reminderTime': '20:00',
            'transactionAlerts': true,
            'portfolioAlerts': true,
            'savingsMilestones': true,
          },
          'security': {
            'pinEnabled': false,
            'biometricEnabled': false,
          },
        },
      };
    }
    
    return {'success': true, 'data': _mockUser};
  }
}

// ==================== API CONFIG ====================

/// API configuration class
class ApiConfig {
  static const String baseUrl = 'https://api.fintrack.app/v1';
  static const String appVersion = '1.0.0';
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
}

// ==================== RESPONSE MODELS ====================

/// Generic API response wrapper
class ApiResponse<T> {
  final bool success;
  final T? data;
  final ResponseMeta? meta;
  final String? error;

  ApiResponse._({
    required this.success,
    this.data,
    this.meta,
    this.error,
  });

  factory ApiResponse.success({T? data, ResponseMeta? meta}) {
    return ApiResponse._(
      success: true,
      data: data,
      meta: meta,
    );
  }

  factory ApiResponse.error(String message) {
    return ApiResponse._(
      success: false,
      error: message,
    );
  }
}

/// Response metadata for pagination
class ResponseMeta {
  final int page;
  final int limit;
  final int total;
  final int? totalPages;

  ResponseMeta({
    required this.page,
    required this.limit,
    required this.total,
    this.totalPages,
  });

  factory ResponseMeta.fromJson(Map<String, dynamic> json) {
    return ResponseMeta(
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 20,
      total: json['total'] ?? 0,
      totalPages: json['totalPages'],
    );
  }
}

/// Error detail model
class ErrorDetail {
  final String? field;
  final String message;
  final dynamic value;

  ErrorDetail({
    this.field,
    required this.message,
    this.value,
  });

  factory ErrorDetail.fromJson(Map<String, dynamic> json) {
    return ErrorDetail(
      field: json['field'],
      message: json['message'],
      value: json['value'],
    );
  }
}

// ==================== SERVICE LOCATOR ====================

/// Service locator for dependency injection
class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  final Map<Type, dynamic> _services = {};

  void register<T>(T service) {
    _services[T] = service;
  }

  T get<T>() {
    final service = _services[T];
    if (service == null) {
      throw Exception('Service of type $T not registered');
    }
    return service as T;
  }

  void unregister<T>() {
    _services.remove(T);
  }

  void reset() {
    _services.clear();
  }
}
