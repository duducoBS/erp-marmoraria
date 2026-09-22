import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/responsive.dart';
import '../../models/orcamento_model.dart';
import '../../providers/orcamento_provider.dart';
import '../../services/pdf_service.dart';
import '../../services/whatsapp_service.dart';
import '../../services/database_service.dart';
import 'calculadora_view.dart';
import 'widgets/empresa_config_dialog.dart';
import 'widgets/importar_json_dialog.dart';

class OrcamentosListView extends StatefulWidget {
  const OrcamentosListView({super.key});

  @override
  State<OrcamentosListView> createState() => _OrcamentosListViewState();
}

class _OrcamentosListViewState extends State<OrcamentosListView> {
  bool _mostrarCalculadora = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_mostrarCalculadora) {
      return CalculadoraView(
        onVoltar: () {
          setState(() => _mostrarCalculadora = false);
        },
      );
    }

    final provider = Provider.of<OrcamentoProvider>(context);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Barra Superior de Título e Novo Orçamento
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 10,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gestão de Orçamentos & Propostas',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Histórico de propostas comerciais para marmoraria',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      onPressed: () => _abrirModalImportarJson(context, provider),
                      icon: const Icon(Icons.file_download_outlined, size: 18),
                      label: const Text('Importar JSON'),
                    ),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      onPressed: () => _abrirModalEmpresa(context, provider),
                      icon: const Icon(Icons.business_outlined, size: 18),
                      label: const Text('Empresa'),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      ),
                      onPressed: () {
                        provider.iniciarNovoOrcamento();
                        setState(() => _mostrarCalculadora = true);
                      },
                      icon: const Icon(Icons.add_shopping_cart, size: 20),
                      label: const Text('Novo Orçamento'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Filtros de Busca e Status
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Responsive.isDesktop(context)
                    ? Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Buscar por cliente, ambiente ou observações...',
                                prefixIcon: const Icon(Icons.search),
                                suffixIcon: _searchController.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear),
                                        onPressed: () {
                                          _searchController.clear();
                                          provider.setBusca('');
                                        },
                                      )
                                    : null,
                              ),
                              onChanged: (val) => provider.setBusca(val),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  'Todos',
                                  'Rascunho',
                                  'Enviado',
                                  'Aprovado',
                                  'Recusado',
                                ].map((st) {
                                  final isSelected = provider.filtroStatus == st;
                                  final isDark = Theme.of(context).brightness == Brightness.dark;
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 6),
                                    child: ChoiceChip(
                                      label: Text(st),
                                      selected: isSelected,
                                      onSelected: (_) => provider.setFiltroStatus(st),
                                      selectedColor: isDark ? AppColors.secondary : AppColors.primary,
                                      labelStyle: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Buscar orçamentos...',
                              prefixIcon: const Icon(Icons.search),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        _searchController.clear();
                                        provider.setBusca('');
                                      },
                                    )
                                  : null,
                            ),
                            onChanged: (val) => provider.setBusca(val),
                          ),
                          const SizedBox(height: 10),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                'Todos',
                                'Rascunho',
                                'Enviado',
                                'Aprovado',
                                'Recusado',
                              ].map((st) {
                                final isSelected = provider.filtroStatus == st;
                                final isDark = Theme.of(context).brightness == Brightness.dark;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child: ChoiceChip(
                                    label: Text(st),
                                    selected: isSelected,
                                    onSelected: (_) => provider.setFiltroStatus(st),
                                    selectedColor: isDark ? AppColors.secondary : AppColors.primary,
                                    labelStyle: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // Listagem de Orçamentos
            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : provider.orcamentos.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.receipt_long_outlined, size: 64, color: AppColors.textMuted),
                              const SizedBox(height: 12),
                              const Text(
                                'Nenhum orçamento encontrado.',
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () {
                                  provider.iniciarNovoOrcamento();
                                  setState(() => _mostrarCalculadora = true);
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('Criar Novo Orçamento'),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          itemCount: provider.orcamentos.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final orc = provider.orcamentos[index];
                            return _buildOrcamentoCard(context, orc, provider);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrcamentoCard(BuildContext context, Orcamento orc, OrcamentoProvider provider) {
    final isDesktop = Responsive.isDesktop(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final statusColor = _getStatusColor(orc.status);

    final badge = Container(
      width: isDesktop ? 54 : 44,
      height: isDesktop ? 54 : 44,
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          '#${orc.id}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isDesktop ? 16 : 14,
            color: statusColor,
          ),
        ),
      ),
    );

    final actionButtons = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.picture_as_pdf, color: AppColors.accent),
          tooltip: 'Gerar PDF A4',
          onPressed: () => _imprimirPdf(orc, provider),
        ),
        IconButton(
          icon: const Icon(Icons.send_to_mobile, color: Color(0xFF25D366)),
          tooltip: 'Enviar WhatsApp',
          onPressed: () => _enviarWhatsApp(orc),
        ),
        IconButton(
          icon: Icon(Icons.edit_outlined, color: isDark ? AppColors.secondaryLight : AppColors.primary),
          tooltip: 'Editar na Calculadora',
          onPressed: () async {
            await provider.editarOrcamento(orc);
            setState(() => _mostrarCalculadora = true);
          },
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (val) async {
            if (val == 'Aprovado' || val == 'Recusado' || val == 'Enviado') {
              await provider.alterarStatusOrcamento(orc.id!, val);
            } else if (val == 'Excluir') {
              _confirmarExclusao(context, orc.id!, provider);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'Aprovado', child: Text('Marcar como Aprovado (Gera OS)')),
            const PopupMenuItem(value: 'Enviado', child: Text('Marcar como Enviado')),
            const PopupMenuItem(value: 'Recusado', child: Text('Marcar como Recusado')),
            const PopupMenuDivider(),
            const PopupMenuItem(value: 'Excluir', child: Text('Excluir Orçamento', style: TextStyle(color: Colors.red))),
          ],
        ),
      ],
    );

    if (isDesktop) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              badge,
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          orc.clienteNome ?? 'Cliente Desconhecido',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(width: 10),
                        Chip(
                          label: Text(
                            orc.status,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                          backgroundColor: statusColor.withValues(alpha: 0.1),
                          side: BorderSide.none,
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Emissão: ${Formatters.formatDate(orc.dataCriacao)} • Validade: ${Formatters.formatDate(orc.dataValidade)}',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                    if (orc.observacoes.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          orc.observacoes,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Valor Total:', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    Text(
                      Formatters.formatCurrency(orc.valorTotal),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: isDark ? const Color(0xFF38BDF8) : AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              actionButtons,
            ],
          ),
        ),
      );
    } else {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  badge,
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          orc.clienteNome ?? 'Cliente Desconhecido',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Validade: ${Formatters.formatDate(orc.dataValidade)}',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Chip(
                    label: Text(
                      orc.status,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                    backgroundColor: statusColor.withValues(alpha: 0.1),
                    side: BorderSide.none,
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
              if (orc.observacoes.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  orc.observacoes,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
              ],
              const Divider(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Valor Total:', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                      Text(
                        Formatters.formatCurrency(orc.valorTotal),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: isDark ? const Color(0xFF38BDF8) : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  actionButtons,
                ],
              ),
            ],
          ),
        ),
      );
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Aprovado':
        return AppColors.success;
      case 'Enviado':
        return AppColors.accent;
      case 'Recusado':
        return AppColors.danger;
      default:
        return AppColors.secondary;
    }
  }

  Future<void> _imprimirPdf(Orcamento orc, OrcamentoProvider provider) async {
    final dbService = DatabaseService();
    final cliente = await dbService.getClienteById(orc.clienteId);
    final itens = await dbService.getItensByOrcamentoId(orc.id!);

    if (cliente != null) {
      final orcComItens = orc.copyWith(itens: itens);
      PdfService.gerarEVisualizarPdf(
        orcamento: orcComItens,
        cliente: cliente,
        empresaConfig: provider.empresaConfig,
      );
    }
  }

  void _abrirModalEmpresa(BuildContext context, OrcamentoProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => EmpresaConfigDialog(
        configAtual: provider.empresaConfig,
        onSalvar: (novaConfig) async {
          await provider.salvarConfiguracoesEmpresa(novaConfig);
          if (mounted) {
            ScaffoldMessenger.of(this.context).showSnackBar(
              const SnackBar(content: Text('Configurações da empresa salvas com sucesso!')),
            );
          }
        },
      ),
    );
  }

  void _abrirModalImportarJson(BuildContext context, OrcamentoProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => ImportarJsonDialog(
        onImportado: () async {
          await provider.carregarDados();
        },
      ),
    );
  }

  Future<void> _enviarWhatsApp(Orcamento orc) async {
    final dbService = DatabaseService();
    final cliente = await dbService.getClienteById(orc.clienteId);
    final itens = await dbService.getItensByOrcamentoId(orc.id!);

    if (cliente != null) {
      final orcComItens = orc.copyWith(itens: itens);
      final texto = WhatsAppService.gerarTextoProposta(orcamento: orcComItens, cliente: cliente);
      WhatsAppService.enviarWhatsApp(telefone: cliente.telefone, mensagem: texto);
    }
  }

  void _confirmarExclusao(BuildContext context, int id, OrcamentoProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir Orçamento?'),
        content: Text('Deseja realmente excluir o orçamento #$id? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () {
              Navigator.of(ctx).pop();
              provider.excluirOrcamento(id);
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}
