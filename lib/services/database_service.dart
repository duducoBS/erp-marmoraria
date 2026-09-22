import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/cliente_model.dart';
import '../models/material_model.dart';
import '../models/acabamento_model.dart';
import '../models/orcamento_model.dart';
import '../models/orcamento_item_model.dart';
import '../models/ordem_servico_model.dart';
import '../models/conta_model.dart';
import '../models/empresa_config_model.dart';

class DatabaseService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<Database> get _db => _dbHelper.database;

  // ==================== CLIENTES ====================
  Future<List<Cliente>> getClientes({String? search}) async {
    final db = await _db;
    List<Map<String, dynamic>> results;
    if (search != null && search.trim().isNotEmpty) {
      final term = '%${search.trim()}%';
      results = await db.query(
        'clientes',
        where: 'nome LIKE ? OR documento LIKE ? OR telefone LIKE ? OR cidade LIKE ?',
        whereArgs: [term, term, term, term],
        orderBy: 'nome ASC',
      );
    } else {
      results = await db.query('clientes', orderBy: 'nome ASC');
    }
    return results.map((m) => Cliente.fromMap(m)).toList();
  }

  Future<Cliente?> getClienteById(int id) async {
    final db = await _db;
    final results = await db.query('clientes', where: 'id = ?', whereArgs: [id]);
    if (results.isNotEmpty) {
      return Cliente.fromMap(results.first);
    }
    return null;
  }

  Future<int> insertCliente(Cliente cliente) async {
    final db = await _db;
    return await db.insert('clientes', cliente.toMap());
  }

  Future<int> updateCliente(Cliente cliente) async {
    final db = await _db;
    return await db.update(
      'clientes',
      cliente.toMap(),
      where: 'id = ?',
      whereArgs: [cliente.id],
    );
  }

  Future<int> deleteCliente(int id) async {
    final db = await _db;
    return await db.delete('clientes', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== MATERIAIS ====================
  Future<List<MaterialItem>> getMateriais() async {
    final db = await _db;
    final results = await db.query('materiais', orderBy: 'nome ASC');
    return results.map((m) => MaterialItem.fromMap(m)).toList();
  }

  Future<int> insertMaterial(MaterialItem material) async {
    final db = await _db;
    return await db.insert('materiais', material.toMap());
  }

  Future<int> updateMaterial(MaterialItem material) async {
    final db = await _db;
    return await db.update(
      'materiais',
      material.toMap(),
      where: 'id = ?',
      whereArgs: [material.id],
    );
  }

  Future<int> deleteMaterial(int id) async {
    final db = await _db;
    return await db.delete('materiais', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== ACABAMENTOS ====================
  Future<List<AcabamentoServico>> getAcabamentos() async {
    final db = await _db;
    final results = await db.query('acabamentos_servicos', orderBy: 'nome ASC');
    return results.map((m) => AcabamentoServico.fromMap(m)).toList();
  }

  Future<int> insertAcabamento(AcabamentoServico acabamento) async {
    final db = await _db;
    return await db.insert('acabamentos_servicos', acabamento.toMap());
  }

  Future<int> updateAcabamento(AcabamentoServico acabamento) async {
    final db = await _db;
    return await db.update(
      'acabamentos_servicos',
      acabamento.toMap(),
      where: 'id = ?',
      whereArgs: [acabamento.id],
    );
  }

  Future<int> deleteAcabamento(int id) async {
    final db = await _db;
    return await db.delete('acabamentos_servicos', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== ORÇAMENTOS & ITENS ====================
  Future<List<Orcamento>> getOrcamentos({String? search, String? status}) async {
    final db = await _db;
    String query = '''
      SELECT o.*, c.nome AS cliente_nome, c.telefone AS cliente_telefone,
             c.endereco AS cliente_endereco, c.bairro AS cliente_bairro,
             c.cidade AS cliente_cidade, c.documento AS cliente_documento,
             c.email AS cliente_email
      FROM orcamentos o
      LEFT JOIN clientes c ON o.cliente_id = c.id
      WHERE 1=1
    ''';
    final List<dynamic> args = [];

    if (status != null && status != 'Todos') {
      query += ' AND o.status = ?';
      args.add(status);
    }

    if (search != null && search.trim().isNotEmpty) {
      query += ' AND (c.nome LIKE ? OR o.observacoes LIKE ?)';
      final term = '%${search.trim()}%';
      args.add(term);
      args.add(term);
    }

    query += ' ORDER BY o.id DESC';

    final results = await db.rawQuery(query, args);
    return results.map((m) => Orcamento.fromMap(m)).toList();
  }

  Future<Orcamento?> getOrcamentoById(int id) async {
    final db = await _db;
    final results = await db.rawQuery('''
      SELECT o.*, c.nome AS cliente_nome, c.telefone AS cliente_telefone,
             c.endereco AS cliente_endereco, c.bairro AS cliente_bairro,
             c.cidade AS cliente_cidade, c.documento AS cliente_documento,
             c.email AS cliente_email
      FROM orcamentos o
      LEFT JOIN clientes c ON o.cliente_id = c.id
      WHERE o.id = ?
    ''', [id]);

    if (results.isEmpty) return null;

    final itens = await getItensByOrcamentoId(id);
    return Orcamento.fromMap(results.first, itens: itens);
  }

  Future<List<OrcamentoItem>> getItensByOrcamentoId(int orcamentoId) async {
    final db = await _db;
    final results = await db.rawQuery('''
      SELECT i.*, 
             m.nome AS material_nome,
             a.nome AS acabamento_nome,
             a.tipo_cobranca AS acabamento_tipo_cobranca
      FROM orcamento_itens i
      LEFT JOIN materiais m ON i.material_id = m.id
      LEFT JOIN acabamentos_servicos a ON i.acabamento_id = a.id
      WHERE i.orcamento_id = ?
      ORDER BY i.id ASC
    ''', [orcamentoId]);

    return results.map((m) => OrcamentoItem.fromMap(m)).toList();
  }

  Future<int> insertOrcamento(Orcamento orcamento, List<OrcamentoItem> itens) async {
    final db = await _db;
    return await db.transaction<int>((txn) async {
      final orcamentoId = await txn.insert('orcamentos', orcamento.toMap());

      for (final item in itens) {
        final itemMap = item.copyWith(orcamentoId: orcamentoId).toMap();
        await txn.insert('orcamento_itens', itemMap);
      }

      // Se o orçamento já for criado como Aprovado, gera automaticamente OS e Conta
      if (orcamento.status == 'Aprovado') {
        await _criarOSAutomatica(txn, orcamentoId, orcamento);
        await _criarContaAutomatica(txn, orcamentoId, orcamento);
      }

      return orcamentoId;
    });
  }

  Future<void> updateOrcamento(Orcamento orcamento, List<OrcamentoItem> itens) async {
    final db = await _db;
    await db.transaction((txn) async {
      await txn.update(
        'orcamentos',
        orcamento.toMap(),
        where: 'id = ?',
        whereArgs: [orcamento.id],
      );

      // Remove itens antigos e reinsere atualizados
      await txn.delete('orcamento_itens', where: 'orcamento_id = ?', whereArgs: [orcamento.id]);
      for (final item in itens) {
        final itemMap = item.copyWith(orcamentoId: orcamento.id).toMap();
        await txn.insert('orcamento_itens', itemMap);
      }

      // Se mudou para Aprovado e não tinha OS, cria
      if (orcamento.status == 'Aprovado') {
        final osExistente = await txn.query('ordens_servico', where: 'orcamento_id = ?', whereArgs: [orcamento.id]);
        if (osExistente.isEmpty) {
          await _criarOSAutomatica(txn, orcamento.id!, orcamento);
        }
        final contaExistente = await txn.query('contas', where: 'orcamento_id = ?', whereArgs: [orcamento.id]);
        if (contaExistente.isEmpty) {
          await _criarContaAutomatica(txn, orcamento.id!, orcamento);
        }
      }
    });
  }

  Future<void> updateOrcamentoStatus(int id, String newStatus) async {
    final db = await _db;
    await db.transaction((txn) async {
      await txn.update('orcamentos', {'status': newStatus}, where: 'id = ?', whereArgs: [id]);

      if (newStatus == 'Aprovado') {
        final orcamentoMap = (await txn.query('orcamentos', where: 'id = ?', whereArgs: [id])).first;
        final orcamento = Orcamento.fromMap(orcamentoMap);

        final osExistente = await txn.query('ordens_servico', where: 'orcamento_id = ?', whereArgs: [id]);
        if (osExistente.isEmpty) {
          await _criarOSAutomatica(txn, id, orcamento);
        }

        final contaExistente = await txn.query('contas', where: 'orcamento_id = ?', whereArgs: [id]);
        if (contaExistente.isEmpty) {
          await _criarContaAutomatica(txn, id, orcamento);
        }
      }
    });
  }

  Future<void> _criarOSAutomatica(dynamic txn, int orcamentoId, Orcamento orcamento) async {
    final hoje = DateTime.now();
    final entrega = hoje.add(const Duration(days: 10)).toIso8601String().substring(0, 10);
    await txn.insert('ordens_servico', {
      'orcamento_id': orcamentoId,
      'cliente_id': orcamento.clienteId,
      'titulo': 'Pedido Orçamento #$orcamentoId',
      'status_producao': 'Medicao',
      'data_entrega_prevista': entrega,
      'observacoes_tecnicas': orcamento.observacoes,
    });
  }

  Future<void> _criarContaAutomatica(dynamic txn, int orcamentoId, Orcamento orcamento) async {
    final hoje = DateTime.now();
    final vencimentoPadrao = hoje.add(const Duration(days: 15)).toIso8601String().substring(0, 10);

    if (orcamento.parcelas.isNotEmpty) {
      for (final p in orcamento.parcelas) {
        await txn.insert('contas', {
          'orcamento_id': orcamentoId,
          'tipo': 'receber',
          'descricao': 'Orçamento #$orcamentoId - Parcela ${p.numero}/${orcamento.parcelas.length}',
          'valor': p.valor,
          'data_vencimento': p.vencimento.isNotEmpty ? p.vencimento : vencimentoPadrao,
          'status_pagamento': 'Pendente',
        });
      }
    } else {
      await txn.insert('contas', {
        'orcamento_id': orcamentoId,
        'tipo': 'receber',
        'descricao': 'Recebimento Orçamento #$orcamentoId',
        'valor': orcamento.valorTotal,
        'data_vencimento': vencimentoPadrao,
        'status_pagamento': 'Pendente',
      });
    }
  }

  Future<int> deleteOrcamento(int id) async {
    final db = await _db;
    return await db.delete('orcamentos', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== ORDENS DE SERVIÇO (KANBAN) ====================
  Future<List<OrdemServico>> getOrdensServico({String? status}) async {
    final db = await _db;
    String query = '''
      SELECT os.*, 
             c.nome AS cliente_nome, 
             c.telefone AS cliente_telefone,
             c.endereco AS cliente_endereco
      FROM ordens_servico os
      LEFT JOIN clientes c ON os.cliente_id = c.id
      WHERE 1=1
    ''';
    final List<dynamic> args = [];

    if (status != null && status != 'Todos') {
      query += ' AND os.status_producao = ?';
      args.add(status);
    }

    query += ' ORDER BY os.id DESC';

    final results = await db.rawQuery(query, args);
    return results.map((m) => OrdemServico.fromMap(m)).toList();
  }

  Future<int> insertOrdemServico(OrdemServico os) async {
    final db = await _db;
    return await db.insert('ordens_servico', os.toMap());
  }

  Future<int> updateOrdemServico(OrdemServico os) async {
    final db = await _db;
    return await db.update(
      'ordens_servico',
      os.toMap(),
      where: 'id = ?',
      whereArgs: [os.id],
    );
  }

  Future<int> updateOrdemServicoStatus(int id, String novoStatus) async {
    final db = await _db;
    return await db.update(
      'ordens_servico',
      {'status_producao': novoStatus},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteOrdemServico(int id) async {
    final db = await _db;
    return await db.delete('ordens_servico', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== CONTAS (FINANCEIRO) ====================
  Future<List<Conta>> getContas({String? tipo, String? status}) async {
    final db = await _db;
    String query = 'SELECT * FROM contas WHERE 1=1';
    final List<dynamic> args = [];

    if (tipo != null && tipo != 'todos') {
      query += ' AND tipo = ?';
      args.add(tipo);
    }

    if (status != null && status != 'Todos') {
      query += ' AND status_pagamento = ?';
      args.add(status);
    }

    query += ' ORDER BY data_vencimento ASC';

    final results = await db.rawQuery(query, args);
    return results.map((m) => Conta.fromMap(m)).toList();
  }

  Future<int> insertConta(Conta conta) async {
    final db = await _db;
    return await db.insert('contas', conta.toMap());
  }

  Future<int> updateConta(Conta conta) async {
    final db = await _db;
    return await db.update(
      'contas',
      conta.toMap(),
      where: 'id = ?',
      whereArgs: [conta.id],
    );
  }

  Future<int> updateContaStatus(int id, String novoStatus) async {
    final db = await _db;
    return await db.update(
      'contas',
      {'status_pagamento': novoStatus},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteConta(int id) async {
    final db = await _db;
    return await db.delete('contas', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== DASHBOARD & KPIS ====================
  Future<Map<String, dynamic>> getDashboardMetrics() async {
    final db = await _db;
    final now = DateTime.now();
    final mesAtualStr = '${now.year}-${now.month.toString().padLeft(2, '0')}%';

    // Total de orçamentos no mês
    final orcamentosMesResult = await db.rawQuery(
      'SELECT COUNT(*) as total, SUM(valor_total) as valor FROM orcamentos WHERE data_criacao LIKE ?',
      [mesAtualStr],
    );
    final totalOrcamentosMes = Sqflite.firstIntValue(orcamentosMesResult) ?? 0;
    final valorOrcamentosMes = (orcamentosMesResult.first['valor'] as num?)?.toDouble() ?? 0.0;

    // Pedidos em produção (não concluídos)
    final osProducaoResult = await db.rawQuery(
      "SELECT COUNT(*) as total FROM ordens_servico WHERE status_producao != 'Concluido'",
    );
    final totalProducao = Sqflite.firstIntValue(osProducaoResult) ?? 0;

    // Entregas da semana (próximos 7 dias)
    final hojeStr = now.toIso8601String().substring(0, 10);
    final fimSemanaStr = now.add(const Duration(days: 7)).toIso8601String().substring(0, 10);
    final entregasSemanaResult = await db.rawQuery(
      "SELECT COUNT(*) as total FROM ordens_servico WHERE data_entrega_prevista BETWEEN ? AND ? AND status_producao != 'Concluido'",
      [hojeStr, fimSemanaStr],
    );
    final totalEntregasSemana = Sqflite.firstIntValue(entregasSemanaResult) ?? 0;

    // Financeiro: Total a Receber e a Pagar pendentes
    final aReceberResult = await db.rawQuery(
      "SELECT SUM(valor) as total FROM contas WHERE tipo = 'receber' AND status_pagamento = 'Pendente'",
    );
    final totalAReceber = (aReceberResult.first['total'] as num?)?.toDouble() ?? 0.0;

    final aPagarResult = await db.rawQuery(
      "SELECT SUM(valor) as total FROM contas WHERE tipo = 'pagar' AND status_pagamento = 'Pendente'",
    );
    final totalAPagar = (aPagarResult.first['total'] as num?)?.toDouble() ?? 0.0;

    return {
      'totalOrcamentosMes': totalOrcamentosMes,
      'valorOrcamentosMes': valorOrcamentosMes,
      'totalProducao': totalProducao,
      'totalEntregasSemana': totalEntregasSemana,
      'totalAReceber': totalAReceber,
      'totalAPagar': totalAPagar,
    };
  }

  // ==================== CONFIGURAÇÃO DA EMPRESA ====================
  Future<EmpresaConfig> getEmpresaConfig() async {
    final db = await _db;
    final results = await db.query('empresa_config', where: 'id = 1');
    if (results.isNotEmpty) {
      return EmpresaConfig.fromMap(results.first);
    }
    return EmpresaConfig();
  }

  Future<void> saveEmpresaConfig(EmpresaConfig config) async {
    final db = await _db;
    await db.insert(
      'empresa_config',
      config.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
