import 'dart:convert';
import 'orcamento_item_model.dart';
import 'orcamento_parcela_model.dart';

class Orcamento {
  final int? id;
  final int clienteId;
  final String dataCriacao;
  final String dataValidade;
  final String status; // Rascunho, Enviado, Aprovado, Recusado
  final double valorTotal;
  final String observacoes;
  final String condicaoPagamento;
  final String dadosBancarios;
  final List<OrcamentoParcela> parcelas;

  // Campos auxiliares
  final String? clienteNome;
  final String? clienteTelefone;
  final String? clienteEndereco;
  final String? clienteBairro;
  final String? clienteCidade;
  final String? clienteDocumento;
  final String? clienteEmail;
  final List<OrcamentoItem> itens;

  Orcamento({
    this.id,
    required this.clienteId,
    required this.dataCriacao,
    required this.dataValidade,
    this.status = 'Rascunho',
    required this.valorTotal,
    this.observacoes = '',
    this.condicaoPagamento = '',
    this.dadosBancarios = '',
    this.parcelas = const [],
    this.clienteNome,
    this.clienteTelefone,
    this.clienteEndereco,
    this.clienteBairro,
    this.clienteCidade,
    this.clienteDocumento,
    this.clienteEmail,
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
      'condicao_pagamento': condicaoPagamento,
      'dados_bancarios': dadosBancarios,
      'parcelas_json': jsonEncode(parcelas.map((p) => p.toMap()).toList()),
    };
  }

  factory Orcamento.fromMap(Map<String, dynamic> map, {List<OrcamentoItem> itens = const []}) {
    List<OrcamentoParcela> parcelasList = [];
    final rawParcelas = map['parcelas_json'] as String?;
    if (rawParcelas != null && rawParcelas.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawParcelas) as List<dynamic>;
        parcelasList = decoded.map((p) => OrcamentoParcela.fromMap(p as Map<String, dynamic>)).toList();
      } catch (_) {}
    }

    return Orcamento(
      id: map['id'] as int?,
      clienteId: map['cliente_id'] as int? ?? 0,
      dataCriacao: map['data_criacao'] as String? ?? '',
      dataValidade: map['data_validade'] as String? ?? '',
      status: map['status'] as String? ?? 'Rascunho',
      valorTotal: (map['valor_total'] as num?)?.toDouble() ?? 0.0,
      observacoes: map['observacoes'] as String? ?? '',
      condicaoPagamento: map['condicao_pagamento'] as String? ?? '',
      dadosBancarios: map['dados_bancarios'] as String? ?? '',
      parcelas: parcelasList,
      clienteNome: map['cliente_nome'] as String?,
      clienteTelefone: map['cliente_telefone'] as String?,
      clienteEndereco: map['cliente_endereco'] as String?,
      clienteBairro: map['cliente_bairro'] as String?,
      clienteCidade: map['cliente_cidade'] as String?,
      clienteDocumento: map['cliente_documento'] as String?,
      clienteEmail: map['cliente_email'] as String?,
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
    String? condicaoPagamento,
    String? dadosBancarios,
    List<OrcamentoParcela>? parcelas,
    String? clienteNome,
    String? clienteTelefone,
    String? clienteEndereco,
    String? clienteBairro,
    String? clienteCidade,
    String? clienteDocumento,
    String? clienteEmail,
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
      condicaoPagamento: condicaoPagamento ?? this.condicaoPagamento,
      dadosBancarios: dadosBancarios ?? this.dadosBancarios,
      parcelas: parcelas ?? this.parcelas,
      clienteNome: clienteNome ?? this.clienteNome,
      clienteTelefone: clienteTelefone ?? this.clienteTelefone,
      clienteEndereco: clienteEndereco ?? this.clienteEndereco,
      clienteBairro: clienteBairro ?? this.clienteBairro,
      clienteCidade: clienteCidade ?? this.clienteCidade,
      clienteDocumento: clienteDocumento ?? this.clienteDocumento,
      clienteEmail: clienteEmail ?? this.clienteEmail,
      itens: itens ?? this.itens,
    );
  }
}
