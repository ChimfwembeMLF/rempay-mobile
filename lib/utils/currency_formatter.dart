import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String format(double amount, String currencyCode) {
    final format = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    // In a real app, map currencyCode to symbol
    return format.format(amount);
  }
}
