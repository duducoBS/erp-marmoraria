import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/responsive.dart';
import '../../providers/app_provider.dart';
import '../../providers/orcamento_provider.dart';
import '../../providers/producao_provider.dart';
import '../../providers/financeiro_provider.dart';
import '../../services/database_service.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final DatabaseService _dbService = DatabaseService();
  Map<String, dynamic>? _metrics;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarMetricas();
  }

  Future<void> _carregarMetricas() async {
    setState(() => _isLoading = true);
    try {
      final metrics = await _dbService.getDashboardMetrics();
      if (mounted) {
        setState(() {
          _metrics = metrics;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final producaoProvider = Provider.of<ProducaoProvider>(context);
    final isDesktop = Responsive.isDesktop(context);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final totalOrcamentos = _metrics?['totalOrcamentosMes'] ?? 0;
    final valorOrcamentos = _metrics?['valorOrcamentosMes'] ?? 0.0;
    final totalProducao = _metrics?['totalProducao'] ?? 0;
    final totalEntregas = _metrics?['totalEntregasSemana'] ?? 0;
    final totalAReceber = _metrics?['totalAReceber'] ?? 0.0;

    return RefreshIndicator(
      onRefresh: () async {
        await _carregarMetricas();
        await producaoProvider.carregarOrdens();
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner de Boas-vindas e Ações Rápidas
            _buildWelcomeHeader(context, appProvider, isDesktop: isDesktop),
            const SizedBox(height: 24),

            // Grid de Cards com Indicadores (KPIs)
            _buildMetricsGrid(
              isDesktop: isDesktop,
              totalOrcamentos: totalOrcamentos,
              valorOrcamentos: valorOrcamentos,
              totalProducao: totalProducao,
              totalEntregas: totalEntregas,
              totalAReceber: totalAReceber,
            ),
            const SizedBox(height: 28),

            // Seção de Produção em Andamento & Próximas Entregas
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: _buildOrdensAtivasCard(producaoProvider, appProvider),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    flex: 2,
                    child: _buildResumoFinanceiroCard(context),
                  ),
                ],
              )
            else
              Column(
                children: [
                  _buildOrdensAtivasCard(producaoProvider, appProvider),
                  const SizedBox(height: 20),
                  _buildResumoFinanceiroCard(context),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(BuildContext context, AppProvider appProvider, {required bool isDesktop}) {
    final titleSection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(3),
              child: Image.asset('assets/images/logo_edu.png', fit: BoxFit.contain),
            ),
            const SizedBox(width: 10),
            const Text(
              'ERP Marmoraria',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Gestão de chapas, medições na obra, ordens de serviço e fluxo financeiro.',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13),
        ),
      ],
    );

    final actionsSection = Wrap(
      spacing: 10,
      runSpacing: 8,
      children: [
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onPressed: () {
            final orcamentoProvider = Provider.of<OrcamentoProvider>(context, listen: false);
            orcamentoProvider.iniciarNovoOrcamento();
            appProvider.openNovoOrcamento();
          },
          icon: const Icon(Icons.add_shopping_cart, size: 18),
          label: const Text('Novo Orçamento'),
        ),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: Colors.white70),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
          onPressed: () => appProvider.openNovaMedicao(),
          icon: const Icon(Icons.straighten, size: 18),
          label: const Text('Produção & Medição'),
        ),
      ],
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: isDesktop
          ? Row(
              children: [
                Expanded(child: titleSection),
                const SizedBox(width: 16),
                actionsSection,
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                titleSection,
                const SizedBox(height: 16),
                actionsSection,
              ],
            ),
    );
  }

  Widget _buildMetricsGrid({
    required bool isDesktop,
    required int totalOrcamentos,
    required double valorOrcamentos,
    required int totalProducao,
    required int totalEntregas,
    required double totalAReceber,
  }) {
    final cards = [
      _buildMetricCard(
        title: 'Orçamentos do Mês',
        value: totalOrcamentos.toString(),
        subtitle: Formatters.formatCurrency(valorOrcamentos),
        icon: Icons.request_quote_outlined,
        color: AppColors.accent,
      ),
      _buildMetricCard(
        title: 'Pedidos em Produção',
        value: '$totalProducao OS',
        subtitle: 'Corte, Acabamento e Montagem',
        icon: Icons.precision_manufacturing_outlined,
        color: AppColors.secondary,
      ),
      _buildMetricCard(
        title: 'Entregas da Semana',
        value: totalEntregas.toString(),
        subtitle: 'Próximos 7 dias',
        icon: Icons.local_shipping_outlined,
        color: AppColors.warning,
      ),
      _buildMetricCard(
        title: 'A Receber no Mês',
        value: Formatters.formatCurrency(totalAReceber),
        subtitle: 'Contas a receber pendentes',
        icon: Icons.account_balance_wallet_outlined,
        color: AppColors.success,
      ),
    ];

    if (isDesktop) {
      return Row(
        children: cards.map((c) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 6), child: c))).toList(),
      );
    } else {
      return Column(
        children: cards.map((c) => Padding(padding: const EdgeInsets.only(bottom: 12), child: c)).toList(),
      );
    }
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdensAtivasCard(ProducaoProvider producaoProvider, AppProvider appProvider) {
    final ordens = producaoProvider.ordens.where((os) => os.statusProducao != 'Concluido').take(5).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.view_kanban_outlined, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text(
                      'Ordens de Produção Ativas',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () => appProvider.openNovaMedicao(),
                  icon: const Icon(Icons.arrow_forward, size: 16),
                  label: const Text('Ver Kanban'),
                ),
              ],
            ),
            const Divider(),
            if (ordens.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: Text('Nenhuma ordem de serviço ativa no momento.')),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: ordens.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final os = ordens[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: _getStatusColor(os.statusProducao).withValues(alpha: 0.15),
                      child: Text(
                        '#${os.id}',
                        style: TextStyle(
                          color: _getStatusColor(os.statusProducao),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(os.titulo, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: Text(
                      'Cliente: ${os.clienteNome ?? "N/A"} • Previsão: ${Formatters.formatDate(os.dataEntregaPrevista)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: Chip(
                      label: Text(
                        os.statusProducao,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(os.statusProducao),
                        ),
                      ),
                      backgroundColor: _getStatusColor(os.statusProducao).withValues(alpha: 0.1),
                      side: BorderSide.none,
                      padding: EdgeInsets.zero,
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumoFinanceiroCard(BuildContext context) {
    final financeiro = Provider.of<FinanceiroProvider>(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.monetization_on_outlined, color: AppColors.secondary),
                SizedBox(width: 8),
                Text(
                  'Fluxo de Caixa Rápido',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            _buildFinanceiroRow('A Receber:', Formatters.formatCurrency(financeiro.totalAReceberPendente), AppColors.success),
            const SizedBox(height: 10),
            _buildFinanceiroRow('A Pagar:', Formatters.formatCurrency(financeiro.totalAPagarPendente), AppColors.danger),
            const Divider(height: 24),
            _buildFinanceiroRow(
              'Saldo Projetado:',
              Formatters.formatCurrency(financeiro.saldoProjetado),
              financeiro.saldoProjetado >= 0 ? AppColors.success : AppColors.danger,
              isBold: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinanceiroRow(String label, String value, Color color, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 14 : 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
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
        return AppColors.textSecondary;
    }
  }
}
