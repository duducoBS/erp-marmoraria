import 'package:flutter/material.dart';
import '../models/conta_model.dart';
import '../services/database_service.dart';

class FinanceiroProvider extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();

  List<Conta> _contas = [];
  bool _isLoading = false;
  String _filtroTipo = 'todos'; // todos, receber, pagar
  String _filtroStatus = 'Todos'; // Todos, Pendente, Pago

  List<Conta> get contas => _contas;
  bool get isLoading => _isLoading;
  String get filtroTipo => _filtroTipo;
  String get filtroStatus => _filtroStatus;

  double get totalAReceberPendente {
    return _contas
        .where((c) => c.isReceber && !c.isPago)
        .fold(0.0, (sum, c) => sum + c.valor);
  }

  double get totalAPagarPendente {
    return _contas
        .where((c) => c.isPagar && !c.isPago)
        .fold(0.0, (sum, c) => sum + c.valor);
  }

  double get saldoProjetado => totalAReceberPendente - totalAPagarPendente;

  FinanceiroProvider() {
    carregarContas();
  }

  Future<void> carregarContas() async {
    _isLoading = true;
    notifyListeners();

    try {
      _contas = await _dbService.getContas(
        tipo: _filtroTipo,
        status: _filtroStatus,
      );
    } catch (e) {
      debugPrint('Erro ao carregar contas financeiras: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setFiltroTipo(String tipo) {
    _filtroTipo = tipo;
    carregarContas();
  }

  void setFiltroStatus(String status) {
    _filtroStatus = status;
    carregarContas();
  }

  Future<void> alternarStatusPagamento(Conta conta) async {
    if (conta.id == null) return;
    final novoStatus = conta.isPago ? 'Pendente' : 'Pago';
    await _dbService.updateContaStatus(conta.id!, novoStatus);
    await carregarContas();
  }

  Future<void> salvarConta(Conta conta) async {
    if (conta.id != null) {
      await _dbService.updateConta(conta);
    } else {
      await _dbService.insertConta(conta);
    }
    await carregarContas();
  }

  Future<void> excluirConta(int id) async {
    await _dbService.deleteConta(id);
    await carregarContas();
  }
}
