class OrcamentoItem {
  final int? id;
  final int? orcamentoId;
  final String ambiente;
  final int materialId;
  final double largura;
  final double comprimento;
  final int quantidade;
  final double m2Total;
  final double perdaPercentual;
  final int? acabamentoId;
  final double acabamentoQuantidade;
  final double valorParcial;
  final String tipoCalculo; // 'metro' ou 'fixo'
  final double precoMetro; // Preço do m² editável no orçamento
  final double valorFixo; // Preço fixo da peça quando tipoCalculo == 'fixo'
  final String descricao; // Detalhamento livre da peça/item

  // Campos extras para exibição (joins)
  final String? materialNome;
  final String? acabamentoNome;
  final String? acabamentoTipoCobranca;

  OrcamentoItem({
    this.id,
    this.orcamentoId,
    required this.ambiente,
    required this.materialId,
    required this.largura,
    required this.comprimento,
    this.quantidade = 1,
    required this.m2Total,
    this.perdaPercentual = 10.0,
    this.acabamentoId,
    this.acabamentoQuantidade = 0.0,
    required this.valorParcial,
    this.tipoCalculo = 'metro',
    this.precoMetro = 0.0,
    this.valorFixo = 0.0,
    this.descricao = '',
    this.materialNome,
    this.acabamentoNome,
    this.acabamentoTipoCobranca,
  });

  /// Metragem quadrada líquida sem a perda
  double get m2Liquido => largura * comprimento * quantidade;

  /// Cálculo da metragem quadrada com a perda:
  /// m² = largura * comprimento * quantidade * (1 + perda% / 100)
  static double calcularM2Total({
    required double largura,
    required double comprimento,
    required int quantidade,
    required double perdaPercentual,
  }) {
    final liquido = largura * comprimento * quantidade;
    final comPerda = liquido * (1.0 + (perdaPercentual / 100.0));
    return double.parse(comPerda.toStringAsFixed(4));
  }

  /// Cálculo do valor parcial do item (por m² com preço customizável ou valor fixo)
  static double calcularValorParcial({
    String tipoCalculo = 'metro',
    required double m2Total,
    required double precoM2Venda,
    double valorFixo = 0.0,
    double acabamentoValorUnitario = 0.0,
    double acabamentoQuantidade = 0.0,
  }) {
    final double baseItem = (tipoCalculo == 'fixo')
        ? valorFixo
        : (m2Total * precoM2Venda);
    final valorAcabamento = acabamentoValorUnitario * acabamentoQuantidade;
    final total = baseItem + valorAcabamento;
    return double.parse(total.toStringAsFixed(2));
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (orcamentoId != null) 'orcamento_id': orcamentoId,
      'ambiente': ambiente,
      'material_id': materialId,
      'largura': largura,
      'comprimento': comprimento,
      'quantidade': quantidade,
      'm2_total': m2Total,
      'perda_percentual': perdaPercentual,
      'acabamento_id': acabamentoId,
      'acabamento_quantidade': acabamentoQuantidade,
      'valor_parcial': valorParcial,
      'tipo_calculo': tipoCalculo,
      'preco_metro': precoMetro,
      'valor_fixo': valorFixo,
      'descricao': descricao,
    };
  }

  factory OrcamentoItem.fromMap(Map<String, dynamic> map) {
    return OrcamentoItem(
      id: map['id'] as int?,
      orcamentoId: map['orcamento_id'] as int?,
      ambiente: map['ambiente'] as String? ?? '',
      materialId: map['material_id'] as int? ?? 0,
      largura: (map['largura'] as num?)?.toDouble() ?? 0.0,
      comprimento: (map['comprimento'] as num?)?.toDouble() ?? 0.0,
      quantidade: map['quantidade'] as int? ?? 1,
      m2Total: (map['m2_total'] as num?)?.toDouble() ?? 0.0,
      perdaPercentual: (map['perda_percentual'] as num?)?.toDouble() ?? 10.0,
      acabamentoId: map['acabamento_id'] as int?,
      acabamentoQuantidade: (map['acabamento_quantidade'] as num?)?.toDouble() ?? 0.0,
      valorParcial: (map['valor_parcial'] as num?)?.toDouble() ?? 0.0,
      tipoCalculo: map['tipo_calculo'] as String? ?? 'metro',
      precoMetro: (map['preco_metro'] as num?)?.toDouble() ?? 0.0,
      valorFixo: (map['valor_fixo'] as num?)?.toDouble() ?? 0.0,
      descricao: map['descricao'] as String? ?? '',
      materialNome: map['material_nome'] as String?,
      acabamentoNome: map['acabamento_nome'] as String?,
      acabamentoTipoCobranca: map['acabamento_tipo_cobranca'] as String?,
    );
  }

  OrcamentoItem copyWith({
    int? id,
    int? orcamentoId,
    String? ambiente,
    int? materialId,
    double? largura,
    double? comprimento,
    int? quantidade,
    double? m2Total,
    double? perdaPercentual,
    int? acabamentoId,
    double? acabamentoQuantidade,
    double? valorParcial,
    String? tipoCalculo,
    double? precoMetro,
    double? valorFixo,
    String? descricao,
    String? materialNome,
    String? acabamentoNome,
    String? acabamentoTipoCobranca,
  }) {
    return OrcamentoItem(
      id: id ?? this.id,
      orcamentoId: orcamentoId ?? this.orcamentoId,
      ambiente: ambiente ?? this.ambiente,
      materialId: materialId ?? this.materialId,
      largura: largura ?? this.largura,
      comprimento: comprimento ?? this.comprimento,
      quantidade: quantidade ?? this.quantidade,
      m2Total: m2Total ?? this.m2Total,
      perdaPercentual: perdaPercentual ?? this.perdaPercentual,
      acabamentoId: acabamentoId ?? this.acabamentoId,
      acabamentoQuantidade: acabamentoQuantidade ?? this.acabamentoQuantidade,
      valorParcial: valorParcial ?? this.valorParcial,
      tipoCalculo: tipoCalculo ?? this.tipoCalculo,
      precoMetro: precoMetro ?? this.precoMetro,
      valorFixo: valorFixo ?? this.valorFixo,
      descricao: descricao ?? this.descricao,
      materialNome: materialNome ?? this.materialNome,
      acabamentoNome: acabamentoNome ?? this.acabamentoNome,
      acabamentoTipoCobranca: acabamentoTipoCobranca ?? this.acabamentoTipoCobranca,
    );
  }
}
