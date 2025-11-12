// lib/utils/money_format.dart
import 'package:intl/intl.dart';

class MoneyFormatter {
  static final _formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static String format(num value) {
    return _formatter.format(value);
  }
}
