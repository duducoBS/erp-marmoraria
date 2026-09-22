class OrcamentoParcela {
  final int numero;
  final double valor;
  final String vencimento; // YYYY-MM-DD ou DD/MM/AAAA
  final String? descricao;

  OrcamentoParcela({
    required this.numero,
    required this.valor,
    required this.vencimento,
    this.descricao,
  });

  OrcamentoParcela copyWith({
    int? numero,
    double? valor,
    String? vencimento,
    String? descricao,
  }) {
    return OrcamentoParcela(
      numero: numero ?? this.numero,
      valor: valor ?? this.valor,
      vencimento: vencimento ?? this.vencimento,
      descricao: descricao ?? this.descricao,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'numero': numero,
      'valor': valor,
      'vencimento': vencimento,
      if (descricao != null && descricao!.isNotEmpty) 'descricao': descricao,
    };
  }

  factory OrcamentoParcela.fromMap(Map<String, dynamic> map) {
    return OrcamentoParcela(
      numero: map['numero'] as int? ?? 1,
      valor: (map['valor'] as num?)?.toDouble() ?? 0.0,
      vencimento: map['vencimento'] as String? ?? '',
      descricao: map['descricao'] as String?,
    );
  }
}
