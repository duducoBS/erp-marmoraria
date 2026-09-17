import 'package:flutter/material.dart';
import '../models/ordem_servico_model.dart';
import '../services/database_service.dart';

class ProducaoProvider extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();

  List<OrdemServico> _ordens = [];
  bool _isLoading = false;

  List<OrdemServico> get ordens => _ordens;
  bool get isLoading => _isLoading;

  ProducaoProvider() {
    carregarOrdens();
  }

  Future<void> carregarOrdens() async {
    _isLoading = true;
    notifyListeners();

    try {
      _ordens = await _dbService.getOrdensServico();
    } catch (e) {
      debugPrint('Erro ao carregar ordens de servico: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<OrdemServico> getOrdensPorEtapa(String etapa) {
    return _ordens.where((os) => os.statusProducao == etapa).toList();
  }

  Future<void> avancarEtapa(OrdemServico os) async {
    final proxima = os.proximaEtapa;
    if (proxima != null && os.id != null) {
      await _dbService.updateOrdemServicoStatus(os.id!, proxima);
      await carregarOrdens();
    }
  }

  Future<void> mudarEtapa(int osId, String novoStatus) async {
    await _dbService.updateOrdemServicoStatus(osId, novoStatus);
    await carregarOrdens();
  }

  Future<void> salvarNovaOS(OrdemServico os) async {
    if (os.id != null) {
      await _dbService.updateOrdemServico(os);
    } else {
      await _dbService.insertOrdemServico(os);
    }
    await carregarOrdens();
  }

  Future<void> excluirOS(int id) async {
    await _dbService.deleteOrdemServico(id);
    await carregarOrdens();
  }
}
