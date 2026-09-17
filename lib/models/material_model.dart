class MaterialItem {
  final int? id;
  final String nome;
  final String tipo; // Granito, Mármore, Quartzo, Lâmina, Outro
  final double precoM2Custo;
  final double precoM2Venda;
  final String espessura; // 2cm, 3cm, etc.

  MaterialItem({
    this.id,
    required this.nome,
    this.tipo = 'Granito',
    required this.precoM2Custo,
    required this.precoM2Venda,
    this.espessura = '2cm',
  });

  double get margemLucro {
    if (precoM2Custo == 0) return 0;
    return ((precoM2Venda - precoM2Custo) / precoM2Custo) * 100;
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'nome': nome,
      'tipo': tipo,
      'preco_m2_custo': precoM2Custo,
      'preco_m2_venda': precoM2Venda,
      'espessura': espessura,
    };
  }

  factory MaterialItem.fromMap(Map<String, dynamic> map) {
    return MaterialItem(
      id: map['id'] as int?,
      nome: map['nome'] as String? ?? '',
      tipo: map['tipo'] as String? ?? 'Granito',
      precoM2Custo: (map['preco_m2_custo'] as num?)?.toDouble() ?? 0.0,
      precoM2Venda: (map['preco_m2_venda'] as num?)?.toDouble() ?? 0.0,
      espessura: map['espessura'] as String? ?? '2cm',
    );
  }

  MaterialItem copyWith({
    int? id,
    String? nome,
    String? tipo,
    double? precoM2Custo,
    double? precoM2Venda,
    String? espessura,
  }) {
    return MaterialItem(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      tipo: tipo ?? this.tipo,
      precoM2Custo: precoM2Custo ?? this.precoM2Custo,
      precoM2Venda: precoM2Venda ?? this.precoM2Venda,
      espessura: espessura ?? this.espessura,
    );
  }
}
