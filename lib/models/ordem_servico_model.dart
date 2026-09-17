class OrdemServico {
  final int? id;
  final int? orcamentoId;
  final int? clienteId;
  final String titulo;
  final String statusProducao; // Medicao, Corte, Acabamento, Montagem, Concluido
  final String? dataEntregaPrevista;
  final String? observacoesTecnicas;

  // Campos auxiliares para visualização
  final String? clienteNome;
  final String? clienteTelefone;
  final String? clienteEndereco;

  OrdemServico({
    this.id,
    this.orcamentoId,
    this.clienteId,
    required this.titulo,
    this.statusProducao = 'Medicao',
    this.dataEntregaPrevista,
    this.observacoesTecnicas,
    this.clienteNome,
    this.clienteTelefone,
    this.clienteEndereco,
  });

  static const List<String> etapas = [
    'Medicao',
    'Corte',
    'Acabamento',
    'Montagem',
    'Concluido',
  ];

  static String getEtapaLabel(String etapa) {
    switch (etapa) {
      case 'Medicao':
        return '1. Medição Agendada';
      case 'Corte':
        return '2. Corte';
      case 'Acabamento':
        return '3. Acabamento';
      case 'Montagem':
        return '4. Montagem / Instalação';
      case 'Concluido':
        return '5. Concluído';
      default:
        return etapa;
    }
  }

  String? get proximaEtapa {
    final index = etapas.indexOf(statusProducao);
    if (index >= 0 && index < etapas.length - 1) {
      return etapas[index + 1];
    }
    return null;
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'orcamento_id': orcamentoId,
      'cliente_id': clienteId,
      'titulo': titulo,
      'status_producao': statusProducao,
      'data_entrega_prevista': dataEntregaPrevista,
      'observacoes_tecnicas': observacoesTecnicas,
    };
  }

  factory OrdemServico.fromMap(Map<String, dynamic> map) {
    return OrdemServico(
      id: map['id'] as int?,
      orcamentoId: map['orcamento_id'] as int?,
      clienteId: map['cliente_id'] as int?,
      titulo: map['titulo'] as String? ?? 'OS Sem Título',
      statusProducao: map['status_producao'] as String? ?? 'Medicao',
      dataEntregaPrevista: map['data_entrega_prevista'] as String?,
      observacoesTecnicas: map['observacoes_tecnicas'] as String?,
      clienteNome: map['cliente_nome'] as String?,
      clienteTelefone: map['cliente_telefone'] as String?,
      clienteEndereco: map['cliente_endereco'] as String?,
    );
  }

  OrdemServico copyWith({
    int? id,
    int? orcamentoId,
    int? clienteId,
    String? titulo,
    String? statusProducao,
    String? dataEntregaPrevista,
    String? observacoesTecnicas,
    String? clienteNome,
    String? clienteTelefone,
    String? clienteEndereco,
  }) {
    return OrdemServico(
      id: id ?? this.id,
      orcamentoId: orcamentoId ?? this.orcamentoId,
      clienteId: clienteId ?? this.clienteId,
      titulo: titulo ?? this.titulo,
      statusProducao: statusProducao ?? this.statusProducao,
      dataEntregaPrevista: dataEntregaPrevista ?? this.dataEntregaPrevista,
      observacoesTecnicas: observacoesTecnicas ?? this.observacoesTecnicas,
      clienteNome: clienteNome ?? this.clienteNome,
      clienteTelefone: clienteTelefone ?? this.clienteTelefone,
      clienteEndereco: clienteEndereco ?? this.clienteEndereco,
    );
  }
}
