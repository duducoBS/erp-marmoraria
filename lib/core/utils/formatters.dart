import 'package:intl/intl.dart';

class Formatters {
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: r'R$',
    decimalDigits: 2,
  );

  static final NumberFormat _decimalFormat = NumberFormat('#,##0.00', 'pt_BR');
  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat _dateIsoFormat = DateFormat('yyyy-MM-dd');

  /// Formata um valor numérico para Moeda Real (ex: R$ 1.250,00)
  static String formatCurrency(num? value) {
    if (value == null) return 'R\$ 0,00';
    return _currencyFormat.format(value);
  }

  /// Formata número com 2 casas decimais (ex: 2,50)
  static String formatDecimal(num? value) {
    if (value == null) return '0,00';
    return _decimalFormat.format(value);
  }

  /// Formata metragem quadrada (ex: 3,45 m²)
  static String formatM2(num? value) {
    return '${formatDecimal(value)} m²';
  }

  /// Formata metros lineares (ex: 4,20 m)
  static String formatMeters(num? value) {
    return '${formatDecimal(value)} m';
  }

  /// Formata data para dd/MM/yyyy a partir de DateTime ou String ISO
  static String formatDate(dynamic date) {
    if (date == null) return '-';
    if (date is DateTime) {
      return _dateFormat.format(date);
    }
    if (date is String) {
      try {
        final parsed = DateTime.parse(date);
        return _dateFormat.format(parsed);
      } catch (_) {
        return date;
      }
    }
    return '-';
  }

  /// Converte DateTime para String YYYY-MM-DD para salvar no SQLite
  static String toIsoDate(DateTime date) {
    return _dateIsoFormat.format(date);
  }

  /// Converte texto digitado com vírgula ou ponto em double
  static double parseDouble(String text) {
    if (text.trim().isEmpty) return 0.0;
    final normalized = text.replaceAll('.', '').replaceAll(',', '.').trim();
    return double.tryParse(normalized) ?? 0.0;
  }
}
