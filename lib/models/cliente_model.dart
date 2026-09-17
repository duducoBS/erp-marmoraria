class Cliente {
  final int? id;
  final String nome;
  final String tipo; // PF ou PJ
  final String documento; // CPF ou CNPJ
  final String telefone;
  final String email;
  final String endereco;
  final String cidade;

  Cliente({
    this.id,
    required this.nome,
    this.tipo = 'PF',
    this.documento = '',
    this.telefone = '',
    this.email = '',
    this.endereco = '',
    this.cidade = '',
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'nome': nome,
      'tipo': tipo,
      'documento': documento,
      'telefone': telefone,
      'email': email,
      'endereco': endereco,
      'cidade': cidade,
    };
  }

  factory Cliente.fromMap(Map<String, dynamic> map) {
    return Cliente(
      id: map['id'] as int?,
      nome: map['nome'] as String? ?? '',
      tipo: map['tipo'] as String? ?? 'PF',
      documento: map['documento'] as String? ?? '',
      telefone: map['telefone'] as String? ?? '',
      email: map['email'] as String? ?? '',
      endereco: map['endereco'] as String? ?? '',
      cidade: map['cidade'] as String? ?? '',
    );
  }

  Cliente copyWith({
    int? id,
    String? nome,
    String? tipo,
    String? documento,
    String? telefone,
    String? email,
    String? endereco,
    String? cidade,
  }) {
    return Cliente(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      tipo: tipo ?? this.tipo,
      documento: documento ?? this.documento,
      telefone: telefone ?? this.telefone,
      email: email ?? this.email,
      endereco: endereco ?? this.endereco,
      cidade: cidade ?? this.cidade,
    );
  }
}
