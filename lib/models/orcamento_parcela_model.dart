class OrcamentoParcela {
  final int numero;
  final double valor;
  final String vencimento; // YYYY-MM-DD ou DD/MM/AAAA

  OrcamentoParcela({
    required this.numero,
    required this.valor,
    required this.vencimento,
  });

  Map<String, dynamic> toMap() {
    return {
      'numero': numero,
      'valor': valor,
      'vencimento': vencimento,
    };
  }

  factory OrcamentoParcela.fromMap(Map<String, dynamic> map) {
    return OrcamentoParcela(
      numero: map['numero'] as int? ?? 1,
      valor: (map['valor'] as num?)?.toDouble() ?? 0.0,
      vencimento: map['vencimento'] as String? ?? '',
    );
  }
}
