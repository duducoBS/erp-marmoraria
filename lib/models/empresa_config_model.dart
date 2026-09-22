class EmpresaConfig {
  final int id;
  final String nome;
  final String cnpj;
  final String endereco;
  final String especialidades;
  final String fone1;
  final String resp1;
  final String cidadePadrao;
  final String dadosBancarios;
  final String observacoesPadrao;

  EmpresaConfig({
    this.id = 1,
    this.nome = 'EDU MÁRMORES & GRANITOS',
    this.cnpj = '26.106.792/0001-77',
    this.endereco = 'Av. Barreira Grande, 3001 - Jd. Imperador - São Paulo - SP',
    this.especialidades = 'MÁRMORES • GRANITOS • PEDRAS DECORATIVAS\nPIAS • LAVATÓRIOS • PISOS • ESCADAS • SOLEIRAS',
    this.fone1 = '(11) 94031-1110',
    this.resp1 = 'Edu',
    this.cidadePadrao = 'São Paulo',
    this.dadosBancarios = 'Caixa Econômica Ag: 0242 Op: 013 CP: 7675-7 / PIX: 148.374.878-23 Cicero Eduardo dos Santos',
    this.observacoesPadrao = 'Material para instalação por conta do cliente. Medição final sujeita a conferência na obra.',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'cnpj': cnpj,
      'endereco': endereco,
      'especialidades': especialidades,
      'fone1': fone1,
      'resp1': resp1,
      'cidade_padrao': cidadePadrao,
      'dados_bancarios': dadosBancarios,
      'observacoes_padrao': observacoesPadrao,
    };
  }

  factory EmpresaConfig.fromMap(Map<String, dynamic> map) {
    return EmpresaConfig(
      id: map['id'] as int? ?? 1,
      nome: map['nome'] as String? ?? 'EDU MÁRMORES & GRANITOS',
      cnpj: map['cnpj'] as String? ?? '26.106.792/0001-77',
      endereco: map['endereco'] as String? ?? '',
      especialidades: map['especialidades'] as String? ?? '',
      fone1: map['fone1'] as String? ?? '',
      resp1: map['resp1'] as String? ?? '',
      cidadePadrao: map['cidade_padrao'] as String? ?? 'São Paulo',
      dadosBancarios: map['dados_bancarios'] as String? ?? '',
      observacoesPadrao: map['observacoes_padrao'] as String? ?? '',
    );
  }

  EmpresaConfig copyWith({
    int? id,
    String? nome,
    String? cnpj,
    String? endereco,
    String? especialidades,
    String? fone1,
    String? resp1,
    String? cidadePadrao,
    String? dadosBancarios,
    String? observacoesPadrao,
  }) {
    return EmpresaConfig(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      cnpj: cnpj ?? this.cnpj,
      endereco: endereco ?? this.endereco,
      especialidades: especialidades ?? this.especialidades,
      fone1: fone1 ?? this.fone1,
      resp1: resp1 ?? this.resp1,
      cidadePadrao: cidadePadrao ?? this.cidadePadrao,
      dadosBancarios: dadosBancarios ?? this.dadosBancarios,
      observacoesPadrao: observacoesPadrao ?? this.observacoesPadrao,
    );
  }
}
