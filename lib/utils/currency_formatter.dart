import 'package:intl/intl.dart';

class CurrencyFormatterUtil {
  static String format(double amount, {String currencyCode = 'IDR'}) {
    switch (currencyCode) {
      case 'USD':
        return NumberFormat.currency(symbol: 'USD ', decimalDigits: 2).format(amount);
      case 'EUR':
        return NumberFormat.currency(symbol: 'EUR ', decimalDigits: 2).format(amount);
      case 'JPY':
        return NumberFormat.currency(symbol: 'JPY ', decimalDigits: 0).format(amount);
      case 'KRW':
        return NumberFormat.currency(symbol: 'KRW ', decimalDigits: 0).format(amount);
      case 'SAR':
        return NumberFormat.currency(symbol: 'SR ', decimalDigits: 2).format(amount);
      case 'MYR':
        return NumberFormat.currency(symbol: 'RM ', decimalDigits: 2).format(amount);
      case 'IDR':
      default:
        return NumberFormat.currency(symbol: 'Rp ', decimalDigits: 0, locale: 'id_ID').format(amount);
    }
  }
}
