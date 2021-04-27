import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

final _numberFormat = NumberFormat('#,##0.00');

extension DateTimeExtension on DateTime {
  String format({String pattern = 'dd/MM/yyyy', String locale = 'fr_FR'}) {
    initializeDateFormatting(locale);
    return DateFormat(pattern, locale).format(this);
  }
}

extension ToDateExtension on String {
  DateTime toDateTime() {
    return DateFormat('yyyy-MM-dd\'T\'HH:mm:ssZ').parse(this);
  }
}

extension ToStringCurrency on num {
  String toCurrency() {
    var amount = this ~/ 100;
    return _numberFormat.format(amount) + '€';
  }
}
