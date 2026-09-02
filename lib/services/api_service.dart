import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// API Service Configuration
class ApiServiceConfig {
  final String baseUrl;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final bool enableMockData;
  final bool enableLogging;

  const ApiServiceConfig({
    this.baseUrl = ApiConstants.baseUrl,
    this.connectTimeout = const Duration(seconds: 30),
    this.receiveTimeout = const Duration(seconds: 30),
    this.enableMockData = false,
    this.enableLogging = true,
  });
}

/// Custom API Exception
class ApiException implements Exception {
  final String code;
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? details;
  final dynamic originalError;

  ApiException({
    required this.code,
    required this.message,
    this.statusCode,
    this.details,
    this.originalError,
  });

  factory ApiException.fromDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return ApiException(
          code: 'CONNECTION_TIMEOUT',
          message: 'Connection timeout. Please check your internet connection.',
          statusCode: 408,
          originalError: error,
        );
      case DioExceptionType.sendTimeout:
        return ApiException(
          code: 'SEND_TIMEOUT',
          message: 'Request timeout. Please try again.',
          statusCode: 408,
          originalError: error,
        );
      case DioExceptionType.receiveTimeout:
        return ApiException(
          code: 'RECEIVE_TIMEOUT',
          message: 'Server response timeout. Please try again.',
          statusCode: 408,
          originalError: error,
        );
      case DioExceptionType.badResponse:
        return ApiException._handleBadResponse(error.response);
      case DioExceptionType.cancel:
        return ApiException(
          code: 'REQUEST_CANCELLED',
          message: 'Request was cancelled.',
          originalError: error,
        );
      case DioExceptionType.connectionError:
        return ApiException(
          code: 'NO_INTERNET',
          message: 'No internet connection. Please check your network.',
          originalError: error,
        );
      default:
        return ApiException(
          code: 'UNKNOWN_ERROR',
          message: 'An unexpected error occurred.',
          originalError: error,
        );
    }
  }

  factory ApiException._handleBadResponse(Response? response) {
    final statusCode = response?.statusCode ?? 500;
    final data = response?.data;
    String code = 'SERVER_ERROR';
    String message = 'Server error occurred.';

    if (data is Map<String, dynamic>) {
      code = data['error']?['code'] ?? _getCodeFromStatus(statusCode);
      message = data['error']?['message'] ?? message;
    } else {
      code = _getCodeFromStatus(statusCode);
      message = _getMessageFromStatus(statusCode);
    }

    return ApiException(
      code: code,
      message: message,
      statusCode: statusCode,
      details: data is Map<String, dynamic> ? data['error']?['details'] : null,
      originalError: response,
    );
  }

  static String _getCodeFromStatus(int statusCode) {
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
      default:
        return 'SERVER_ERROR';
    }
  }

  static String _getMessageFromStatus(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Invalid request. Please check your input.';
      case 401:
        return 'Authentication required. Please login.';
      case 403:
        return 'Access denied. You don\'t have permission.';
      case 404:
        return 'Resource not found.';
      case 409:
        return 'Resource already exists.';
      case 422:
        return 'Validation failed. Please check your input.';
      case 429:
        return 'Too many requests. Please wait and try again.';
      case 500:
        return 'Server error. Please try again later.';
      default:
        return 'An error occurred. Please try again.';
    }
  }

  @override
  String toString() => 'ApiException($code): $message';
}

/// Token refresh callback type
typedef TokenRefreshCallback = Future<String?> Function();

/// Main API Service class
class ApiService {
  late final Dio _dio;
  final ApiServiceConfig config;
  String? _accessToken;
  String? _refreshToken;
  TokenRefreshCallback? _onTokenRefresh;
  bool _isRefreshing = false;
  final List<RequestOptions> _pendingRequests = [];

  ApiService({this.config = const ApiServiceConfig()}) {
    _dio = _createDio();
  }

  Dio get dio => _dio;

  /// Set token refresh callback
  void setTokenRefreshCallback(TokenRefreshCallback callback) {
    _onTokenRefresh = callback;
  }

  /// Set authentication tokens
  void setTokens({String? accessToken, String? refreshToken}) {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    if (accessToken != null) {
      _dio.options.headers['Authorization'] = 'Bearer $accessToken';
    }
  }

  /// Clear authentication tokens
  void clearTokens() {
    _accessToken = null;
    _refreshToken = null;
    _dio.options.headers.remove('Authorization');
  }

  /// Check if user is authenticated
  bool get isAuthenticated => _accessToken != null;

  Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: config.baseUrl,
        connectTimeout: config.connectTimeout,
        receiveTimeout: config.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Client-Version': AppConstants.appVersion,
          'X-Platform': Platform.operatingSystem,
        },
      ),
    );

    dio.interceptors.addAll([
      _AuthInterceptor(this),
      if (config.enableLogging) _LoggingInterceptor(),
      _ErrorInterceptor(),
    ]);

    return dio;
  }

  /// Generic GET request
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic>)? parser,
    bool useMockData = false,
  }) async {
    if (useMockData || config.enableMockData) {
      return _getMockResponse<T>(path, queryParameters);
    }

    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
      );
      return _parseResponse<T>(response, parser);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Generic POST request
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic>)? parser,
    bool useMockData = false,
  }) async {
    if (useMockData || config.enableMockData) {
      return _getMockResponse<T>(path, queryParameters, method: 'POST', body: data);
    }

    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return _parseResponse<T>(response, parser);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Generic PUT request
  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic>)? parser,
    bool useMockData = false,
  }) async {
    if (useMockData || config.enableMockData) {
      return _getMockResponse<T>(path, queryParameters, method: 'PUT', body: data);
    }

    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return _parseResponse<T>(response, parser);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Generic PATCH request
  Future<ApiResponse<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic>)? parser,
    bool useMockData = false,
  }) async {
    if (useMockData || config.enableMockData) {
      return _getMockResponse<T>(path, queryParameters, method: 'PATCH', body: data);
    }

    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return _parseResponse<T>(response, parser);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Generic DELETE request
  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic>)? parser,
    bool useMockData = false,
  }) async {
    if (useMockData || config.enableMockData) {
      return _getMockResponse<T>(path, queryParameters, method: 'DELETE');
    }

    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return _parseResponse<T>(response, parser);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Upload file with progress
  Future<ApiResponse<T>> uploadFile<T>(
    String path, {
    required String filePath,
    required String fileField,
    Map<String, dynamic>? additionalFields,
    void Function(int, int)? onSendProgress,
    T Function(Map<String, dynamic>)? parser,
  }) async {
    try {
      final formData = FormData.fromMap({
        fileField: await MultipartFile.fromFile(filePath),
        ...?additionalFields,
      });

      final response = await _dio.post(
        path,
        data: formData,
        onSendProgress: onSendProgress,
      );
      return _parseResponse<T>(response, parser);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Download file with progress
  Future<void> downloadFile(
    String path,
    String savePath, {
    void Function(int, int)? onReceiveProgress,
  }) async {
    try {
      await _dio.download(
        path,
        savePath,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  ApiResponse<T> _parseResponse<T>(
    Response response, {
    T Function(Map<String, dynamic>)? parser,
  }) {
    final data = response.data;

    if (data is Map<String, dynamic>) {
      final success = data['success'] == true;
      final responseData = data['data'];
      final meta = data['meta'] as Map<String, dynamic>?;

      if (!success) {
        throw ApiException(
          code: data['error']?['code'] ?? 'UNKNOWN_ERROR',
          message: data['error']?['message'] ?? 'An error occurred',
          details: data['error']?['details'],
          statusCode: response.statusCode,
        );
      }

      T? parsedData;
      if (responseData != null && parser != null) {
        if (responseData is List) {
          parsedData = responseData.map((e) => parser(e as Map<String, dynamic>)).toList() as T;
        } else {
          parsedData = parser(responseData as Map<String, dynamic>);
        }
      }

      return ApiResponse<T>(
        success: true,
        data: parsedData ?? responseData as T?,
        meta: meta != null ? PaginationMeta.fromJson(meta) : null,
      );
    }

    return ApiResponse<T>(success: true, data: data as T?);
  }

  Future<ApiResponse<T>> _getMockResponse<T>(
    String path,
    Map<String, dynamic>? queryParameters, {
    String method = 'GET',
    dynamic body,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final mockData = MockDataProvider.getMockData(path, method, queryParameters, body);

    if (mockData == null) {
      return ApiResponse<T>(
        success: true,
        data: null,
        message: 'Mock data not available for this endpoint',
      );
    }

    if (T.toString().contains('List')) {
      final list = (mockData as List).map((e) => e as T).toList();
      return ApiResponse<T>(
        success: true,
        data: list as T,
        meta: PaginationMeta(
          page: 1,
          limit: 20,
          total: list.length,
          totalPages: 1,
        ),
      );
    }

    return ApiResponse<T>(
      success: true,
      data: mockData as T?,
    );
  }

  /// Handle token refresh
  Future<void> handleTokenRefresh() async {
    if (_isRefreshing) return;
    _isRefreshing = true;

    try {
      if (_onTokenRefresh != null && _refreshToken != null) {
        final newAccessToken = await _onTokenRefresh!();
        if (newAccessToken != null) {
          _accessToken = newAccessToken;
          _dio.options.headers['Authorization'] = 'Bearer $newAccessToken';

          for (final request in _pendingRequests) {
            request.headers['Authorization'] = 'Bearer $newAccessToken';
          }
        }
      }
    } finally {
      _pendingRequests.clear();
      _isRefreshing = false;
    }
  }
}

/// Auth interceptor for adding tokens
class _AuthInterceptor extends Interceptor {
  final ApiService apiService;

  _AuthInterceptor(this.apiService);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (apiService._accessToken != null) {
      options.headers['Authorization'] = 'Bearer ${apiService._accessToken}';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && apiService._refreshToken != null) {
      try {
        await apiService.handleTokenRefresh();
        
        final retryOptions = err.requestOptions;
        retryOptions.headers['Authorization'] = 'Bearer ${apiService._accessToken}';
        
        final response = await Dio().fetch(retryOptions);
        handler.resolve(response);
        return;
      } catch (e) {
        apiService.clearTokens();
      }
    }
    handler.next(err);
  }
}

/// Logging interceptor for debugging
class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    AppLogger.debug('API Request: ${options.method} ${options.path}');
    AppLogger.debug('Headers: ${options.headers}');
    if (options.data != null) {
      AppLogger.debug('Body: ${options.data}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    AppLogger.debug('API Response: ${response.statusCode} ${response.requestOptions.path}');
    AppLogger.debug('Data: ${response.data}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppLogger.error('API Error: ${err.message}', err: err);
    handler.next(err);
  }
}

/// Error handling interceptor
class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppLogger.error('API Error: ${err.type}', err: err);
    handler.next(err);
  }
}

/// Pagination meta model
class PaginationMeta {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  PaginationMeta({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 20,
      total: json['total'] ?? 0,
      totalPages: json['totalPages'] ?? 1,
    );
  }

  bool get hasMore => page < totalPages;
}

/// Mock data provider
class MockDataProvider {
  static final Map<String, Map<String, dynamic>> _mockData = {
    '/api/v1/auth/me': {
      'success': true,
      'data': {
        'id': 'usr_mock_123',
        'email': 'demo@fintrack.app',
        'fullName': 'Demo User',
        'avatar': 'https://i.pravatar.cc/150?u=demo',
        'currency': 'IDR',
        'timezone': 'Asia/Jakarta',
        'pinEnabled': true,
        'biometricEnabled': false,
        'emailVerified': true,
        'settings': {
          'darkMode': false,
          'notifications': true,
          'language': 'id',
        },
        'createdAt': '2024-01-01T00:00:00Z',
        'updatedAt': '2024-01-15T00:00:00Z',
      },
    },
    '/api/v1/accounts': {
      'success': true,
      'data': [
        {
          'id': 'acc_1',
          'name': 'Bank BCA',
          'type': 'bank',
          'icon': 'account_balance',
          'color': '#1E3A5F',
          'balance': 15000000.0,
          'currency': 'IDR',
          'isActive': true,
          'createdAt': '2024-01-01T00:00:00Z',
        },
        {
          'id': 'acc_2',
          'name': 'OVO',
          'type': 'ewallet',
          'icon': 'smartphone',
          'color': '#6B3FA0',
          'balance': 2500000.0,
          'currency': 'IDR',
          'isActive': true,
          'createdAt': '2024-01-01T00:00:00Z',
        },
        {
          'id': 'acc_3',
          'name': 'Tunai',
          'type': 'cash',
          'icon': 'wallet',
          'color': '#22C55E',
          'balance': 500000.0,
          'currency': 'IDR',
          'isActive': true,
          'createdAt': '2024-01-01T00:00:00Z',
        },
      ],
      'meta': {'page': 1, 'limit': 20, 'total': 3, 'totalPages': 1},
    },
    '/api/v1/transactions': {
      'success': true,
      'data': [
        {
          'id': 'txn_1',
          'type': 'expense',
          'amount': 75000.0,
          'categoryId': 'cat_1',
          'categoryName': 'Makanan',
          'categoryIcon': 'restaurant',
          'categoryColor': '#EF4444',
          'accountId': 'acc_1',
          'accountName': 'Bank BCA',
          'description': 'Makan siang tim',
          'date': '2024-01-15',
          'createdAt': '2024-01-15T12:30:00Z',
        },
        {
          'id': 'txn_2',
          'type': 'income',
          'amount': 15000000.0,
          'categoryId': 'cat_10',
          'categoryName': 'Gaji',
          'categoryIcon': 'briefcase',
          'categoryColor': '#10B981',
          'accountId': 'acc_1',
          'accountName': 'Bank BCA',
          'description': 'Gaji Bulanan Januari',
          'date': '2024-01-10',
          'createdAt': '2024-01-10T08:00:00Z',
        },
        {
          'id': 'txn_3',
          'type': 'expense',
          'amount': 150000.0,
          'categoryId': 'cat_2',
          'categoryName': 'Transportasi',
          'categoryIcon': 'car',
          'categoryColor': '#F59E0B',
          'accountId': 'acc_2',
          'accountName': 'OVO',
          'description': 'Grab ke kantor',
          'date': '2024-01-14',
          'createdAt': '2024-01-14T07:30:00Z',
        },
      ],
      'meta': {'page': 1, 'limit': 20, 'total': 3, 'totalPages': 1},
    },
    '/api/v1/goals': {
      'success': true,
      'data': [
        {
          'id': 'goal_1',
          'name': 'Dana Darurat',
          'targetAmount': 36000000.0,
          'currentAmount': 18000000.0,
          'deadline': '2024-12-31',
          'icon': 'shield',
          'color': '#2196F3',
          'status': 'in_progress',
          'progress': 50.0,
          'createdAt': '2024-01-01T00:00:00Z',
        },
        {
          'id': 'goal_2',
          'name': 'Liburan',
          'targetAmount': 10000000.0,
          'currentAmount': 5000000.0,
          'deadline': '2024-06-30',
          'icon': 'flight',
          'color': '#4CAF50',
          'status': 'in_progress',
          'progress': 50.0,
          'createdAt': '2024-01-01T00:00:00Z',
        },
      ],
      'meta': {'page': 1, 'limit': 20, 'total': 2, 'totalPages': 1},
    },
    '/api/v1/portfolio': {
      'success': true,
      'data': {
        'totalInvested': 50000000.0,
        'currentValue': 54500000.0,
        'totalProfitLoss': 4500000.0,
        'totalProfitLossPercent': 9.0,
        'dayChange': 250000.0,
        'dayChangePercent': 0.46,
        'holdings': [
          {
            'id': 'hold_1',
            'symbol': 'BBCA.JK',
            'companyName': 'Bank Central Asia',
            'shares': 100.0,
            'averageBuyPrice': 8500.0,
            'currentPrice': 9200.0,
            'totalInvested': 850000.0,
            'currentValue': 920000.0,
            'profitLoss': 70000.0,
            'profitLossPercent': 8.24,
            'sector': 'Financial Services',
          },
        ],
      },
    },
    '/api/v1/dashboard/summary': {
      'success': true,
      'data': {
        'totalBalance': 18000000.0,
        'monthlyIncome': 15000000.0,
        'monthlyExpense': 2500000.0,
        'totalSavings': 23000000.0,
        'portfolioValue': 54500000.0,
        'netWorth': 72500000.0,
        'savingsRate': 83.33,
        'recentTransactions': [],
        'topCategories': [],
        'insights': [
          {
            'type': 'positive',
            'title': 'Pengeluaran Lebih Rendah',
            'message': 'Pengeluaran bulan ini 15% lebih rendah dari biasanya',
          },
        ],
      },
    },
    '/api/v1/statistics/spending': {
      'success': true,
      'data': {
        'totalSpending': 2500000.0,
        'transactionCount': 25,
        'averageTransaction': 100000.0,
        'byCategory': [
          {
            'categoryId': 'cat_1',
            'categoryName': 'Makanan',
            'total': 800000.0,
            'percentage': 32.0,
            'transactionCount': 10,
          },
          {
            'categoryId': 'cat_2',
            'categoryName': 'Transportasi',
            'total': 500000.0,
            'percentage': 20.0,
            'transactionCount': 8,
          },
        ],
        'byDay': [
          {'date': '2024-01-15', 'total': 150000.0},
          {'date': '2024-01-14', 'total': 250000.0},
        ],
      },
    },
    '/api/v1/categories': {
      'success': true,
      'data': {
        'income': [
          {
            'id': 'cat_10',
            'name': 'Gaji',
            'icon': 'briefcase',
            'color': '#10B981',
            'type': 'income',
          },
          {
            'id': 'cat_11',
            'name': 'Freelance',
            'icon': 'laptop',
            'color': '#F59E0B',
            'type': 'income',
          },
        ],
        'expense': [
          {
            'id': 'cat_1',
            'name': 'Makanan',
            'icon': 'restaurant',
            'color': '#EF4444',
            'type': 'expense',
          },
          {
            'id': 'cat_2',
            'name': 'Transportasi',
            'icon': 'car',
            'color': '#F59E0B',
            'type': 'expense',
          },
        ],
      },
    },
  };

  static dynamic getMockData(
    String path,
    String method,
    Map<String, dynamic>? queryParameters,
    dynamic body,
  ) {
    String matchedKey = path;
    
    for (final key in _mockData.keys) {
      if (path.contains(key.replaceAll('/api/v1/', '')) || path == key) {
        matchedKey = key;
        break;
      }
    }

    final data = _mockData[matchedKey];
    if (data == null) return null;

    return data['data'];
  }
}
