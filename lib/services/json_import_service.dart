import 'dart:convert';
import 'database_service.dart';
import '../models/cliente_model.dart';
import '../models/orcamento_model.dart';
import '../models/orcamento_item_model.dart';
import '../models/orcamento_parcela_model.dart';
import '../models/empresa_config_model.dart';

class ImportResult {
  final int orcamentosImportados;
  final int clientesImportados;
  final bool empresaAtualizada;
  final String? erro;

  ImportResult({
    required this.orcamentosImportados,
    required this.clientesImportados,
    required this.empresaAtualizada,
    this.erro,
  });

  bool get sucesso => erro == null;
}

class JsonImportService {
  final DatabaseService _dbService = DatabaseService();

  Future<ImportResult> importarBackupJson(String jsonString) async {
    try {
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      bool empresaAtualizada = false;
      int orcamentosCount = 0;
      int clientesCount = 0;

      // 1. Importa Configurações da Empresa (se houver)
      if (data.containsKey('empresa') && data['empresa'] is Map<String, dynamic>) {
        final emp = data['empresa'] as Map<String, dynamic>;
        final config = EmpresaConfig(
          id: 1,
          nome: emp['nome'] as String? ?? 'EDU MÁRMORES & GRANITOS',
          cnpj: emp['cnpj'] as String? ?? '',
          endereco: emp['endereco'] as String? ?? '',
          especialidades: emp['especialidades'] as String? ?? '',
          fone1: emp['fone1'] as String? ?? '',
          resp1: emp['resp1'] as String? ?? '',
          cidadePadrao: emp['cidadePadrao'] as String? ?? 'São Paulo',
          dadosBancarios: emp['dadosBancarios'] as String? ?? '',
          observacoesPadrao: emp['observacoesPadrao'] as String? ?? '',
        );
        await _dbService.saveEmpresaConfig(config);
        empresaAtualizada = true;
      }

      // 2. Extrai lista de orçamentos (histórico + atual)
      final List<Map<String, dynamic>> orcamentosBrutos = [];
      if (data.containsKey('historico') && data['historico'] is List) {
        for (final item in data['historico']) {
          if (item is Map<String, dynamic>) orcamentosBrutos.add(item);
        }
      }
      if (data.containsKey('orcamentoAtual') && data['orcamentoAtual'] is Map<String, dynamic>) {
        final atual = data['orcamentoAtual'] as Map<String, dynamic>;
        // Só adiciona se tiver cliente e não for duplicado
        if (atual.containsKey('cliente') && atual['cliente'] is Map<String, dynamic>) {
          final jaExiste = orcamentosBrutos.any((o) => o['id'] == atual['id']);
          if (!jaExiste) orcamentosBrutos.add(atual);
        }
      }

      // 3. Processa e insere cada orçamento
      final clientesExistentes = await _dbService.getClientes();
      final materiaisExistentes = await _dbService.getMateriais();
      final materialPadraoId = materiaisExistentes.isNotEmpty ? materiaisExistentes.first.id! : 1;

      for (final orc in orcamentosBrutos) {
        final cliData = orc['cliente'] as Map<String, dynamic>? ?? {};
        final cliNome = (cliData['nome'] as String? ?? '').trim();
        if (cliNome.isEmpty || cliNome == 'Edifício Allure') continue; // Ignora exemplos de teste

        // Localiza ou cadastra o cliente
        Cliente? cliente = clientesExistentes.cast<Cliente?>().firstWhere(
          (c) => c != null && c.nome.toLowerCase() == cliNome.toLowerCase(),
          orElse: () => null,
        );

        if (cliente == null) {
          final novoCliente = Cliente(
            nome: cliNome,
            tipo: (cliData['cpfCnpj'] as String? ?? '').length > 14 ? 'PJ' : 'PF',
            documento: cliData['cpfCnpj'] as String? ?? '',
            telefone: cliData['foneCel'] as String? ?? cliData['foneRes'] as String? ?? '',
            email: cliData['email'] as String? ?? '',
            endereco: '${cliData["endereco"] ?? ""}${cliData["numero"] != null ? ", ${cliData["numero"]}" : ""}'.trim(),
            bairro: cliData['bairro'] as String? ?? '',
            cidade: '${cliData["cidade"] ?? ""} - ${cliData["estado"] ?? ""}'.trim(),
            cep: cliData['cep'] as String? ?? '',
          );
          final idInserido = await _dbService.insertCliente(novoCliente);
          cliente = novoCliente.copyWith(id: idInserido);
          clientesExistentes.add(cliente);
          clientesCount++;
        }

        // Parcelas
        final List<OrcamentoParcela> parcelas = [];
        if (orc.containsKey('parcelas') && orc['parcelas'] is List) {
          for (var i = 0; i < (orc['parcelas'] as List).length; i++) {
            final p = (orc['parcelas'] as List)[i] as Map<String, dynamic>;
            parcelas.add(OrcamentoParcela(
              numero: p['numero'] as int? ?? (i + 1),
              valor: (p['valor'] as num?)?.toDouble() ?? 0.0,
              vencimento: p['vencimento'] as String? ?? '',
            ));
          }
        }

        // Itens
        final List<OrcamentoItem> itens = [];
        if (orc.containsKey('itens') && orc['itens'] is List) {
          for (final itemRaw in orc['itens'] as List) {
            final itemMap = itemRaw as Map<String, dynamic>;
            final qtd = itemMap['qtd'] as int? ?? 1;
            final valor = (itemMap['valor'] as num?)?.toDouble() ?? 0.0;
            final desc = itemMap['descricao'] as String? ?? 'Mercadoria';
            final acab = itemMap['acabamento'] as String? ?? '';
            final cor = itemMap['cor'] as String? ?? '';

            itens.add(OrcamentoItem(
              ambiente: desc,
              materialId: materialPadraoId,
              largura: 0.0,
              comprimento: 0.0,
              quantidade: qtd,
              m2Total: 0.0,
              valorParcial: valor,
              tipoCalculo: 'fixo',
              valorFixo: valor,
              descricao: 'Acabamento: $acab | Rocha/Cor: $cor',
              materialNome: cor.isNotEmpty ? cor : 'Rocha Ornamental',
              acabamentoNome: acab.isNotEmpty ? acab : null,
            ));
          }
        }

        final dataCriacao = orc['data'] as String? ?? DateTime.now().toIso8601String().substring(0, 10);
        final dataValidade = DateTime.now().add(const Duration(days: 15)).toIso8601String().substring(0, 10);
        final double valorTotal = (orc['valorTotal'] as num?)?.toDouble() ?? itens.fold<double>(0.0, (acc, it) => acc + it.valorParcial);

        final novoOrcamento = Orcamento(
          clienteId: cliente.id!,
          dataCriacao: dataCriacao,
          dataValidade: dataValidade,
          status: 'Enviado',
          valorTotal: valorTotal,
          observacoes: orc['observacoes'] as String? ?? '',
          condicaoPagamento: cliData['condPag'] as String? ?? '',
          dadosBancarios: orc['dadosBancarios'] as String? ?? '',
          parcelas: parcelas,
        );

        await _dbService.insertOrcamento(novoOrcamento, itens);
        orcamentosCount++;
      }

      return ImportResult(
        orcamentosImportados: orcamentosCount,
        clientesImportados: clientesCount,
        empresaAtualizada: empresaAtualizada,
      );
    } catch (e) {
      return ImportResult(
        orcamentosImportados: 0,
        clientesImportados: 0,
        empresaAtualizada: false,
        erro: e.toString(),
      );
    }
  }
}
