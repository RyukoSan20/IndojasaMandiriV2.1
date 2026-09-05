import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyApiService {
  static const String apiKey = '1f64fafa938447949ffc4f520bf1549e';
  static const String baseUrl = 'https://api.currencyfreaks.com/v2.0/rates/latest';

  static Future<Map<String, double>> fetchLatestRates() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl?apikey=$apiKey'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final ratesMap = data['rates'] as Map<String, dynamic>;
        return ratesMap.map((key, value) => MapEntry(key, double.tryParse(value.toString()) ?? 1.0));
      }
    } catch (_) {}
    return {
      'IDR': 15500.0,
      'USD': 1.0,
      'EUR': 0.92,
      'JPY': 150.0,
      'SAR': 3.75,
      'MYR': 4.70,
    };
  }

  static double convert({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
    required Map<String, double> rates,
  }) {
    if (rates.isEmpty) return amount;
    double amountInUSD = fromCurrency == 'USD' ? amount : amount / (rates[fromCurrency] ?? 1.0);
    double targetRate = rates[toCurrency] ?? 1.0;
    return amountInUSD * targetRate;
  }
}
