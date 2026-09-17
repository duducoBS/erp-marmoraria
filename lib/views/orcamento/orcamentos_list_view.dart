import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/orcamento_model.dart';
import '../../providers/orcamento_provider.dart';
import '../../services/pdf_service.dart';
import '../../services/whatsapp_service.dart';
import '../../services/database_service.dart';
import 'calculadora_view.dart';

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
            const SizedBox(height: 20),

            // Filtros de Busca e Status
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
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
                            return Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: ChoiceChip(
                                label: Text(st),
                                selected: isSelected,
                                onSelected: (_) => provider.setFiltroStatus(st),
                                selectedColor: AppColors.primary,
                                labelStyle: TextStyle(
                                  color: isSelected ? Colors.white : AppColors.textPrimary,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Badge ID
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: _getStatusColor(orc.status).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  '#${orc.id}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: _getStatusColor(orc.status),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Informações do Orçamento
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
                            color: _getStatusColor(orc.status),
                          ),
                        ),
                        backgroundColor: _getStatusColor(orc.status).withValues(alpha: 0.1),
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

            // Valor Total
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Valor Total:', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  Text(
                    Formatters.formatCurrency(orc.valorTotal),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),

            // Botões de Ação
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.picture_as_pdf, color: AppColors.accent),
                  tooltip: 'Gerar PDF A4',
                  onPressed: () => _imprimirPdf(orc),
                ),
                IconButton(
                  icon: const Icon(Icons.send_to_mobile, color: Color(0xFF25D366)),
                  tooltip: 'Enviar WhatsApp',
                  onPressed: () => _enviarWhatsApp(orc),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
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
            ),
          ],
        ),
      ),
    );
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

  Future<void> _imprimirPdf(Orcamento orc) async {
    final dbService = DatabaseService();
    final cliente = await dbService.getClienteById(orc.clienteId);
    final itens = await dbService.getItensByOrcamentoId(orc.id!);

    if (cliente != null) {
      final orcComItens = orc.copyWith(itens: itens);
      PdfService.gerarEVisualizarPdf(orcamento: orcComItens, cliente: cliente);
    }
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
