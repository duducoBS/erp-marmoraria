import 'package:flutter/material.dart';
import '../models/orcamento_model.dart';
import '../models/orcamento_item_model.dart';
import '../models/cliente_model.dart';
import '../models/material_model.dart';
import '../models/acabamento_model.dart';
import '../services/database_service.dart';

class OrcamentoProvider extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();

  List<Orcamento> _orcamentos = [];
  List<Cliente> _clientes = [];
  List<MaterialItem> _materiais = [];
  List<AcabamentoServico> _acabamentos = [];
  bool _isLoading = false;
  String _filtroStatus = 'Todos';
  String _busca = '';

  // Estado do Orçamento em Edição / Calculadora
  int? _editingId;
  Cliente? _selectedCliente;
  DateTime _dataValidade = DateTime.now().add(const Duration(days: 15));
  String _status = 'Rascunho';
  String _observacoes = '';
  List<OrcamentoItem> _itensRascunho = [];

  // Getters
  List<Orcamento> get orcamentos => _orcamentos;
  List<Cliente> get clientes => _clientes;
  List<MaterialItem> get materiais => _materiais;
  List<AcabamentoServico> get acabamentos => _acabamentos;
  bool get isLoading => _isLoading;
  String get filtroStatus => _filtroStatus;
  String get busca => _busca;

  int? get editingId => _editingId;
  Cliente? get selectedCliente => _selectedCliente;
  DateTime get dataValidade => _dataValidade;
  String get status => _status;
  String get observacoes => _observacoes;
  List<OrcamentoItem> get itensRascunho => List.unmodifiable(_itensRascunho);

  double get valorTotalRascunho {
    final total = _itensRascunho.fold(0.0, (sum, item) => sum + item.valorParcial);
    return double.parse(total.toStringAsFixed(2));
  }

  double get m2TotalRascunho {
    final total = _itensRascunho.fold(0.0, (sum, item) => sum + item.m2Total);
    return double.parse(total.toStringAsFixed(4));
  }

  OrcamentoProvider() {
    carregarDados();
  }

  Future<void> carregarDados() async {
    _isLoading = true;
    notifyListeners();

    try {
      _clientes = await _dbService.getClientes();
      _materiais = await _dbService.getMateriais();
      _acabamentos = await _dbService.getAcabamentos();
      await carregarOrcamentos();
    } catch (e) {
      debugPrint('Erro ao carregar dados do orcamento: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> carregarOrcamentos() async {
    _orcamentos = await _dbService.getOrcamentos(
      search: _busca,
      status: _filtroStatus,
    );
    notifyListeners();
  }

  void setFiltroStatus(String status) {
    _filtroStatus = status;
    carregarOrcamentos();
  }

  void setBusca(String query) {
    _busca = query;
    carregarOrcamentos();
  }

  // Métodos da Calculadora / Rascunho
  void iniciarNovoOrcamento() {
    _editingId = null;
    _selectedCliente = _clientes.isNotEmpty ? _clientes.first : null;
    _dataValidade = DateTime.now().add(const Duration(days: 15));
    _status = 'Rascunho';
    _observacoes = '';
    _itensRascunho = [];
    notifyListeners();
  }

  Future<void> editarOrcamento(Orcamento orcamento) async {
    _editingId = orcamento.id;
    _selectedCliente = _clientes.firstWhere(
      (c) => c.id == orcamento.clienteId,
      orElse: () => Cliente(id: orcamento.clienteId, nome: orcamento.clienteNome ?? 'Cliente'),
    );
    try {
      _dataValidade = DateTime.parse(orcamento.dataValidade);
    } catch (_) {
      _dataValidade = DateTime.now().add(const Duration(days: 15));
    }
    _status = orcamento.status;
    _observacoes = orcamento.observacoes;

    // Busca itens do banco
    _itensRascunho = await _dbService.getItensByOrcamentoId(orcamento.id!);
    notifyListeners();
  }

  void setSelectedCliente(Cliente? cliente) {
    _selectedCliente = cliente;
    notifyListeners();
  }

  void setDataValidade(DateTime data) {
    _dataValidade = data;
    notifyListeners();
  }

  void setStatus(String status) {
    _status = status;
    notifyListeners();
  }

  void setObservacoes(String obs) {
    _observacoes = obs;
    notifyListeners();
  }

  void addItemRascunho(OrcamentoItem item) {
    _itensRascunho.add(item);
    notifyListeners();
  }

  void updateItemRascunho(int index, OrcamentoItem item) {
    if (index >= 0 && index < _itensRascunho.length) {
      _itensRascunho[index] = item;
      notifyListeners();
    }
  }

  void removeItemRascunho(int index) {
    if (index >= 0 && index < _itensRascunho.length) {
      _itensRascunho.removeAt(index);
      notifyListeners();
    }
  }

  Future<int?> salvarOrcamento() async {
    if (_selectedCliente == null || _selectedCliente!.id == null) {
      return null;
    }
    if (_itensRascunho.isEmpty) {
      return null;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final hoje = DateTime.now().toIso8601String().substring(0, 10);
      final validade = _dataValidade.toIso8601String().substring(0, 10);

      final orcamento = Orcamento(
        id: _editingId,
        clienteId: _selectedCliente!.id!,
        dataCriacao: hoje,
        dataValidade: validade,
        status: _status,
        valorTotal: valorTotalRascunho,
        observacoes: _observacoes,
      );

      int orcamentoId;
      if (_editingId != null) {
        await _dbService.updateOrcamento(orcamento, _itensRascunho);
        orcamentoId = _editingId!;
      } else {
        orcamentoId = await _dbService.insertOrcamento(orcamento, _itensRascunho);
      }

      await carregarOrcamentos();
      return orcamentoId;
    } catch (e) {
      debugPrint('Erro ao salvar orcamento: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> alterarStatusOrcamento(int id, String novoStatus) async {
    await _dbService.updateOrcamentoStatus(id, novoStatus);
    await carregarOrcamentos();
  }

  Future<void> excluirOrcamento(int id) async {
    await _dbService.deleteOrcamento(id);
    await carregarOrcamentos();
  }
}
