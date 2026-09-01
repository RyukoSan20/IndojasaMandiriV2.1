import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = ApiConstants.baseUrl;
  static const Duration _timeout = Duration(seconds: 30);

  final http.Client _client;
  String? _authToken;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<void> setAuthToken(String token) async {
    _authToken = token;
  }

  Future<void> clearAuthToken() async {
    _authToken = null;
    await SecureStorageHelper.deleteToken();
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };

  Future<ApiResponse<T>> _handleResponse<T>(
    http.Response response,
    T Function(dynamic) parser,
  ) async {
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = parser(body['data']);
        return ApiResponse.success(data);
      } else {
        final message = body['message'] ?? 'An error occurred';
        return ApiResponse.error(message, response.statusCode);
      }
    } catch (e) {
      return ApiResponse.error('Failed to parse response: $e', response.statusCode);
    }
  }

  // Authentication Methods
  Future<ApiResponse<UserModel>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse('$_baseUrl/auth/register'),
            headers: _headers,
            body: jsonEncode({
              'name': name,
              'email': email,
              'password': password,
            }),
          )
          .timeout(_timeout);

      return _handleResponse(response, (data) => UserModel.fromJson(data));
    } catch (e) {
      return ApiResponse.error('Network error: $e', 0);
    }
  }

  Future<ApiResponse<UserModel>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse('$_baseUrl/auth/login'),
            headers: _headers,
            body: jsonEncode({
              'email': email,
              'password': password,
            }),
          )
          .timeout(_timeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final token = body['token'] as String?;
        if (token != null) {
          await setAuthToken(token);
          await SecureStorageHelper.saveToken(token);
        }
        return ApiResponse.success(UserModel.fromJson(body['data']));
      } else {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        return ApiResponse.error(body['message'] ?? 'Login failed', response.statusCode);
      }
    } catch (e) {
      return ApiResponse.error('Network error: $e', 0);
    }
  }

  Future<ApiResponse<UserModel>> getCurrentUser() async {
    try {
      final response = await _client
          .get(
            Uri.parse('$_baseUrl/auth/me'),
            headers: _headers,
          )
          .timeout(_timeout);

      return _handleResponse(response, (data) => UserModel.fromJson(data));
    } catch (e) {
      return ApiResponse.error('Network error: $e', 0);
    }
  }

  Future<ApiResponse<void>> logout() async {
    try {
      await clearAuthToken();
      final response = await _client
          .post(
            Uri.parse('$_baseUrl/auth/logout'),
            headers: _headers,
          )
          .timeout(_timeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse.success(null);
      } else {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        return ApiResponse.error(body['message'] ?? 'Logout failed', response.statusCode);
      }
    } catch (e) {
      await clearAuthToken();
      return ApiResponse.success(null);
    }
  }

  // Account Methods
  Future<ApiResponse<List<AccountModel>>> getAccounts() async {
    try {
      final response = await _client
          .get(
            Uri.parse('$_baseUrl/accounts'),
            headers: _headers,
          )
          .timeout(_timeout);

      return _handleResponse(response, (data) {
        final list = data as List<dynamic>;
        return list.map((e) => AccountModel.fromJson(e as Map<String, dynamic>)).toList();
      });
    } catch (e) {
      return ApiResponse.error('Network error: $e', 0);
    }
  }

  Future<ApiResponse<AccountModel>> getAccountById(String id) async {
    try {
      final response = await _client
          .get(
            Uri.parse('$_baseUrl/accounts/$id'),
            headers: _headers,
          )
          .timeout(_timeout);

      return _handleResponse(response, (data) => AccountModel.fromJson(data));
    } catch (e) {
      return ApiResponse.error('Network error: $e', 0);
    }
  }

  Future<ApiResponse<AccountModel>> createAccount({
    required String name,
    required String type,
    required double balance,
    String? currency,
    String? description,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse('$_baseUrl/accounts'),
            headers: _headers,
            body: jsonEncode({
              'name': name,
              'type': type,
              'balance': balance,
              if (currency != null) 'currency': currency,
              if (description != null) 'description': description,
            }),
          )
          .timeout(_timeout);

      return _handleResponse(response, (data) => AccountModel.fromJson(data));
    } catch (e) {
      return ApiResponse.error('Network error: $e', 0);
    }
  }

  Future<ApiResponse<AccountModel>> updateAccount({
    required String id,
    String? name,
    String? type,
    double? balance,
    String? currency,
    String? description,
  }) async {
    try {
      final response = await _client
          .put(
            Uri.parse('$_baseUrl/accounts/$id'),
            headers: _headers,
            body: jsonEncode({
              if (name != null) 'name': name,
              if (type != null) 'type': type,
              if (balance != null) 'balance': balance,
              if (currency != null) 'currency': currency,
              if (description != null) 'description': description,
            }),
          )
          .timeout(_timeout);

      return _handleResponse(response, (data) => AccountModel.fromJson(data));
    } catch (e) {
      return ApiResponse.error('Network error: $e', 0);
    }
  }

  Future<ApiResponse<void>> deleteAccount(String id) async {
    try {
      final response = await _client
          .delete(
            Uri.parse('$_baseUrl/accounts/$id'),
            headers: _headers,
          )
          .timeout(_timeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse.success(null);
      } else {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        return ApiResponse.error(body['message'] ?? 'Delete failed', response.statusCode);
      }
    } catch (e) {
      return ApiResponse.error('Network error: $e', 0);
    }
  }

  // Transaction Methods
  Future<ApiResponse<List<TransactionModel>>> getTransactions({
    String? accountId,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (accountId != null) queryParams['account_id'] = accountId;
      if (category != null) queryParams['category'] = category;
      if (startDate != null) queryParams['start_date'] = startDate.toIso8601String();
      if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();
      if (limit != null) queryParams['limit'] = limit.toString();
      if (offset != null) queryParams['offset'] = offset.toString();

      final uri = Uri.parse('$_baseUrl/transactions').replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);
      
      final response = await _client
          .get(uri, headers: _headers)
          .timeout(_timeout);

      return _handleResponse(response, (data) {
        final list = data as List<dynamic>;
        return list.map((e) => TransactionModel.fromJson(e as Map<String, dynamic>)).toList();
      });
    } catch (e) {
      return ApiResponse.error('Network error: $e', 0);
    }
  }

  Future<ApiResponse<TransactionModel>> getTransactionById(String id) async {
    try {
      final response = await _client
          .get(
            Uri.parse('$_baseUrl/transactions/$id'),
            headers: _headers,
          )
          .timeout(_timeout);

      return _handleResponse(response, (data) => TransactionModel.fromJson(data));
    } catch (e) {
      return ApiResponse.error('Network error: $e', 0);
    }
  }

  Future<ApiResponse<TransactionModel>> createTransaction({
    required String accountId,
    required String type,
    required double amount,
    required String category,
    String? description,
    DateTime? date,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse('$_baseUrl/transactions'),
            headers: _headers,
            body: jsonEncode({
              'account_id': accountId,
              'type': type,
              'amount': amount,
              'category': category,
              if (description != null) 'description': description,
              if (date != null) 'date': date.toIso8601String(),
            }),
          )
          .timeout(_timeout);

      return _handleResponse(response, (data) => TransactionModel.fromJson(data));
    } catch (e) {
      return ApiResponse.error('Network error: $e', 0);
    }
  }

  Future<ApiResponse<TransactionModel>> updateTransaction({
    required String id,
    String? accountId,
    String? type,
    double? amount,
    String? category,
    String? description,
    DateTime? date,
  }) async {
    try {
      final response = await _client
          .put(
            Uri.parse('$_baseUrl/transactions/$id'),
            headers: _headers,
            body: jsonEncode({
              if (accountId != null) 'account_id': accountId,
              if (type != null) 'type': type,
              if (amount != null) 'amount': amount,
              if (category != null) 'category': category,
              if (description != null) 'description': description,
              if (date != null) 'date': date.toIso8601String(),
            }),
          )
          .timeout(_timeout);

      return _handleResponse(response, (data) => TransactionModel.fromJson(data));
    } catch (e) {
      return ApiResponse.error('Network error: $e', 0);
    }
  }

  Future<ApiResponse<void>> deleteTransaction(String id) async {
    try {
      final response = await _client
          .delete(
            Uri.parse('$_baseUrl/transactions/$id'),
            headers: _headers,
          )
          .timeout(_timeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse.success(null);
      } else {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        return ApiResponse.error(body['message'] ?? 'Delete failed', response.statusCode);
      }
    } catch (e) {
      return ApiResponse.error('Network error: $e', 0);
    }
  }

  Future<ApiResponse<List<TransactionModel>>> getTransactionsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _client
          .get(
            Uri.parse('$_baseUrl/transactions').replace(queryParameters: {
              'start_date': startDate.toIso8601String(),
              'end_date': endDate.toIso8601String(),
            }),
            headers: _headers,
          )
          .timeout(_timeout);

      return _handleResponse(response, (data) {
        final list = data as List<dynamic>;
        return list.map((e) => TransactionModel.fromJson(e as Map<String, dynamic>)).toList();
      });
    } catch (e) {
      return ApiResponse.error('Network error: $e', 0);
    }
  }

  // Savings Goals Methods
  Future<ApiResponse<List<SavingsGoalModel>>> getSavingsGoals() async {
    try {
      final response = await _client
          .get(
            Uri.parse('$_baseUrl/savings-goals'),
            headers: _headers,
          )
          .timeout(_timeout);

      return _handleResponse(response, (data) {
        final list = data as List<dynamic>;
        return list.map((e) => SavingsGoalModel.fromJson(e as Map<String, dynamic>)).toList();
      });
    } catch (e) {
      return ApiResponse.error('Network error: $e', 0);
    }
  }

  Future<ApiResponse<SavingsGoalModel>> getSavingsGoalById(String id) async {
    try {
      final response = await _client
          .get(
            Uri.parse('$_baseUrl/savings-goals/$id'),
            headers: _headers,
          )
          .timeout(_timeout);

      return _handleResponse(response, (data) => SavingsGoalModel.fromJson(data));
    } catch (e) {
      return ApiResponse.error('Network error: $e', 0);
    }
  }

  Future<ApiResponse<SavingsGoalModel>> createSavingsGoal({
    required String name,
    required double targetAmount,
    required DateTime targetDate,
    double? currentAmount,
    String? description,
    String? icon,
    String? color,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse('$_baseUrl/savings-goals'),
            headers: _headers,
            body: jsonEncode({
              'name': name,
              'target_amount': targetAmount,
              'target_date': targetDate.toIso8601String(),
              if (currentAmount != null) 'current_amount': currentAmount,
              if (description != null) 'description': description,
              if (icon != null) 'icon': icon,
              if (color != null) 'color': color,
            }),
          )
          .timeout(_timeout);

      return _handleResponse(response, (data) => SavingsGoalModel.fromJson(data));
    } catch (e) {
      return ApiResponse.error('Network error: $e', 0);
    }
  }

  Future<ApiResponse<SavingsGoalModel>> updateSavingsGoal({
    required String id,
    String? name,
    double? targetAmount,
    DateTime? targetDate,
    double? currentAmount,
    String? description,
    String? icon,
    String? color,
    bool? isCompleted,
  }) async {
    try {
      final response = await _client
          .put(
            Uri.parse('$_baseUrl/savings-goals/$id'),
            headers: _headers,
            body: jsonEncode({
              if (name != null) 'name': name,
              if (targetAmount != null) 'target_amount': targetAmount,
              if (targetDate != null) 'target_date': targetDate.toIso8601String(),
              if (currentAmount != null) 'current_amount': currentAmount,
              if (description != null) 'description': description,
              if (icon != null) 'icon': icon,
              if (color != null) 'color': color,
              if (isCompleted != null) 'is_completed': isCompleted,
            }),
          )
          .timeout(_timeout);

      return _handleResponse(response, (data) => SavingsGoalModel.fromJson(data));
    } catch (e) {
      return ApiResponse.error('Network error: $e', 0);
    }
  }

  Future<ApiResponse<void>> deleteSavingsGoal(String id) async {
    try {
      final response = await _client
          .delete(
            Uri.parse('$_baseUrl/savings-goals/$id'),
            headers: _headers,
          )
          .timeout(_timeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse.success(null);
      } else {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        return ApiResponse.error(body['message'] ?? 'Delete failed', response.statusCode);
      }
    } catch (e) {
      return ApiResponse.error('Network error: $e', 0);
    }
  }

  Future<ApiResponse<SavingsGoalModel>> contributeToSavingsGoal({
    required String id,
    required double amount,
    String? note,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse('$_baseUrl/savings-goals/$id/contribute'),
            headers: _headers,
            body: jsonEncode({
              'amount': amount,
              if (note != null) 'note': note,
            }),
          )
          .timeout(_timeout);

      return _handleResponse(response, (data) => SavingsGoalModel.fromJson(data));
    } catch (e) {
      return ApiResponse.error('Network error: $e', 0);
    }
  }

  // Portfolio Methods
  Future<ApiResponse<List<PortfolioModel>>> getPortfolioHoldings() async {
    try {
      final response = await _client
          .get(
            Uri.parse('$_baseUrl/portfolio/holdings'),
            headers: _headers,
          )
          .timeout(_timeout);

      return _handleResponse(response, (data) {
        final list = data as List<dynamic>;
        return list.map((e) => PortfolioModel.fromJson(e as Map<String, dynamic>)).toList();
      });
    } catch (e) {
      return ApiResponse.error('Network error: $e', 0);
    }
  }

  Future<ApiResponse<PortfolioModel>> getHoldingById(String id) async {
    try {
      final response = await _client
          .get(
            Uri.parse('$_baseUrl/portfolio/holdings/$id'),
            headers: _headers,
          )
          .timeout(_timeout);

      return _handleResponse(response, (data) => PortfolioModel.fromJson(data));
    } catch (e) {
      return ApiResponse.error('Network error: $e', 0);
    }
  }

  Future<ApiResponse<PortfolioModel>> addHolding({
    required String symbol,
    required String name,
    required int quantity,
    required double purchasePrice,
    required DateTime purchaseDate,
    String? exchange,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse('$_baseUrl/portfolio/holdings'),
            headers: _headers,
            body: jsonEncode({
              'symbol': symbol,
              'name': name,
              'quantity': quantity,
              'purchase_price': purchasePrice,
              'purchase_date': purchaseDate.toIso8601String(),
              if (exchange != null) 'exchange': exchange,
            }),
          )
          .timeout(_timeout);

      return _handleResponse(response, (data) => PortfolioModel.fromJson(data));
    } catch (e) {
      return ApiResponse.error('Network error: $e', 0);
    }
  }

  Future<ApiResponse<PortfolioModel>> updateHolding({
    required String id,
    int? quantity,
    double? purchasePrice,
    DateTime? purchaseDate,
  }) async {
    try {
      final response = await _client
          .put(
            Uri.parse('$_baseUrl/portfolio/holdings/$id'),
            headers: _headers,
            body: jsonEncode({
              if (quantity != null) 'quantity': quantity,
              if (purchasePrice != null) 'purchase_price': purchasePrice,
              if (purchaseDate != null) 'purchase_date': purchaseDate.toIso8601String(),
            }),
          )
          .timeout(_timeout);

      return _handleResponse(response, (data) => PortfolioModel.fromJson(data));
    } catch (e) {
      return ApiResponse.error('Network error: $e', 0);
    }
  }

  Future<ApiResponse<void>> deleteHolding(String id) async {
    try {
      final response = await _client
          .delete(
            Uri.parse('$_baseUrl/portfolio/holdings/$id'),
            headers: _headers,
          )
          .timeout(_timeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse.success(null);
      } else {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        return ApiResponse.error(body['message'] ?? 'Delete failed', response.statusCode);
      }
    } catch (e) {
      return ApiResponse.error('Network error: $e', 0);
    }
  }

  // Analytics Methods
  Future<ApiResponse<Map<String, dynamic>>> getDashboardSummary() async {
    try {
      final response = await _client
          .get(
            Uri.parse('$_baseUrl/analytics/dashboard'),
            headers: _headers,
          )
          .timeout(_timeout);

      return _handleResponse(response, (data) => data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse.error('Network error: $e', 0);
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getExpenseBreakdown({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (startDate != null) queryParams['start_date'] = startDate.toIso8601String();
      if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();

      final uri = Uri.parse('$_baseUrl/analytics/expenses').replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);
      
      final response = await _client.get(uri, headers: _headers).timeout(_timeout);

      return _handleResponse(response, (data) => data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse.error('Network error: $e', 0);
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getIncomeBreakdown({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (startDate != null) queryParams['start_date'] = startDate.toIso8601String();
      if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();

      final uri = Uri.parse('$_baseUrl/analytics/income').replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);
      
      final response = await _client.get(uri, headers: _headers).timeout(_timeout);

      return _handleResponse(response, (data) => data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse.error('Network error: $e', 0);
    }
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> getNetWorthHistory({
    int? months,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (months != null) queryParams['months'] = months.toString();

      final uri = Uri.parse('$_baseUrl/analytics/net-worth-history').replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);
      
      final response = await _client.get(uri, headers: _headers).timeout(_timeout);

      return _handleResponse(response, (data) {
        final list = data as List<dynamic>;
        return list.map((e) => e as Map<String, dynamic>).toList();
      });
    } catch (e) {
      return ApiResponse.error('Network error: $e', 0);
    }
  }

  // Stock Market Data Methods
  Future<ApiResponse<Map<String, dynamic>>> searchStocks(String query) async {
    try {
      final response = await _client
          .get(
            Uri.parse('$_baseUrl/stocks/search?q=$query'),
            headers: _headers,
          )
          .timeout(_timeout);

      return _handleResponse(response, (data) => data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse.error('Network error: $e', 0);
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getStockQuote(String symbol) async {
    try {
      final response = await _client
          .get(
            Uri.parse('$_baseUrl/stocks/$symbol/quote'),
            headers: _headers,
          )
          .timeout(_timeout);

      return _handleResponse(response, (data) => data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse.error('Network error: $e', 0);
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getStockHistory({
    required String symbol,
    String? interval,
    int? range,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (interval != null) queryParams['interval'] = interval;
      if (range != null) queryParams['range'] = range.toString();

      final uri = Uri.parse('$_baseUrl/stocks/$symbol/history').replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);
      
      final response = await _client.get(uri, headers: _headers).timeout(_timeout);

      return _handleResponse(response, (data) => data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse.error('Network error: $e', 0);
    }
  }

  // Category Methods
  Future<ApiResponse<List<String>>> getCategories() async {
    try {
      final response = await _client
          .get(
            Uri.parse('$_baseUrl/categories'),
            headers: _headers,
          )
          .timeout(_timeout);

      return _handleResponse(response, (data) {
        final list = data as List<dynamic>;
        return list.map((e) => e.toString()).toList();
      });
    } catch (e) {
      return ApiResponse.error('Network error: $e', 0);
    }
  }

  // Budget Methods
  Future<ApiResponse<Map<String, dynamic>>> getBudgets() async {
    try {
      final response = await _client
          .get(
            Uri.parse('$_baseUrl/budgets'),
            headers: _headers,
          )
          .timeout(_timeout);

      return _handleResponse(response, (data) => data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse.error('Network error: $e', 0);
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> createBudget({
    required String category,
    required double amount,
    required String period,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse('$_baseUrl/budgets'),
            headers: _headers,
            body: jsonEncode({
              'category': category,
              'amount': amount,
              'period': period,
            }),
          )
          .timeout(_timeout);

      return _handleResponse(response, (data) => data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse.error('Network error: $e', 0);
    }
  }

  void dispose() {
    _client.close();
  }
}

class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? errorMessage;
  final int statusCode;

  ApiResponse._({
    required this.success,
    this.data,
    this.errorMessage,
    required this.statusCode,
  });

  factory ApiResponse.success(T data) {
    return ApiResponse._(
      success: true,
      data: data,
      statusCode: 200,
    );
  }

  factory ApiResponse.error(String message, int statusCode) {
    return ApiResponse._(
      success: false,
      errorMessage: message,
      statusCode: statusCode,
    );
  }
}
