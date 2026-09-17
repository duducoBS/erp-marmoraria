class AcabamentoServico {
  final int? id;
  final String nome;
  final String tipoCobranca; // metro_linear, unidade, fixo
  final double valor;

  AcabamentoServico({
    this.id,
    required this.nome,
    required this.tipoCobranca,
    required this.valor,
  });

  String get tipoCobrancaLabel {
    switch (tipoCobranca) {
      case 'metro_linear':
        return 'Metro Linear (m)';
      case 'unidade':
        return 'Unidade (un)';
      case 'fixo':
        return 'Fixo';
      default:
        return tipoCobranca;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'nome': nome,
      'tipo_cobranca': tipoCobranca,
      'valor': valor,
    };
  }

  factory AcabamentoServico.fromMap(Map<String, dynamic> map) {
    return AcabamentoServico(
      id: map['id'] as int?,
      nome: map['nome'] as String? ?? '',
      tipoCobranca: map['tipo_cobranca'] as String? ?? 'metro_linear',
      valor: (map['valor'] as num?)?.toDouble() ?? 0.0,
    );
  }

  AcabamentoServico copyWith({
    int? id,
    String? nome,
    String? tipoCobranca,
    double? valor,
  }) {
    return AcabamentoServico(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      tipoCobranca: tipoCobranca ?? this.tipoCobranca,
      valor: valor ?? this.valor,
    );
  }
}
