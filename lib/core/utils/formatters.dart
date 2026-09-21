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
    if (value == null || value.isNaN || value.isInfinite) return r'R$ 0,00';
    return _currencyFormat.format(value).replaceAll('\u00a0', ' ');
  }

  /// Formata número com casas decimais no padrão brasileiro (ex: 2,50)
  static String formatDecimal(num? value, {int decimals = 2}) {
    if (value == null || value.isNaN || value.isInfinite) return '0,00';
    if (decimals == 2) {
      return _decimalFormat.format(value);
    }
    final format = NumberFormat.currency(locale: 'pt_BR', symbol: '', decimalDigits: decimals);
    return format.format(value).trim();
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

  /// Converte texto digitado com vírgula ou ponto em double de forma segura.
  /// Suporta formatos BRL: "1.250,50", "2,50", "0,60"
  /// Suporta formatos com ponto decimal / numpad: "1250.50", "2.50", "0.60", "1250"
  /// Suporta prefixos de moeda: "R$ 1.250,50"
  static double parseDouble(String text) {
    var cleaned = text.replaceAll(RegExp(r'[^0-9,\.-]'), '').trim();
    if (cleaned.isEmpty) return 0.0;

    // Se possui vírgula E ponto
    if (cleaned.contains(',') && cleaned.contains('.')) {
      final lastComma = cleaned.lastIndexOf(',');
      final lastDot = cleaned.lastIndexOf('.');
      if (lastComma > lastDot) {
        // Padrão Brasileiro: 1.250,50 -> remove pontos de milhar, vírgula vira ponto decimal
        cleaned = cleaned.replaceAll('.', '').replaceAll(',', '.');
      } else {
        // Padrão Internacional: 1,250.50 -> remove vírgulas de milhar
        cleaned = cleaned.replaceAll(',', '');
      }
    } else if (cleaned.contains(',')) {
      // Apenas vírgula: "2,50", "0,60", "1500,00" -> vírgula é separador decimal
      cleaned = cleaned.replaceAll(',', '.');
    } else if (cleaned.contains('.')) {
      // Apenas ponto(s)
      final dots = cleaned.split('.').length - 1;
      if (dots > 1) {
        // Múltiplos pontos: "1.000.000" -> pontos de milhar
        cleaned = cleaned.replaceAll('.', '');
      } else {
        // Apenas um ponto: "0.60", "2.50", "150.50", "1250.00" -> ponto decimal padrão
      }
    }

    return double.tryParse(cleaned) ?? 0.0;
  }
}
