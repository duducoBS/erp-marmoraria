import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/responsive.dart';
import '../../models/conta_model.dart';
import '../../providers/financeiro_provider.dart';
import 'conta_form_dialog.dart';

class FinanceiroView extends StatelessWidget {
  const FinanceiroView({super.key});

  @override
  Widget build(BuildContext context) {
    final financeiro = Provider.of<FinanceiroProvider>(context);
    final isDesktop = Responsive.isDesktop(context);

    final cardReceber = _buildResumoCard(
      title: 'Total a Receber (Pendente)',
      value: Formatters.formatCurrency(financeiro.totalAReceberPendente),
      color: AppColors.success,
      icon: Icons.arrow_downward,
    );

    final cardPagar = _buildResumoCard(
      title: 'Total a Pagar (Pendente)',
      value: Formatters.formatCurrency(financeiro.totalAPagarPendente),
      color: AppColors.danger,
      icon: Icons.arrow_upward,
    );

    final cardSaldo = _buildResumoCard(
      title: 'Saldo Projetado',
      value: Formatters.formatCurrency(financeiro.saldoProjetado),
      color: financeiro.saldoProjetado >= 0 ? AppColors.accent : AppColors.danger,
      icon: Icons.account_balance,
    );

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
                      'Fluxo de Caixa & Financeiro',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Controle de contas a pagar, recebimentos de orçamentos e despesas operacionais',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  ),
                  onPressed: () => _abrirDialogConta(context, financeiro),
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('Novo Lançamento'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Resumo em Cards
            if (isDesktop)
              Row(
                children: [
                  Expanded(child: cardReceber),
                  const SizedBox(width: 14),
                  Expanded(child: cardPagar),
                  const SizedBox(width: 14),
                  Expanded(child: cardSaldo),
                ],
              )
            else
              Column(
                children: [
                  cardReceber,
                  const SizedBox(height: 10),
                  cardPagar,
                  const SizedBox(height: 10),
                  cardSaldo,
                ],
              ),
            const SizedBox(height: 20),

            // Filtros de Tipo e Status
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Text('Filtrar:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        ChoiceChip(
                          label: const Text('Todas as Contas'),
                          selected: financeiro.filtroTipo == 'todos',
                          onSelected: (_) => financeiro.setFiltroTipo('todos'),
                        ),
                        ChoiceChip(
                          label: const Text('A Receber'),
                          selected: financeiro.filtroTipo == 'receber',
                          onSelected: (_) => financeiro.setFiltroTipo('receber'),
                        ),
                        ChoiceChip(
                          label: const Text('A Pagar'),
                          selected: financeiro.filtroTipo == 'pagar',
                          onSelected: (_) => financeiro.setFiltroTipo('pagar'),
                        ),
                      ],
                    ),
                    DropdownButton<String>(
                      value: financeiro.filtroStatus,
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(value: 'Todos', child: Text('Status: Todos')),
                        DropdownMenuItem(value: 'Pendente', child: Text('Status: Pendentes')),
                        DropdownMenuItem(value: 'Pago', child: Text('Status: Pagos/Recebidos')),
                      ],
                      onChanged: (val) {
                        if (val != null) financeiro.setFiltroStatus(val);
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Lista de Contas
            Expanded(
              child: financeiro.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : financeiro.contas.isEmpty
                      ? const Center(child: Text('Nenhum lançamento encontrado para os filtros aplicados.'))
                      : ListView.separated(
                          itemCount: financeiro.contas.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final conta = financeiro.contas[index];
                            final isReceita = conta.isReceber;
                            final color = isReceita ? AppColors.success : AppColors.danger;

                            final iconBox = Container(
                              width: isDesktop ? 48 : 40,
                              height: isDesktop ? 48 : 40,
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                isReceita ? Icons.arrow_downward : Icons.arrow_upward,
                                color: color,
                                size: isDesktop ? 24 : 20,
                              ),
                            );

                            final actionButtons = Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton.filledTonal(
                                  tooltip: conta.isPago ? 'Marcar como Pendente' : 'Marcar como Pago/Recebido',
                                  icon: Icon(
                                    conta.isPago ? Icons.check_circle : Icons.radio_button_unchecked,
                                    color: conta.isPago ? AppColors.success : AppColors.textSecondary,
                                  ),
                                  onPressed: () => financeiro.alternarStatusPagamento(conta),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.edit_outlined,
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? AppColors.secondaryLight
                                        : AppColors.primary,
                                  ),
                                  onPressed: () => _abrirDialogConta(context, financeiro, conta: conta),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: AppColors.danger),
                                  onPressed: () => financeiro.excluirConta(conta.id!),
                                ),
                              ],
                            );

                            if (isDesktop) {
                              return Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      iconBox,
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    conta.descricao,
                                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Chip(
                                                  label: Text(
                                                    isReceita ? 'RECEITA' : 'DESPESA',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.bold,
                                                      color: color,
                                                    ),
                                                  ),
                                                  backgroundColor: color.withValues(alpha: 0.1),
                                                  side: BorderSide.none,
                                                  padding: EdgeInsets.zero,
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Vencimento: ${Formatters.formatDate(conta.dataVencimento)}',
                                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              Formatters.formatCurrency(conta.valor),
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 17,
                                                color: color,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              conta.statusPagamento,
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: conta.isPago ? AppColors.success : AppColors.warning,
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
                                          iconBox,
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              conta.descricao,
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Chip(
                                            label: Text(
                                              isReceita ? 'RECEITA' : 'DESPESA',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: color,
                                              ),
                                            ),
                                            backgroundColor: color.withValues(alpha: 0.1),
                                            side: BorderSide.none,
                                            padding: EdgeInsets.zero,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Vencimento: ${Formatters.formatDate(conta.dataVencimento)}',
                                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                      ),
                                      const Divider(height: 16),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                Formatters.formatCurrency(conta.valor),
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: color,
                                                ),
                                              ),
                                              Text(
                                                conta.statusPagamento,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color: conta.isPago ? AppColors.success : AppColors.warning,
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
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumoCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text(value, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: color)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _abrirDialogConta(BuildContext context, FinanceiroProvider provider, {Conta? conta}) {
    showDialog(
      context: context,
      builder: (ctx) => ContaFormDialog(
        contaInicial: conta,
        onSalvar: (c) => provider.salvarConta(c),
      ),
    );
  }
}
