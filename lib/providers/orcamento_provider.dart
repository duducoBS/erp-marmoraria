import 'package:flutter/material.dart';
import '../models/orcamento_model.dart';
import '../models/orcamento_item_model.dart';
import '../models/orcamento_parcela_model.dart';
import '../models/cliente_model.dart';
import '../models/material_model.dart';
import '../models/acabamento_model.dart';
import '../models/empresa_config_model.dart';
import '../services/database_service.dart';

class OrcamentoProvider extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();

  List<Orcamento> _orcamentos = [];
  List<Cliente> _clientes = [];
  List<MaterialItem> _materiais = [];
  List<AcabamentoServico> _acabamentos = [];
  EmpresaConfig _empresaConfig = EmpresaConfig();
  bool _isLoading = false;
  String _filtroStatus = 'Todos';
  String _busca = '';

  // Estado do Orçamento em Edição / Calculadora
  int? _editingId;
  Cliente? _selectedCliente;
  DateTime _dataValidade = DateTime.now().add(const Duration(days: 15));
  String _status = 'Rascunho';
  String _observacoes = '';
  String _condicaoPagamento = '50% entrada + 50% na colocação';
  String _dadosBancarios = 'Caixa Econômica Ag: 0242 Op: 013 CP: 7675-7 / PIX: 148.374.878-23 Cicero Eduardo dos Santos';
  List<OrcamentoParcela> _parcelas = [];
  List<OrcamentoItem> _itensRascunho = [];

  // Getters
  List<Orcamento> get orcamentos => _orcamentos;
  List<Cliente> get clientes => _clientes;
  List<MaterialItem> get materiais => _materiais;
  List<AcabamentoServico> get acabamentos => _acabamentos;
  EmpresaConfig get empresaConfig => _empresaConfig;
  bool get isLoading => _isLoading;
  String get filtroStatus => _filtroStatus;
  String get busca => _busca;

  int? get editingId => _editingId;
  Cliente? get selectedCliente => _selectedCliente;
  DateTime get dataValidade => _dataValidade;
  String get status => _status;
  String get observacoes => _observacoes;
  String get condicaoPagamento => _condicaoPagamento;
  String get dadosBancarios => _dadosBancarios;
  List<OrcamentoParcela> get parcelas => List.unmodifiable(_parcelas);
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
      _empresaConfig = await _dbService.getEmpresaConfig();
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

  Future<void> salvarConfiguracoesEmpresa(EmpresaConfig config) async {
    await _dbService.saveEmpresaConfig(config);
    _empresaConfig = config;
    notifyListeners();
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
    _observacoes = _empresaConfig.observacoesPadrao.isNotEmpty
        ? _empresaConfig.observacoesPadrao
        : 'Material para instalação será por conta do cliente.';
    _condicaoPagamento = '50% entrada + 50% na colocação';
    _dadosBancarios = _empresaConfig.dadosBancarios.isNotEmpty
        ? _empresaConfig.dadosBancarios
        : 'Caixa Econômica Ag: 0242 Op: 013 CP: 7675-7 / PIX: 148.374.878-23 Cicero Eduardo dos Santos';
    _parcelas = [];
    _itensRascunho = [];
    notifyListeners();
  }

  Future<void> editarOrcamento(Orcamento orcamento) async {
    _editingId = orcamento.id;
    _selectedCliente = _clientes.firstWhere(
      (c) => c.id == orcamento.clienteId,
      orElse: () => Cliente(
        id: orcamento.clienteId,
        nome: orcamento.clienteNome ?? 'Cliente',
        telefone: orcamento.clienteTelefone ?? '',
        endereco: orcamento.clienteEndereco ?? '',
        bairro: orcamento.clienteBairro ?? '',
        cidade: orcamento.clienteCidade ?? '',
        documento: orcamento.clienteDocumento ?? '',
        email: orcamento.clienteEmail ?? '',
      ),
    );
    try {
      _dataValidade = DateTime.parse(orcamento.dataValidade);
    } catch (_) {
      _dataValidade = DateTime.now().add(const Duration(days: 15));
    }
    _status = orcamento.status;
    _observacoes = orcamento.observacoes;
    _condicaoPagamento = orcamento.condicaoPagamento.isNotEmpty
        ? orcamento.condicaoPagamento
        : '50% entrada + 50% na colocação';
    _dadosBancarios = orcamento.dadosBancarios.isNotEmpty
        ? orcamento.dadosBancarios
        : _empresaConfig.dadosBancarios;
    _parcelas = List.from(orcamento.parcelas);

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

  void setCondicaoPagamento(String cond) {
    _condicaoPagamento = cond;
    notifyListeners();
  }

  void setDadosBancarios(String dados) {
    _dadosBancarios = dados;
    notifyListeners();
  }

  void gerarParcelasAutomaticas(int quantidade) {
    if (quantidade <= 0) return;
    final total = valorTotalRascunho;
    final valorBase = double.parse((total / quantidade).toStringAsFixed(2));
    final agora = DateTime.now();

    _parcelas.clear();
    double somaParcelas = 0.0;

    for (int i = 1; i <= quantidade; i++) {
      final vencimento = agora.add(Duration(days: 30 * i)).toIso8601String().substring(0, 10);
      double valor = (i == quantidade) ? double.parse((total - somaParcelas).toStringAsFixed(2)) : valorBase;
      somaParcelas += valor;
      _parcelas.add(OrcamentoParcela(
        numero: i,
        valor: valor,
        vencimento: vencimento,
      ));
    }
    notifyListeners();
  }

  void addParcela(OrcamentoParcela parcela) {
    _parcelas.add(parcela);
    notifyListeners();
  }

  void updateParcela(int index, OrcamentoParcela parcela) {
    if (index >= 0 && index < _parcelas.length) {
      _parcelas[index] = parcela;
      notifyListeners();
    }
  }

  void removeParcela(int index) {
    if (index >= 0 && index < _parcelas.length) {
      _parcelas.removeAt(index);
      notifyListeners();
    }
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
        condicaoPagamento: _condicaoPagamento,
        dadosBancarios: _dadosBancarios,
        parcelas: _parcelas,
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
