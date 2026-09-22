import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'initial_data.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('marmoraria.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    // Inicialização do SQLite na Web / WebView2
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
      return await databaseFactory.openDatabase(
        filePath,
        options: OpenDatabaseOptions(
          version: 3,
          onCreate: _createDB,
          onUpgrade: _onUpgrade,
          onConfigure: _onConfigure,
        ),
      );
    }

    // Inicialização do SQLite FFI em plataformas desktop (Windows / Linux)
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;

      final appSupportDir = await getApplicationSupportDirectory();
      final dbFolder = p.join(appSupportDir.path, 'erp_marmoraria');
      final dir = Directory(dbFolder);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      final dbPath = p.join(dbFolder, filePath);
      return await databaseFactory.openDatabase(
        dbPath,
        options: OpenDatabaseOptions(
          version: 3,
          onCreate: _createDB,
          onUpgrade: _onUpgrade,
          onConfigure: _onConfigure,
        ),
      );
    } else {
      // Android / iOS usando caminhos nativos seguros
      final dbPath = await getDatabasesPath();
      final fullPath = p.join(dbPath, filePath);
      return await openDatabase(
        fullPath,
        version: 3,
        onCreate: _createDB,
        onUpgrade: _onUpgrade,
        onConfigure: _onConfigure,
      );
    }
  }

  Future<void> _onConfigure(Database db) async {
    // Ativa chaves estrangeiras no SQLite
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Migração para versão 2: adicionar tipo_calculo, preco_metro e valor_fixo em orcamento_itens
      try {
        await db.execute("ALTER TABLE orcamento_itens ADD COLUMN tipo_calculo TEXT DEFAULT 'metro'");
      } catch (_) {}
      try {
        await db.execute("ALTER TABLE orcamento_itens ADD COLUMN preco_metro REAL DEFAULT 0");
      } catch (_) {}
      try {
        await db.execute("ALTER TABLE orcamento_itens ADD COLUMN valor_fixo REAL DEFAULT 0");
      } catch (_) {}
    }
    if (oldVersion < 3) {
      // Migração para versão 3: adicionar descricao detalhada em orcamento_itens
      try {
        await db.execute("ALTER TABLE orcamento_itens ADD COLUMN descricao TEXT DEFAULT ''");
      } catch (_) {}
    }
  }

  Future<void> _createDB(Database db, int version) async {
    // 1. Tabela Clientes
    await db.execute('''
      CREATE TABLE IF NOT EXISTS clientes (
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

    // 2. Tabela Materiais
    await db.execute('''
      CREATE TABLE IF NOT EXISTS materiais (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        tipo TEXT,
        preco_m2_custo REAL NOT NULL,
        preco_m2_venda REAL NOT NULL,
        espessura TEXT
      )
    ''');

    // 3. Tabela Acabamentos & Serviços
    await db.execute('''
      CREATE TABLE IF NOT EXISTS acabamentos_servicos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        tipo_cobranca TEXT NOT NULL,
        valor REAL NOT NULL
      )
    ''');

    // 4. Tabela Orçamentos
    await db.execute('''
      CREATE TABLE IF NOT EXISTS orcamentos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cliente_id INTEGER NOT NULL,
        data_criacao TEXT NOT NULL,
        data_validade TEXT NOT NULL,
        status TEXT NOT NULL,
        valor_total REAL NOT NULL,
        observacoes TEXT,
        FOREIGN KEY (cliente_id) REFERENCES clientes(id) ON DELETE RESTRICT
      )
    ''');

    // 5. Tabela Orçamento Itens
    await db.execute('''
      CREATE TABLE IF NOT EXISTS orcamento_itens (
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
        descricao TEXT DEFAULT '',
        FOREIGN KEY (orcamento_id) REFERENCES orcamentos(id) ON DELETE CASCADE,
        FOREIGN KEY (material_id) REFERENCES materiais(id) ON DELETE RESTRICT,
        FOREIGN KEY (acabamento_id) REFERENCES acabamentos_servicos(id) ON DELETE SET NULL
      )
    ''');

    // 6. Tabela Ordens de Serviço (Produção)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ordens_servico (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        orcamento_id INTEGER,
        cliente_id INTEGER,
        titulo TEXT NOT NULL,
        status_producao TEXT NOT NULL,
        data_entrega_prevista TEXT,
        observacoes_tecnicas TEXT,
        FOREIGN KEY (orcamento_id) REFERENCES orcamentos(id) ON DELETE SET NULL,
        FOREIGN KEY (cliente_id) REFERENCES clientes(id) ON DELETE SET NULL
      )
    ''');

    // 7. Tabela Contas (Financeiro - Fluxo de Caixa)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS contas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        orcamento_id INTEGER,
        tipo TEXT NOT NULL,
        descricao TEXT NOT NULL,
        valor REAL NOT NULL,
        data_vencimento TEXT NOT NULL,
        status_pagamento TEXT NOT NULL,
        FOREIGN KEY (orcamento_id) REFERENCES orcamentos(id) ON DELETE SET NULL
      )
    ''');

    // Carga de dados iniciais (Seed)
    await _seedInitialData(db);
  }

  Future<void> _seedInitialData(Database db) async {
    // Seed de Materiais
    for (final material in InitialData.defaultMaterials) {
      await db.insert('materiais', material.toMap());
    }

    // Seed de Acabamentos
    for (final acabamento in InitialData.defaultAcabamentos) {
      await db.insert('acabamentos_servicos', acabamento.toMap());
    }

    // Seed de Clientes
    for (final cliente in InitialData.defaultClientes) {
      await db.insert('clientes', cliente.toMap());
    }

    // Seed de Orçamento Demonstrativo
    final now = DateTime.now();
    final hojeStr = now.toIso8601String().substring(0, 10);
    final validadeStr = now.add(const Duration(days: 15)).toIso8601String().substring(0, 10);

    final orcamentoId = await db.insert('orcamentos', {
      'cliente_id': 1,
      'data_criacao': hojeStr,
      'data_validade': validadeStr,
      'status': 'Aprovado',
      'valor_total': 2682.60,
      'observacoes': 'Bancada de cozinha com ilha em Granito Preto São Gabriel com acabamento 45 graus.',
    });

    // Itens do orçamento demonstrativo
    await db.insert('orcamento_itens', {
      'orcamento_id': orcamentoId,
      'ambiente': 'Cozinha Principal',
      'material_id': 1, // Granito Preto São Gabriel (R$ 550/m²)
      'largura': 0.60,
      'comprimento': 3.20,
      'quantidade': 1,
      'm2_total': 2.112, // 1.92 * 1.10
      'perda_percentual': 10.0,
      'acabamento_id': 1, // 45 graus (R$ 60/m)
      'acabamento_quantidade': 3.20,
      'valor_parcial': 1353.60,
      'tipo_calculo': 'metro',
      'preco_metro': 550.00,
      'valor_fixo': 0.0,
      'descricao': 'Bancada principal com furo para cuba de sobrepor e frontão 10cm',
    });

    await db.insert('orcamento_itens', {
      'orcamento_id': orcamentoId,
      'ambiente': 'Ilha Central',
      'material_id': 1, // Granito Preto São Gabriel (R$ 550/m²)
      'largura': 0.90,
      'comprimento': 2.00,
      'quantidade': 1,
      'm2_total': 1.98, // 1.80 * 1.10
      'perda_percentual': 10.0,
      'acabamento_id': 1, // 45 graus (R$ 60/m)
      'acabamento_quantidade': 4.00,
      'valor_parcial': 1329.00,
      'tipo_calculo': 'metro',
      'preco_metro': 550.00,
      'valor_fixo': 0.0,
      'descricao': 'Ilha com saia 4cm em meia esquadria 45º e recorte cooktop',
    });

    // OS Demonstrativa
    final entregaStr = now.add(const Duration(days: 7)).toIso8601String().substring(0, 10);
    await db.insert('ordens_servico', {
      'orcamento_id': orcamentoId,
      'cliente_id': 1,
      'titulo': 'Cozinha e Ilha - Granito São Gabriel',
      'status_producao': 'Corte',
      'data_entrega_prevista': entregaStr,
      'observacoes_tecnicas': 'Atenção ao corte em 45 graus na saia da ilha. Furo para cuba Franke.',
    });

    await db.insert('ordens_servico', {
      'orcamento_id': null,
      'cliente_id': 2,
      'titulo': 'Lavabo Social - Branco Prime',
      'status_producao': 'Medicao',
      'data_entrega_prevista': now.add(const Duration(days: 3)).toIso8601String().substring(0, 10),
      'observacoes_tecnicas': 'Agendada medição técnica no local às 14h.',
    });

    // Contas demonstrativas (Fluxo de Caixa)
    await db.insert('contas', {
      'orcamento_id': orcamentoId,
      'tipo': 'receber',
      'descricao': 'Entrada Pedido Cozinha - Construtora Horizonte',
      'valor': 1341.30,
      'data_vencimento': hojeStr,
      'status_pagamento': 'Pago',
    });

    await db.insert('contas', {
      'orcamento_id': orcamentoId,
      'tipo': 'receber',
      'descricao': 'Saldo Entrega Pedido Cozinha - Construtora Horizonte',
      'valor': 1341.30,
      'data_vencimento': entregaStr,
      'status_pagamento': 'Pendente',
    });

    await db.insert('contas', {
      'orcamento_id': null,
      'tipo': 'pagar',
      'descricao': 'Insumos / Discos de Corte Diamantados',
      'valor': 480.00,
      'data_vencimento': now.add(const Duration(days: 5)).toIso8601String().substring(0, 10),
      'status_pagamento': 'Pendente',
    });
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
