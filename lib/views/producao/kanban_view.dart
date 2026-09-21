import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/ordem_servico_model.dart';
import '../../providers/producao_provider.dart';
import 'widgets/os_dialog.dart';

class KanbanView extends StatelessWidget {
  const KanbanView({super.key});

  @override
  Widget build(BuildContext context) {
    final producaoProvider = Provider.of<ProducaoProvider>(context);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar
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
                      'Quadro de Produção & Fábrica (Kanban)',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Arraste os cartões ou toque no botão de avanço para mudar a etapa de produção',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  ),
                  onPressed: () => _abrirDialogNovaOS(context, producaoProvider),
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('Nova OS / Medição'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Colunas do Kanban
            Expanded(
              child: producaoProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: OrdemServico.etapas.map((etapa) {
                              final ordens = producaoProvider.getOrdensPorEtapa(etapa);
                              return _buildKanbanColumn(
                                context,
                                etapa: etapa,
                                ordens: ordens,
                                provider: producaoProvider,
                              );
                            }).toList(),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKanbanColumn(
    BuildContext context, {
    required String etapa,
    required List<OrdemServico> ordens,
    required ProducaoProvider provider,
  }) {
    final color = _getEtapaColor(etapa);
    final label = OrdemServico.getEtapaLabel(etapa);

    return Container(
      width: 290,
      margin: const EdgeInsets.only(right: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header da Coluna
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(13),
                topRight: Radius.circular(13),
              ),
              border: Border(bottom: BorderSide(color: color.withValues(alpha: 0.3))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 5,
                      backgroundColor: color,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: color,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    '${ordens.length}',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: color),
                  ),
                ),
              ],
            ),
          ),

          // Área de Arrastar e Soltar (DragTarget)
          Expanded(
            child: DragTarget<OrdemServico>(
              onWillAcceptWithDetails: (details) => details.data.statusProducao != etapa,
              onAcceptWithDetails: (details) {
                provider.mudarEtapa(details.data.id!, etapa);
              },
              builder: (context, candidateData, rejectedData) {
                final isHighlight = candidateData.isNotEmpty;
                return Container(
                  color: isHighlight ? color.withValues(alpha: 0.08) : Colors.transparent,
                  padding: const EdgeInsets.all(10),
                  child: ordens.isEmpty
                      ? Center(
                          child: Text(
                            'Nenhuma ordem nesta fase',
                            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                          ),
                        )
                      : ListView.separated(
                          itemCount: ordens.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final os = ordens[index];
                            return Draggable<OrdemServico>(
                              data: os,
                              feedback: Material(
                                elevation: 6,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  width: 270,
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: color, width: 2),
                                  ),
                                  child: Text(
                                    os.titulo,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              childWhenDragging: Opacity(
                                opacity: 0.3,
                                child: _buildOsCard(context, os, provider, color),
                              ),
                              child: _buildOsCard(context, os, provider, color),
                            );
                          },
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOsCard(BuildContext context, OrdemServico os, ProducaoProvider provider, Color color) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'OS #${os.id}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.more_horiz, size: 18),
                  onSelected: (val) {
                    if (val == 'Editar') {
                      _abrirDialogEditarOS(context, provider, os);
                    } else if (val == 'Excluir') {
                      provider.excluirOS(os.id!);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'Editar', child: Text('Editar OS')),
                    const PopupMenuItem(value: 'Excluir', child: Text('Excluir OS', style: TextStyle(color: Colors.red))),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              os.titulo,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.person_outline, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    os.clienteNome ?? 'Cliente Desconhecido',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  'Entrega: ${Formatters.formatDate(os.dataEntregaPrevista)}',
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
            if (os.observacoesTecnicas != null && os.observacoesTecnicas!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  os.observacoesTecnicas!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ),
            ],
            const SizedBox(height: 10),

            // Botão de Avanço Rápido
            if (os.proximaEtapa != null)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    side: BorderSide(color: color.withValues(alpha: 0.5)),
                  ),
                  onPressed: () => provider.avancarEtapa(os),
                  icon: const Icon(Icons.arrow_forward, size: 14),
                  label: Text(
                    'Avançar para ${os.proximaEtapa}',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 6),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, size: 14, color: AppColors.success),
                    SizedBox(width: 6),
                    Text(
                      'Produção Concluída',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.success),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getEtapaColor(String etapa) {
    switch (etapa) {
      case 'Medicao':
        return AppColors.kanbanMedicao;
      case 'Corte':
        return AppColors.kanbanCorte;
      case 'Acabamento':
        return AppColors.kanbanAcabamento;
      case 'Montagem':
        return AppColors.kanbanMontagem;
      case 'Concluido':
        return AppColors.kanbanConcluido;
      default:
        return AppColors.primary;
    }
  }

  void _abrirDialogNovaOS(BuildContext context, ProducaoProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => OsDialog(
        onSalvar: (os) => provider.salvarNovaOS(os),
      ),
    );
  }

  void _abrirDialogEditarOS(BuildContext context, ProducaoProvider provider, OrdemServico os) {
    showDialog(
      context: context,
      builder: (ctx) => OsDialog(
        osInicial: os,
        onSalvar: (osAtualizada) => provider.salvarNovaOS(osAtualizada),
      ),
    );
  }
}
