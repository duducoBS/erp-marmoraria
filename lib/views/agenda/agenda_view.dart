import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/ordem_servico_model.dart';
import '../../services/database_service.dart';
import '../../services/whatsapp_service.dart';
import '../producao/widgets/os_dialog.dart';

class AgendaView extends StatefulWidget {
  const AgendaView({super.key});

  @override
  State<AgendaView> createState() => _AgendaViewState();
}

class _AgendaViewState extends State<AgendaView> {
  final DatabaseService _dbService = DatabaseService();
  List<OrdemServico> _ordens = [];
  bool _isLoading = true;
  String _filtro = 'todos'; // todos, medicao, entrega

  @override
  void initState() {
    super.initState();
    _carregarAgenda();
  }

  Future<void> _carregarAgenda() async {
    setState(() => _isLoading = true);
    try {
      final ordens = await _dbService.getOrdensServico();
      if (mounted) {
        setState(() {
          _ordens = ordens.where((os) => os.statusProducao != 'Concluido').toList();
          _ordens.sort((a, b) {
            final dataA = a.dataEntregaPrevista ?? '9999';
            final dataB = b.dataEntregaPrevista ?? '9999';
            return dataA.compareTo(dataB);
          });
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<OrdemServico> get _ordensFiltradas {
    if (_filtro == 'medicao') {
      return _ordens.where((os) => os.statusProducao == 'Medicao').toList();
    }
    if (_filtro == 'entrega') {
      return _ordens.where((os) => os.statusProducao == 'Montagem').toList();
    }
    return _ordens;
  }

  @override
  Widget build(BuildContext context) {
    final hojeStr = DateTime.now().toIso8601String().substring(0, 10);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Agenda de Medições & Entregas na Obra',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Compromissos de visita técnica para medição e instalação de bancadas',
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
                    showDialog(
                      context: context,
                      builder: (ctx) => OsDialog(
                        onSalvar: (os) async {
                          await _dbService.insertOrdemServico(os);
                          _carregarAgenda();
                        },
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_alarm, size: 20),
                  label: const Text('Novo Agendamento'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Filtros de Agenda
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Text('Filtrar por tipo:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(width: 12),
                    ChoiceChip(
                      label: const Text('Todos'),
                      selected: _filtro == 'todos',
                      onSelected: (_) => setState(() => _filtro = 'todos'),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Medições Técnicas'),
                      selected: _filtro == 'medicao',
                      onSelected: (_) => setState(() => _filtro = 'medicao'),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Entregas / Instalações'),
                      selected: _filtro == 'entrega',
                      onSelected: (_) => setState(() => _filtro = 'entrega'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Lista da Agenda
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _ordensFiltradas.isEmpty
                      ? const Center(child: Text('Nenhum compromisso agendado para o filtro selecionado.'))
                      : ListView.separated(
                          itemCount: _ordensFiltradas.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final os = _ordensFiltradas[index];
                            final isHoje = os.dataEntregaPrevista == hojeStr;
                            final isAtrasado = os.dataEntregaPrevista != null && os.dataEntregaPrevista!.compareTo(hojeStr) < 0;

                            return Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    // Ícone de tipo de compromisso
                                    Container(
                                      width: 52,
                                      height: 52,
                                      decoration: BoxDecoration(
                                        color: os.statusProducao == 'Medicao'
                                            ? AppColors.kanbanMedicao.withValues(alpha: 0.12)
                                            : AppColors.kanbanMontagem.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        os.statusProducao == 'Medicao' ? Icons.straighten : Icons.home_repair_service,
                                        color: os.statusProducao == 'Medicao' ? AppColors.kanbanMedicao : AppColors.kanbanMontagem,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                os.titulo,
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                              ),
                                              const SizedBox(width: 8),
                                              if (isHoje)
                                                const Chip(
                                                  label: Text('HOJE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                                                  backgroundColor: AppColors.danger,
                                                  side: BorderSide.none,
                                                  padding: EdgeInsets.zero,
                                                )
                                              else if (isAtrasado)
                                                const Chip(
                                                  label: Text('ATRASADO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                                                  backgroundColor: AppColors.warning,
                                                  side: BorderSide.none,
                                                  padding: EdgeInsets.zero,
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Cliente: ${os.clienteNome ?? "N/A"} • Endereço: ${os.clienteEndereco ?? "Não informado"}',
                                            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                                          ),
                                          if (os.observacoesTecnicas != null && os.observacoesTecnicas!.isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(top: 4),
                                              child: Text(
                                                'Obs: ${os.observacoesTecnicas!}',
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
                                          const Text('Data Prevista:', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                          Text(
                                            Formatters.formatDate(os.dataEntregaPrevista),
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                          ),
                                          Text(
                                            OrdemServico.getEtapaLabel(os.statusProducao),
                                            style: const TextStyle(fontSize: 11, color: AppColors.secondary, fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (os.clienteTelefone != null && os.clienteTelefone!.isNotEmpty)
                                      IconButton(
                                        icon: const Icon(Icons.send_to_mobile, color: Color(0xFF25D366)),
                                        tooltip: 'Avisar Cliente no WhatsApp',
                                        onPressed: () {
                                          WhatsAppService.enviarWhatsApp(
                                            telefone: os.clienteTelefone!,
                                            mensagem: 'Olá! Entramos em contato da Marmoraria para confirmar o agendamento da sua obra no dia ${Formatters.formatDate(os.dataEntregaPrevista)}.',
                                          );
                                        },
                                      ),
                                  ],
                                ),
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
}
