class Conta {
  final int? id;
  final int? orcamentoId;
  final String tipo; // receber ou pagar
  final String descricao;
  final double valor;
  final String dataVencimento;
  final String statusPagamento; // Pendente ou Pago

  Conta({
    this.id,
    this.orcamentoId,
    required this.tipo,
    required this.descricao,
    required this.valor,
    required this.dataVencimento,
    this.statusPagamento = 'Pendente',
  });

  bool get isPago => statusPagamento == 'Pago';
  bool get isReceber => tipo == 'receber';
  bool get isPagar => tipo == 'pagar';

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'orcamento_id': orcamentoId,
      'tipo': tipo,
      'descricao': descricao,
      'valor': valor,
      'data_vencimento': dataVencimento,
      'status_pagamento': statusPagamento,
    };
  }

  factory Conta.fromMap(Map<String, dynamic> map) {
    return Conta(
      id: map['id'] as int?,
      orcamentoId: map['orcamento_id'] as int?,
      tipo: map['tipo'] as String? ?? 'receber',
      descricao: map['descricao'] as String? ?? '',
      valor: (map['valor'] as num?)?.toDouble() ?? 0.0,
      dataVencimento: map['data_vencimento'] as String? ?? '',
      statusPagamento: map['status_pagamento'] as String? ?? 'Pendente',
    );
  }

  Conta copyWith({
    int? id,
    int? orcamentoId,
    String? tipo,
    String? descricao,
    double? valor,
    String? dataVencimento,
    String? statusPagamento,
  }) {
    return Conta(
      id: id ?? this.id,
      orcamentoId: orcamentoId ?? this.orcamentoId,
      tipo: tipo ?? this.tipo,
      descricao: descricao ?? this.descricao,
      valor: valor ?? this.valor,
      dataVencimento: dataVencimento ?? this.dataVencimento,
      statusPagamento: statusPagamento ?? this.statusPagamento,
    );
  }
}
