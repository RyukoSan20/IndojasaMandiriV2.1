import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fintrack/config/api_config.dart';
import 'package:fintrack/models/api_response.dart';
import 'package:fintrack/utils/exceptions.dart';

class ApiService {
  final http.Client _client;
  final String _baseUrl;
  final Map<String, String> _headers;

  ApiService({
    http.Client? client,
    String? baseUrl,
    String? authToken,
  })  : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? ApiConfig.baseUrl,
        _headers = {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        };

  void updateAuthToken(String token) {
    _headers['Authorization'] = 'Bearer $token';
  }

  void removeAuthToken() {
    _headers.remove('Authorization');
  }

  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? queryParams,
    T Function(dynamic)? parser,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParams);
      final response = await _client.get(uri, headers: _headers);
      return _handleResponse<T>(response, parser);
    } on http.ClientException catch (e) {
      throw NetworkException('Network error: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Unexpected error: $e');
    }
  }

  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(dynamic)? parser,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      final response = await _client.post(
        uri,
        headers: _headers,
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse<T>(response, parser);
    } on http.ClientException catch (e) {
      throw NetworkException('Network error: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Unexpected error: $e');
    }
  }

  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(dynamic)? parser,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      final response = await _client.put(
        uri,
        headers: _headers,
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse<T>(response, parser);
    } on http.ClientException catch (e) {
      throw NetworkException('Network error: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Unexpected error: $e');
    }
  }

  Future<ApiResponse<T>> patch<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(dynamic)? parser,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      final response = await _client.patch(
        uri,
        headers: _headers,
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse<T>(response, parser);
    } on http.ClientException catch (e) {
      throw NetworkException('Network error: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Unexpected error: $e');
    }
  }

  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    T Function(dynamic)? parser,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      final response = await _client.delete(uri, headers: _headers);
      return _handleResponse<T>(response, parser);
    } on http.ClientException catch (e) {
      throw NetworkException('Network error: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Unexpected error: $e');
    }
  }

  Future<ApiResponse<T>> postFormData<T>(
    String endpoint, {
    required Map<String, dynamic> fields,
    T Function(dynamic)? parser,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(_headers);
      fields.forEach((key, value) {
        if (value is http.MultipartFile) {
          request.files.add(value);
        } else {
          request.fields[key] = value.toString();
        }
      });
      final streamedResponse = await _client.send(request);
      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse<T>(response, parser);
    } on http.ClientException catch (e) {
      throw NetworkException('Network error: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Unexpected error: $e');
    }
  }

  Future<ApiResponse<T>> uploadFile<T>(
    String endpoint, {
    required String filePath,
    required String fieldName,
    Map<String, String>? additionalFields,
    T Function(dynamic)? parser,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(_headers);
      request.files.add(await http.MultipartFile.fromPath(fieldName, filePath));
      if (additionalFields != null) {
        request.fields.addAll(additionalFields);
      }
      final streamedResponse = await _client.send(request);
      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse<T>(response, parser);
    } on http.ClientException catch (e) {
      throw NetworkException('Network error: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Unexpected error: $e');
    }
  }

  Uri _buildUri(String endpoint, [Map<String, String>? queryParams]) {
    final uri = Uri.parse('$_baseUrl$endpoint');
    if (queryParams != null && queryParams.isNotEmpty) {
      return uri.replace(queryParameters: queryParams);
    }
    return uri;
  }

  ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(dynamic)? parser,
  ) {
    final statusCode = response.statusCode;
    dynamic body;
    try {
      if (response.body.isNotEmpty) {
        body = jsonDecode(response.body);
      }
    } catch (e) {
      body = response.body;
    }

    if (statusCode >= 200 && statusCode < 300) {
      final data = parser != null && body != null ? parser(body) : body;
      return ApiResponse<T>.success(data as T?, body);
    }

    final errorMessage = _extractErrorMessage(body);
    switch (statusCode) {
      case 400:
        throw BadRequestException(errorMessage);
      case 401:
        throw UnauthorizedException(errorMessage);
      case 403:
        throw ForbiddenException(errorMessage);
      case 404:
        throw NotFoundException(errorMessage);
      case 422:
        throw ValidationException(errorMessage, body);
      case 429:
        throw RateLimitException(errorMessage);
      case 500:
      case 502:
      case 503:
        throw ServerException(errorMessage, statusCode);
      default:
        throw ApiException(errorMessage, statusCode);
    }
  }

  String _extractErrorMessage(dynamic body) {
    if (body == null) return 'Unknown error occurred';
    if (body is String) return body;
    if (body is Map) {
      if (body.containsKey('message')) return body['message'].toString();
      if (body.containsKey('error')) return body['error'].toString();
      if (body.containsKey('errors') && body['errors'] is List) {
        return (body['errors'] as List).join(', ');
      }
    }
    return 'Unknown error occurred';
  }

  void dispose() {
    _client.close();
  }
}

class AuthApiService extends ApiService {
  AuthApiService({String? baseUrl}) : super(baseUrl: baseUrl);

  Future<ApiResponse<Map<String, dynamic>>> login({
    required String email,
    required String password,
  }) async {
    return post<Map<String, dynamic>>(
      '/auth/login',
      body: {'email': email, 'password': password},
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> register({
    required String email,
    required String password,
    required String name,
  }) async {
    return post<Map<String, dynamic>>(
      '/auth/register',
      body: {'email': email, 'password': password, 'name': name},
    );
  }

  Future<ApiResponse<void>> logout() async {
    return post<void>('/auth/logout');
  }

  Future<ApiResponse<Map<String, dynamic>>> refreshToken(String refreshToken) async {
    return post<Map<String, dynamic>>(
      '/auth/refresh',
      body: {'refresh_token': refreshToken},
    );
  }

  Future<ApiResponse<void>> forgotPassword(String email) async {
    return post<void>(
      '/auth/forgot-password',
      body: {'email': email},
    );
  }

  Future<ApiResponse<void>> resetPassword({
    required String token,
    required String password,
  }) async {
    return post<void>(
      '/auth/reset-password',
      body: {'token': token, 'password': password},
    );
  }

  Future<ApiResponse<void>> verifyEmail(String token) async {
    return post<void>(
      '/auth/verify-email',
      body: {'token': token},
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> resendVerificationEmail(String email) async {
    return post<Map<String, dynamic>>(
      '/auth/resend-verification',
      body: {'email': email},
    );
  }
}

class TransactionApiService extends ApiService {
  TransactionApiService({String? baseUrl, String? authToken})
      : super(baseUrl: baseUrl, authToken: authToken);

  Future<ApiResponse<List<dynamic>>> getTransactions({
    int page = 1,
    int limit = 20,
    String? accountId,
    String? categoryId,
    DateTime? startDate,
    DateTime? endDate,
    String? type,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
      if (accountId != null) 'account_id': accountId,
      if (categoryId != null) 'category_id': categoryId,
      if (startDate != null) 'start_date': startDate.toIso8601String(),
      if (endDate != null) 'end_date': endDate.toIso8601String(),
      if (type != null) 'type': type,
    };
    return get<List<dynamic>>('/transactions', queryParams: queryParams);
  }

  Future<ApiResponse<Map<String, dynamic>>> getTransaction(String id) async {
    return get<Map<String, dynamic>>('/transactions/$id');
  }

  Future<ApiResponse<Map<String, dynamic>>> createTransaction({
    required String accountId,
    required String categoryId,
    required double amount,
    required String type,
    required String description,
    DateTime? date,
    String? notes,
    List<String>? tags,
  }) async {
    return post<Map<String, dynamic>>(
      '/transactions',
      body: {
        'account_id': accountId,
        'category_id': categoryId,
        'amount': amount,
        'type': type,
        'description': description,
        if (date != null) 'date': date.toIso8601String(),
        if (notes != null) 'notes': notes,
        if (tags != null) 'tags': tags,
      },
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> updateTransaction(
    String id, {
    String? accountId,
    String? categoryId,
    double? amount,
    String? type,
    String? description,
    DateTime? date,
    String? notes,
    List<String>? tags,
  }) async {
    return put<Map<String, dynamic>>(
      '/transactions/$id',
      body: {
        if (accountId != null) 'account_id': accountId,
        if (categoryId != null) 'category_id': categoryId,
        if (amount != null) 'amount': amount,
        if (type != null) 'type': type,
        if (description != null) 'description': description,
        if (date != null) 'date': date.toIso8601String(),
        if (notes != null) 'notes': notes,
        if (tags != null) 'tags': tags,
      },
    );
  }

  Future<ApiResponse<void>> deleteTransaction(String id) async {
    return delete<void>('/transactions/$id');
  }

  Future<ApiResponse<List<dynamic>>> getTransactionStats({
    DateTime? startDate,
    DateTime? endDate,
    String? groupBy,
  }) async {
    final queryParams = <String, String>{
      if (startDate != null) 'start_date': startDate.toIso8601String(),
      if (endDate != null) 'end_date': endDate.toIso8601String(),
      if (groupBy != null) 'group_by': groupBy,
    };
    return get<List<dynamic>>('/transactions/stats', queryParams: queryParams);
  }

  Future<ApiResponse<Map<String, dynamic>>> bulkCreateTransactions(
    List<Map<String, dynamic>> transactions,
  ) async {
    return post<Map<String, dynamic>>(
      '/transactions/bulk',
      body: {'transactions': transactions},
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> bulkDeleteTransactions(
    List<String> ids,
  ) async {
    return delete<Map<String, dynamic>>(
      '/transactions/bulk',
      queryParams: {'ids': ids.join(',')},
    );
  }
}

class AccountApiService extends ApiService {
  AccountApiService({String? baseUrl, String? authToken})
      : super(baseUrl: baseUrl, authToken: authToken);

  Future<ApiResponse<List<dynamic>>> getAccounts() async {
    return get<List<dynamic>>('/accounts');
  }

  Future<ApiResponse<Map<String, dynamic>>> getAccount(String id) async {
    return get<Map<String, dynamic>>('/accounts/$id');
  }

  Future<ApiResponse<Map<String, dynamic>>> createAccount({
    required String name,
    required String type,
    required double balance,
    String? currency,
    String? color,
    String? icon,
    String? institution,
    String? notes,
  }) async {
    return post<Map<String, dynamic>>(
      '/accounts',
      body: {
        'name': name,
        'type': type,
        'balance': balance,
        if (currency != null) 'currency': currency,
        if (color != null) 'color': color,
        if (icon != null) 'icon': icon,
        if (institution != null) 'institution': institution,
        if (notes != null) 'notes': notes,
      },
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> updateAccount(
    String id, {
    String? name,
    String? type,
    double? balance,
    String? currency,
    String? color,
    String? icon,
    String? institution,
    String? notes,
  }) async {
    return put<Map<String, dynamic>>(
      '/accounts/$id',
      body: {
        if (name != null) 'name': name,
        if (type != null) 'type': type,
        if (balance != null) 'balance': balance,
        if (currency != null) 'currency': currency,
        if (color != null) 'color': color,
        if (icon != null) 'icon': icon,
        if (institution != null) 'institution': institution,
        if (notes != null) 'notes': notes,
      },
    );
  }

  Future<ApiResponse<void>> deleteAccount(String id) async {
    return delete<void>('/accounts/$id');
  }

  Future<ApiResponse<Map<String, dynamic>>> getAccountBalance(String id) async {
    return get<Map<String, dynamic>>('/accounts/$id/balance');
  }

  Future<ApiResponse<List<dynamic>>> getAccountTransactions(
    String id, {
    int page = 1,
    int limit = 20,
  }) async {
    return get<List<dynamic>>(
      '/accounts/$id/transactions',
      queryParams: {'page': page.toString(), 'limit': limit.toString()},
    );
  }

  Future<ApiResponse<List<dynamic>>> getAccountSummary() async {
    return get<List<dynamic>>('/accounts/summary');
  }
}

class CategoryApiService extends ApiService {
  CategoryApiService({String? baseUrl, String? authToken})
      : super(baseUrl: baseUrl, authToken: authToken);

  Future<ApiResponse<List<dynamic>>> getCategories({String? type}) async {
    return get<List<dynamic>>(
      '/categories',
      queryParams: type != null ? {'type': type} : null,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> getCategory(String id) async {
    return get<Map<String, dynamic>>('/categories/$id');
  }

  Future<ApiResponse<Map<String, dynamic>>> createCategory({
    required String name,
    required String type,
    required String icon,
    required String color,
    String? parentId,
    String? description,
  }) async {
    return post<Map<String, dynamic>>(
      '/categories',
      body: {
        'name': name,
        'type': type,
        'icon': icon,
        'color': color,
        if (parentId != null) 'parent_id': parentId,
        if (description != null) 'description': description,
      },
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> updateCategory(
    String id, {
    String? name,
    String? type,
    String? icon,
    String? color,
    String? parentId,
    String? description,
  }) async {
    return put<Map<String, dynamic>>(
      '/categories/$id',
      body: {
        if (name != null) 'name': name,
        if (type != null) 'type': type,
        if (icon != null) 'icon': icon,
        if (color != null) 'color': color,
        if (parentId != null) 'parent_id': parentId,
        if (description != null) 'description': description,
      },
    );
  }

  Future<ApiResponse<void>> deleteCategory(String id) async {
    return delete<void>('/categories/$id');
  }
}

class SavingsGoalApiService extends ApiService {
  SavingsGoalApiService({String? baseUrl, String? authToken})
      : super(baseUrl: baseUrl, authToken: authToken);

  Future<ApiResponse<List<dynamic>>> getSavingsGoals() async {
    return get<List<dynamic>>('/savings-goals');
  }

  Future<ApiResponse<Map<String, dynamic>>> getSavingsGoal(String id) async {
    return get<Map<String, dynamic>>('/savings-goals/$id');
  }

  Future<ApiResponse<Map<String, dynamic>>> createSavingsGoal({
    required String name,
    required double targetAmount,
    required DateTime targetDate,
    String? description,
    String? color,
    String? icon,
  }) async {
    return post<Map<String, dynamic>>(
      '/savings-goals',
      body: {
        'name': name,
        'target_amount': targetAmount,
        'target_date': targetDate.toIso8601String(),
        if (description != null) 'description': description,
        if (color != null) 'color': color,
        if (icon != null) 'icon': icon,
      },
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> updateSavingsGoal(
    String id, {
    String? name,
    double? targetAmount,
    DateTime? targetDate,
    String? description,
    String? color,
    String? icon,
  }) async {
    return put<Map<String, dynamic>>(
      '/savings-goals/$id',
      body: {
        if (name != null) 'name': name,
        if (targetAmount != null) 'target_amount': targetAmount,
        if (targetDate != null) 'target_date': targetDate.toIso8601String(),
        if (description != null) 'description': description,
        if (color != null) 'color': color,
        if (icon != null) 'icon': icon,
      },
    );
  }

  Future<ApiResponse<void>> deleteSavingsGoal(String id) async {
    return delete<void>('/savings-goals/$id');
  }

  Future<ApiResponse<Map<String, dynamic>>> addContribution(
    String id, {
    required double amount,
    String? notes,
  }) async {
    return post<Map<String, dynamic>>(
      '/savings-goals/$id/contributions',
      body: {
        'amount': amount,
        if (notes != null) 'notes': notes,
      },
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> withdrawFromGoal(
    String id, {
    required double amount,
    String? notes,
  }) async {
    return post<Map<String, dynamic>>(
      '/savings-goals/$id/withdrawals',
      body: {
        'amount': amount,
        if (notes != null) 'notes': notes,
      },
    );
  }

  Future<ApiResponse<List<dynamic>>> getSavingsGoalContributions(String id) async {
    return get<List<dynamic>>('/savings-goals/$id/contributions');
  }

  Future<ApiResponse<Map<String, dynamic>>> getSavingsGoalProgress(String id) async {
    return get<Map<String, dynamic>>('/savings-goals/$id/progress');
  }
}

class PortfolioApiService extends ApiService {
  PortfolioApiService({String? baseUrl, String? authToken})
      : super(baseUrl: baseUrl, authToken: authToken);

  Future<ApiResponse<List<dynamic>>> getHoldings() async {
    return get<List<dynamic>>('/portfolio/holdings');
  }

  Future<ApiResponse<Map<String, dynamic>>> getHolding(String symbol) async {
    return get<Map<String, dynamic>>('/portfolio/holdings/$symbol');
  }

  Future<ApiResponse<Map<String, dynamic>>> addHolding({
    required String symbol,
    required int quantity,
    required double purchasePrice,
    required DateTime purchaseDate,
    String? notes,
  }) async {
    return post<Map<String, dynamic>>(
      '/portfolio/holdings',
      body: {
        'symbol': symbol,
        'quantity': quantity,
        'purchase_price': purchasePrice,
        'purchase_date': purchaseDate.toIso8601String(),
        if (notes != null) 'notes': notes,
      },
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> updateHolding(
    String symbol, {
    int? quantity,
    double? purchasePrice,
    DateTime? purchaseDate,
    String? notes,
  }) async {
    return put<Map<String, dynamic>>(
      '/portfolio/holdings/$symbol',
      body: {
        if (quantity != null) 'quantity': quantity,
        if (purchasePrice != null) 'purchase_price': purchasePrice,
        if (purchaseDate != null) 'purchase_date': purchaseDate.toIso8601String(),
        if (notes != null) 'notes': notes,
      },
    );
  }

  Future<ApiResponse<void>> deleteHolding(String symbol) async {
    return delete<void>('/portfolio/holdings/$symbol');
  }

  Future<ApiResponse<List<dynamic>>> getTransactions({
    String? symbol,
    int page = 1,
    int limit = 20,
  }) async {
    return get<List<dynamic>>(
      '/portfolio/transactions',
      queryParams: {
        'page': page.toString(),
        'limit': limit.toString(),
        if (symbol != null) 'symbol': symbol,
      },
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> addTransaction({
    required String symbol,
    required String type,
    required int quantity,
    required double price,
    required DateTime date,
    double? fees,
    String? notes,
  }) async {
    return post<Map<String, dynamic>>(
      '/portfolio/transactions',
      body: {
        'symbol': symbol,
        'type': type,
        'quantity': quantity,
        'price': price,
        'date': date.toIso8601String(),
        if (fees != null) 'fees': fees,
        if (notes != null) 'notes': notes,
      },
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> getPortfolioSummary() async {
    return get<Map<String, dynamic>>('/portfolio/summary');
  }

  Future<ApiResponse<Map<String, dynamic>>> getPortfolioPerformance({
    DateTime? startDate,
    DateTime? endDate,
    String? period,
  }) async {
    return get<Map<String, dynamic>>(
      '/portfolio/performance',
      queryParams: {
        if (startDate != null) 'start_date': startDate.toIso8601String(),
        if (endDate != null) 'end_date': endDate.toIso8601String(),
        if (period != null) 'period': period,
      },
    );
  }

  Future<ApiResponse<List<dynamic>>> getPortfolioAllocation() async {
    return get<List<dynamic>>('/portfolio/allocation');
  }

  Future<ApiResponse<Map<String, dynamic>>> getPortfolioValue({DateTime? date}) async {
    return get<Map<String, dynamic>>(
      '/portfolio/value',
      queryParams: date != null ? {'date': date.toIso8601String()} : null,
    );
  }
}

class StockApiService extends ApiService {
  StockApiService({String? baseUrl, String? authToken})
      : super(baseUrl: baseUrl, authToken: authToken);

  Future<ApiResponse<Map<String, dynamic>>> searchStocks(String query) async {
    return get<Map<String, dynamic>>(
      '/stocks/search',
      queryParams: {'q': query},
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> getStockQuote(String symbol) async {
    return get<Map<String, dynamic>>('/stocks/$symbol/quote');
  }

  Future<ApiResponse<Map<String, dynamic>>> getStockInfo(String symbol) async {
    return get<Map<String, dynamic>>('/stocks/$symbol/info');
  }

  Future<ApiResponse<List<dynamic>>> getStockHistoricalData(
    String symbol, {
    required String interval,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return get<List<dynamic>>(
      '/stocks/$symbol/historical',
      queryParams: {
        'interval': interval,
        if (startDate != null) 'start_date': startDate.toIso8601String(),
        if (endDate != null) 'end_date': endDate.toIso8601String(),
      },
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> getStockFinancials(String symbol) async {
    return get<Map<String, dynamic>>('/stocks/$symbol/financials');
  }

  Future<ApiResponse<Map<String, dynamic>>> getStockDividends(String symbol) async {
    return get<Map<String, dynamic>>('/stocks/$symbol/dividends');
  }

  Future<ApiResponse<List<dynamic>>> getMarketMovers() async {
    return get<List<dynamic>>('/stocks/market/movers');
  }

  Future<ApiResponse<List<dynamic>>> getMarketIndices() async {
    return get<List<dynamic>>('/stocks/market/indices');
  }

  Future<ApiResponse<Map<String, dynamic>>> getStockAnalysis(String symbol) async {
    return get<Map<String, dynamic>>('/stocks/$symbol/analysis');
  }
}

class BudgetApiService extends ApiService {
  BudgetApiService({String? baseUrl, String? authToken})
      : super(baseUrl: baseUrl, authToken: authToken);

  Future<ApiResponse<List<dynamic>>> getBudgets() async {
    return get<List<dynamic>>('/budgets');
  }

  Future<ApiResponse<Map<String, dynamic>>> getBudget(String id) async {
    return get<Map<String, dynamic>>('/budgets/$id');
  }

  Future<ApiResponse<Map<String, dynamic>>> createBudget({
    required String name,
    required double amount,
    required String period,
    required String categoryId,
    DateTime? startDate,
  }) async {
    return post<Map<String, dynamic>>(
      '/budgets',
      body: {
        'name': name,
        'amount': amount,
        'period': period,
        'category_id': categoryId,
        if (startDate != null) 'start_date': startDate.toIso8601String(),
      },
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> updateBudget(
    String id, {
    String? name,
    double? amount,
    String? period,
    String? categoryId,
  }) async {
    return put<Map<String, dynamic>>(
      '/budgets/$id',
      body: {
        if (name != null) 'name': name,
        if (amount != null) 'amount': amount,
        if (period != null) 'period': period,
        if (categoryId != null) 'category_id': categoryId,
      },
    );
  }

  Future<ApiResponse<void>> deleteBudget(String id) async {
    return delete<void>('/budgets/$id');
  }

  Future<ApiResponse<Map<String, dynamic>>> getBudgetProgress(String id) async {
    return get<Map<String, dynamic>>('/budgets/$id/progress');
  }

  Future<ApiResponse<List<dynamic>>> getBudgetAlerts() async {
    return get<List<dynamic>>('/budgets/alerts');
  }
}

class AnalyticsApiService extends ApiService {
  AnalyticsApiService({String? baseUrl, String? authToken})
      : super(baseUrl: baseUrl, authToken: authToken);

  Future<ApiResponse<Map<String, dynamic>>> getDashboardSummary() async {
    return get<Map<String, dynamic>>('/analytics/dashboard');
  }

  Future<ApiResponse<List<dynamic>>> getExpenseBreakdown({
    DateTime? startDate,
    DateTime? endDate,
    String? groupBy,
  }) async {
    return get<List<dynamic>>(
      '/analytics/expenses/breakdown',
      queryParams: {
        if (startDate != null) 'start_date': startDate.toIso8601String(),
        if (endDate != null) 'end_date': endDate.toIso8601String(),
        if (groupBy != null) 'group_by': groupBy,
      },
    );
  }

  Future<ApiResponse<List<dynamic>>> getIncomeBreakdown({
    DateTime? startDate,
    DateTime? endDate,
    String? groupBy,
  }) async {
    return get<List<dynamic>>(
      '/analytics/income/breakdown',
      queryParams: {
        if (startDate != null) 'start_date': startDate.toIso8601String(),
        if (endDate != null) 'end_date': endDate.toIso8601String(),
        if (groupBy != null) 'group_by': groupBy,
      },
    );
  }

  Future<ApiResponse<List<dynamic>>> getCashFlowData({
    required DateTime startDate,
    required DateTime endDate,
    String? interval,
  }) async {
    return get<List<dynamic>>(
      '/analytics/cash-flow',
      queryParams: {
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
        if (interval != null) 'interval': interval,
      },
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> getNetWorthHistory({
    int months = 12,
  }) async {
    return get<Map<String, dynamic>>(
      '/analytics/net-worth',
      queryParams: {'months': months.toString()},
    );
  }

  Future<ApiResponse<List<dynamic>>> getSpendingTrends({
    int months = 6,
  }) async {
    return get<List<dynamic>>(
      '/analytics/trends/spending',
      queryParams: {'months': months.toString()},
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> getFinancialHealth() async {
    return get<Map<String, dynamic>>('/analytics/health');
  }

  Future<ApiResponse<List<dynamic>>> getSavingsRate({int months = 12}) async {
    return get<List<dynamic>>(
      '/analytics/savings-rate',
      queryParams: {'months': months.toString()},
    );
  }
}

class UserApiService extends ApiService {
  UserApiService({String? baseUrl, String? authToken})
      : super(baseUrl: baseUrl, authToken: authToken);

  Future<ApiResponse<Map<String, dynamic>>> getProfile() async {
    return get<Map<String, dynamic>>('/user/profile');
  }

  Future<ApiResponse<Map<String, dynamic>>> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? avatar,
    String? currency,
    String? timezone,
    String? language,
  }) async {
    return put<Map<String, dynamic>>(
      '/user/profile',
      body: {
        if (name != null) 'name': name,
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
        if (avatar != null) 'avatar': avatar,
        if (currency != null) 'currency': currency,
        if (timezone != null) 'timezone': timezone,
        if (language != null) 'language': language,
      },
    );
  }

  Future<ApiResponse<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    return post<void>(
      '/user/change-password',
      body: {
        'current_password': currentPassword,
        'new_password': newPassword,
      },
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> getPreferences() async {
    return get<Map<String, dynamic>>('/user/preferences');
  }

  Future<ApiResponse<Map<String, dynamic>>> updatePreferences(
    Map<String, dynamic> preferences,
  ) async {
    return put<Map<String, dynamic>>('/user/preferences', body: preferences);
  }

  Future<ApiResponse<void>> deleteAccount() async {
    return delete<void>('/user/account');
  }

  Future<ApiResponse<Map<String, dynamic>>> getNotifications({
    int page = 1,
    int limit = 20,
    bool? unreadOnly,
  }) async {
    return get<Map<String, dynamic>>(
      '/user/notifications',
      queryParams: {
        'page': page.toString(),
        'limit': limit.toString(),
        if (unreadOnly != null) 'unread_only': unreadOnly.toString(),
      },
    );
  }

  Future<ApiResponse<void>> markNotificationRead(String id) async {
    return patch<void>('/user/notifications/$id');
  }

  Future<ApiResponse<void>> markAllNotificationsRead() async {
    return post<void>('/user/notifications/mark-all-read');
  }
}
