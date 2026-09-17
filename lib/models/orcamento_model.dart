import 'orcamento_item_model.dart';

class Orcamento {
  final int? id;
  final int clienteId;
  final String dataCriacao;
  final String dataValidade;
  final String status; // Rascunho, Enviado, Aprovado, Recusado
  final double valorTotal;
  final String observacoes;

  // Campos auxiliares
  final String? clienteNome;
  final String? clienteTelefone;
  final List<OrcamentoItem> itens;

  Orcamento({
    this.id,
    required this.clienteId,
    required this.dataCriacao,
    required this.dataValidade,
    this.status = 'Rascunho',
    required this.valorTotal,
    this.observacoes = '',
    this.clienteNome,
    this.clienteTelefone,
    this.itens = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'cliente_id': clienteId,
      'data_criacao': dataCriacao,
      'data_validade': dataValidade,
      'status': status,
      'valor_total': valorTotal,
      'observacoes': observacoes,
    };
  }

  factory Orcamento.fromMap(Map<String, dynamic> map, {List<OrcamentoItem> itens = const []}) {
    return Orcamento(
      id: map['id'] as int?,
      clienteId: map['cliente_id'] as int? ?? 0,
      dataCriacao: map['data_criacao'] as String? ?? '',
      dataValidade: map['data_validade'] as String? ?? '',
      status: map['status'] as String? ?? 'Rascunho',
      valorTotal: (map['valor_total'] as num?)?.toDouble() ?? 0.0,
      observacoes: map['observacoes'] as String? ?? '',
      clienteNome: map['cliente_nome'] as String?,
      clienteTelefone: map['cliente_telefone'] as String?,
      itens: itens,
    );
  }

  Orcamento copyWith({
    int? id,
    int? clienteId,
    String? dataCriacao,
    String? dataValidade,
    String? status,
    double? valorTotal,
    String? observacoes,
    String? clienteNome,
    String? clienteTelefone,
    List<OrcamentoItem>? itens,
  }) {
    return Orcamento(
      id: id ?? this.id,
      clienteId: clienteId ?? this.clienteId,
      dataCriacao: dataCriacao ?? this.dataCriacao,
      dataValidade: dataValidade ?? this.dataValidade,
      status: status ?? this.status,
      valorTotal: valorTotal ?? this.valorTotal,
      observacoes: observacoes ?? this.observacoes,
      clienteNome: clienteNome ?? this.clienteNome,
      clienteTelefone: clienteTelefone ?? this.clienteTelefone,
      itens: itens ?? this.itens,
    );
  }
}
