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
              valor_parcial REAL NOT NULL
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

    // Inserção de Orçamento e Itens
    final m2 = OrcamentoItem.calcularM2Total(largura: 0.6, comprimento: 3.0, quantidade: 1, perdaPercentual: 10);
    final totalItem = OrcamentoItem.calcularValorParcial(
      m2Total: m2,
      precoM2Venda: 550.0,
      acabamentoValorUnitario: 60.0,
      acabamentoQuantidade: 3.0,
    );

    final orcamentoId = await db.insert('orcamentos', {
      'cliente_id': clienteId,
      'data_criacao': '2026-09-17',
      'data_validade': '2026-10-02',
      'status': 'Aprovado',
      'valor_total': totalItem,
      'observacoes': 'Teste de persistência SQLite com FFI',
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
      'valor_parcial': totalItem,
    });

    // Consulta com Join
    final itens = await db.rawQuery('''
      SELECT i.*, m.nome as material_nome, a.nome as acabamento_nome
      FROM orcamento_itens i
      LEFT JOIN materiais m ON i.material_id = m.id
      LEFT JOIN acabamentos_servicos a ON i.acabamento_id = a.id
      WHERE i.orcamento_id = ?
    ''', [orcamentoId]);

    expect(itens.length, equals(1));
    expect(itens.first['material_nome'], equals('Granito São Gabriel'));
    expect(itens.first['acabamento_nome'], equals('Meia Esquadria 45º'));

    await db.close();
  });
}
