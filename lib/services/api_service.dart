// ignore_for_file: unused_import
import 'dart:async';
import 'package:dio/dio.dart';
import '../core/constants.dart';
import '../core/exceptions.dart';

/// API Service for FinTrack application
class ApiService {
  static ApiService? _instance;
  late final Dio _dio;

  String? _accessToken;
  String? _refreshToken;
  bool _useMockData = false;

  ApiService._internal() {
    _dio = Dio(_baseOptions);
    _setupInterceptors();
  }

  factory ApiService({bool useMockData = false}) {
    _instance ??= ApiService._internal();
    _instance!._useMockData = useMockData;
    return _instance!;
  }

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

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_accessToken != null) {
            options.headers['Authorization'] = 'Bearer $_accessToken';
          }
          options.headers['X-Request-ID'] = _generateRequestId();
          options.headers['X-Timezone'] = 'Asia/Jakarta';
          handler.next(options);
        },
        onResponse: (response, handler) => handler.next(response),
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            final refreshed = await _handleTokenRefresh();
            if (refreshed) {
              final retryResponse = await _retryRequest(error.requestOptions);
              return handler.resolve(retryResponse);
            }
          }
          handler.next(error);
        },
      ),
    );
  }

  void setTokens({required String accessToken, required String refreshToken}) {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
  }

  void clearTokens() {
    _accessToken = null;
    _refreshToken = null;
  }

  bool get isAuthenticated => _accessToken != null;

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
    } catch (_) {}
    clearTokens();
    return false;
  }

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

  String _generateRequestId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic>)? parser,
  }) async {
    if (_useMockData) return _getMockResponse<T>(path, 'GET', parser: parser);
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return _handleResponse<T>(response, parser);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic>)? parser,
  }) async {
    if (_useMockData) return _getMockResponse<T>(path, 'POST', parser: parser);
    try {
      final response = await _dio.post(path, data: data, queryParameters: queryParameters);
      return _handleResponse<T>(response, parser);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  ApiResponse<T> _handleResponse<T>(
    Response response,
    T Function(Map<String, dynamic>)? parser,
  ) {
    final data = response.data;
    if (data['success'] == true) {
      return ApiResponse<T>.success(
        data: parser != null && data['data'] != null ? parser(data['data']) : data['data'] as T?,
        meta: data['meta'] != null ? ResponseMeta.fromJson(data['meta']) : null,
      );
    } else {
      throw ApiException(
        code: data['error']['code'] ?? 'UNKNOWN_ERROR',
        message: data['error']['message'] ?? 'An unknown error occurred',
      );
    }
  }

  ApiException _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(code: 'TIMEOUT_ERROR', message: 'Connection timed out.');
      case DioExceptionType.connectionError:
        return ApiException(code: 'NETWORK_ERROR', message: 'No internet connection.');
      default:
        return ApiException(code: 'INTERNAL_ERROR', message: 'An internal error occurred.');
    }
  }

  Future<ApiResponse<T>> _getMockResponse<T>(
    String path,
    String method, {
    T Function(Map<String, dynamic>)? parser,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    Map<String, dynamic>? mockData;

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

    return ApiResponse<T>.success(
      data: mockData?['data'] != null && parser != null
          ? parser(mockData!['data'])
          : mockData?['data'] as T?,
      meta: mockData?['meta'] != null ? ResponseMeta.fromJson(mockData!['meta']) : null,
    );
  }

  Map<String, dynamic>? _getMockAuthData(String path, String method) => {'success': true, 'data': null};
  Map<String, dynamic>? _getMockAccountsData(String path, String method) => {'success': true, 'data': []};
  Map<String, dynamic>? _getMockTransactionsData(String path, String method) => {'success': true, 'data': []};
  Map<String, dynamic>? _getMockCategoriesData(String path, String method) => {'success': true, 'data': []};
  Map<String, dynamic>? _getMockSavingsGoalsData(String path, String method) => {'success': true, 'data': []};
  Map<String, dynamic>? _getMockPortfolioData(String path, String method) => {'success': true, 'data': []};
  Map<String, dynamic>? _getMockWatchlistData(String path, String method) => {'success': true, 'data': []};
  Map<String, dynamic>? _getMockDashboardData(String path) => {'success': true, 'data': null};
  Map<String, dynamic>? _getMockStatisticsData(String path) => {'success': true, 'data': null};
  Map<String, dynamic>? _getMockUserData(String path, String method) => {'success': true, 'data': null};
}

class ApiResponse<T> {
  final bool success;
  final T? data;
  final ResponseMeta? meta;
  final String? error;

  ApiResponse._({required this.success, this.data, this.meta, this.error});

  factory ApiResponse.success({T? data, ResponseMeta? meta}) {
    return ApiResponse._(success: true, data: data, meta: meta);
  }
}

class ResponseMeta {
  final int page;
  final int limit;
  final int total;

  ResponseMeta({required this.page, required this.limit, required this.total});

  factory ResponseMeta.fromJson(Map<String, dynamic> json) {
    return ResponseMeta(
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 20,
      total: json['total'] ?? 0,
    );
  }
}
