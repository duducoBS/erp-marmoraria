import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:erp_marmoraria/models/cliente_model.dart';
import 'package:erp_marmoraria/models/material_model.dart';
import 'package:erp_marmoraria/models/acabamento_model.dart';
import 'package:erp_marmoraria/models/orcamento_item_model.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('Teste de criação e manipulação em banco de dados SQLite in-memory', () async {
    final db = await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE clientes (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              nome TEXT NOT NULL,
              tipo TEXT DEFAULT 'PF',
              documento TEXT,
              telefone TEXT,
              email TEXT,
              endereco TEXT,
              cidade TEXT
            )
          ''');

          await db.execute('''
            CREATE TABLE materiais (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              nome TEXT NOT NULL,
              tipo TEXT,
              preco_m2_custo REAL NOT NULL,
              preco_m2_venda REAL NOT NULL,
              espessura TEXT
            )
          ''');

          await db.execute('''
            CREATE TABLE acabamentos_servicos (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              nome TEXT NOT NULL,
              tipo_cobranca TEXT NOT NULL,
              valor REAL NOT NULL
            )
          ''');

          await db.execute('''
            CREATE TABLE orcamentos (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              cliente_id INTEGER NOT NULL,
              data_criacao TEXT NOT NULL,
              data_validade TEXT NOT NULL,
              status TEXT NOT NULL,
              valor_total REAL NOT NULL,
              observacoes TEXT
            )
          ''');

          await db.execute('''
            CREATE TABLE orcamento_itens (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              orcamento_id INTEGER NOT NULL,
              ambiente TEXT NOT NULL,
              material_id INTEGER NOT NULL,
              largura REAL NOT NULL,
              comprimento REAL NOT NULL,
              quantidade INTEGER NOT NULL,
              m2_total REAL NOT NULL,
              perda_percentual REAL NOT NULL,
              acabamento_id INTEGER,
              acabamento_quantidade REAL DEFAULT 0,
              valor_parcial REAL NOT NULL,
              tipo_calculo TEXT DEFAULT 'metro',
              preco_metro REAL DEFAULT 0,
              valor_fixo REAL DEFAULT 0,
              descricao TEXT DEFAULT ''
            )
          ''');
        },
      ),
    );

    // Inserção de Cliente
    final cliente = Cliente(
      nome: 'Marmoraria Teste Cliente',
      tipo: 'PJ',
      telefone: '(11) 98888-7777',
      cidade: 'São Paulo',
    );
    final clienteId = await db.insert('clientes', cliente.toMap());
    expect(clienteId, equals(1));

    // Inserção de Material
    final material = MaterialItem(
      nome: 'Granito São Gabriel',
      tipo: 'Granito',
      precoM2Custo: 300.0,
      precoM2Venda: 550.0,
    );
    final materialId = await db.insert('materiais', material.toMap());
    expect(materialId, equals(1));

    // Inserção de Acabamento
    final acabamento = AcabamentoServico(
      nome: 'Meia Esquadria 45º',
      tipoCobranca: 'metro_linear',
      valor: 60.0,
    );
    final acabamentoId = await db.insert('acabamentos_servicos', acabamento.toMap());
    expect(acabamentoId, equals(1));

    // Inserção de Orçamento e Itens (1 por m2 com preco customizado e 1 com valor fixo)
    final m2 = OrcamentoItem.calcularM2Total(largura: 0.6, comprimento: 3.0, quantidade: 1, perdaPercentual: 10);
    final totalItem1 = OrcamentoItem.calcularValorParcial(
      tipoCalculo: 'metro',
      m2Total: m2,
      precoM2Venda: 520.0, // preço livre customizado
      acabamentoValorUnitario: 60.0,
      acabamentoQuantidade: 3.0,
    );

    final totalItem2 = OrcamentoItem.calcularValorParcial(
      tipoCalculo: 'fixo',
      m2Total: 0.0,
      precoM2Venda: 0.0,
      valorFixo: 850.0, // valor fixo fechado
      acabamentoValorUnitario: 0.0,
      acabamentoQuantidade: 0.0,
    );

    final orcamentoId = await db.insert('orcamentos', {
      'cliente_id': clienteId,
      'data_criacao': '2026-09-17',
      'data_validade': '2026-10-02',
      'status': 'Aprovado',
      'valor_total': totalItem1 + totalItem2,
      'observacoes': 'Teste com item livre m2 e item valor fixo',
    });
    expect(orcamentoId, equals(1));

    await db.insert('orcamento_itens', {
      'orcamento_id': orcamentoId,
      'ambiente': 'Cozinha',
      'material_id': materialId,
      'largura': 0.6,
      'comprimento': 3.0,
      'quantidade': 1,
      'm2_total': m2,
      'perda_percentual': 10.0,
      'acabamento_id': acabamentoId,
      'acabamento_quantidade': 3.0,
      'valor_parcial': totalItem1,
      'tipo_calculo': 'metro',
      'preco_metro': 520.0,
      'valor_fixo': 0.0,
      'descricao': 'Bancada com frontão 10cm',
    });

    await db.insert('orcamento_itens', {
      'orcamento_id': orcamentoId,
      'ambiente': 'Lavabo Cuba Esculpida',
      'material_id': materialId,
      'largura': 0.5,
      'comprimento': 0.8,
      'quantidade': 1,
      'm2_total': 0.44,
      'perda_percentual': 10.0,
      'acabamento_id': null,
      'acabamento_quantidade': 0.0,
      'valor_parcial': totalItem2,
      'tipo_calculo': 'fixo',
      'preco_metro': 0.0,
      'valor_fixo': 850.0,
      'descricao': 'Cuba esculpida com rampa oculta',
    });

    // Consulta com Join
    final itens = await db.rawQuery('''
      SELECT i.*, m.nome as material_nome, a.nome as acabamento_nome
      FROM orcamento_itens i
      LEFT JOIN materiais m ON i.material_id = m.id
      LEFT JOIN acabamentos_servicos a ON i.acabamento_id = a.id
      WHERE i.orcamento_id = ?
      ORDER BY i.id ASC
    ''', [orcamentoId]);

    expect(itens.length, equals(2));
    expect(itens[0]['material_nome'], equals('Granito São Gabriel'));
    expect(itens[0]['tipo_calculo'], equals('metro'));
    expect(itens[0]['preco_metro'], equals(520.0));
    expect(itens[0]['descricao'], equals('Bancada com frontão 10cm'));
    expect(itens[1]['tipo_calculo'], equals('fixo'));
    expect(itens[1]['valor_fixo'], equals(850.0));
    expect(itens[1]['descricao'], equals('Cuba esculpida com rampa oculta'));

    await db.close();
  });
}
