import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/cliente_model.dart';
import '../../../models/ordem_servico_model.dart';
import '../../../services/database_service.dart';

class OsDialog extends StatefulWidget {
  final OrdemServico? osInicial;
  final Function(OrdemServico) onSalvar;

  const OsDialog({super.key, this.osInicial, required this.onSalvar});

  @override
  State<OsDialog> createState() => _OsDialogState();
}

class _OsDialogState extends State<OsDialog> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseService _dbService = DatabaseService();

  late TextEditingController _tituloController;
  late TextEditingController _obsController;
  String _status = 'Medicao';
  DateTime _dataEntrega = DateTime.now().add(const Duration(days: 10));
  List<Cliente> _clientes = [];
  Cliente? _clienteSelecionado;

  @override
  void initState() {
    super.initState();
    final os = widget.osInicial;
    _tituloController = TextEditingController(text: os?.titulo ?? '');
    _obsController = TextEditingController(text: os?.observacoesTecnicas ?? '');
    _status = os?.statusProducao ?? 'Medicao';

    if (os?.dataEntregaPrevista != null) {
      try {
        _dataEntrega = DateTime.parse(os!.dataEntregaPrevista!);
      } catch (_) {}
    }

    _carregarClientes();
  }

  Future<void> _carregarClientes() async {
    final clientes = await _dbService.getClientes();
    setState(() {
      _clientes = clientes;
      if (widget.osInicial?.clienteId != null) {
        _clienteSelecionado = clientes.firstWhere(
          (c) => c.id == widget.osInicial!.clienteId,
          orElse: () => clientes.first,
        );
      } else if (clientes.isNotEmpty) {
        _clienteSelecionado = clientes.first;
      }
    });
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _obsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 550),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.osInicial != null ? 'Editar Ordem de Serviço' : 'Nova Ordem de Serviço / Medição',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _tituloController,
                  decoration: const InputDecoration(
                    labelText: 'Título da OS / Descrição do Serviço *',
                    hintText: 'Ex: Cozinha e Ilha - Bancada São Gabriel',
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Informe o título' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<Cliente>(
                  key: ValueKey(_clienteSelecionado?.id),
                  initialValue: _clienteSelecionado,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Cliente / Obra',
                    prefixIcon: Icon(Icons.business),
                  ),
                  items: _clientes.map((c) {
                    return DropdownMenuItem(value: c, child: Text(c.nome));
                  }).toList(),
                  onChanged: (val) => setState(() => _clienteSelecionado = val),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _status,
                        decoration: const InputDecoration(labelText: 'Fase Inicial'),
                        items: OrdemServico.etapas.map((et) {
                          return DropdownMenuItem(value: et, child: Text(OrdemServico.getEtapaLabel(et)));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _status = val);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _dataEntrega,
                            firstDate: DateTime.now().subtract(const Duration(days: 30)),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (picked != null) setState(() => _dataEntrega = picked);
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Previsão de Entrega',
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                          child: Text(Formatters.formatDate(_dataEntrega)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _obsController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Observações Técnicas / Detalhes de Instalação',
                    hintText: 'Ex: Furo da cuba e cooktop conferidos no local. Medição confirmada.',
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final os = OrdemServico(
                            id: widget.osInicial?.id,
                            orcamentoId: widget.osInicial?.orcamentoId,
                            clienteId: _clienteSelecionado?.id,
                            titulo: _tituloController.text.trim(),
                            statusProducao: _status,
                            dataEntregaPrevista: Formatters.toIsoDate(_dataEntrega),
                            observacoesTecnicas: _obsController.text.trim(),
                            clienteNome: _clienteSelecionado?.nome,
                          );
                          widget.onSalvar(os);
                          Navigator.of(context).pop();
                        }
                      },
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Salvar OS'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
