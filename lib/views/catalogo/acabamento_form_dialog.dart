import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/acabamento_model.dart';
import '../../services/database_service.dart';

class AcabamentoFormDialog extends StatefulWidget {
  final AcabamentoServico? acabamentoInicial;
  final VoidCallback onSalvar;

  const AcabamentoFormDialog({super.key, this.acabamentoInicial, required this.onSalvar});

  @override
  State<AcabamentoFormDialog> createState() => _AcabamentoFormDialogState();
}

class _AcabamentoFormDialogState extends State<AcabamentoFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseService _dbService = DatabaseService();

  late TextEditingController _nomeController;
  late TextEditingController _valorController;
  String _tipoCobranca = 'metro_linear';

  @override
  void initState() {
    super.initState();
    final a = widget.acabamentoInicial;
    _nomeController = TextEditingController(text: a?.nome ?? '');
    _tipoCobranca = a?.tipoCobranca ?? 'metro_linear';
    _valorController = TextEditingController(text: a != null ? Formatters.formatDecimal(a.valor) : '');
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _valorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
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
                      widget.acabamentoInicial != null ? 'Editar Acabamento' : 'Novo Acabamento / Serviço',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nomeController,
                  decoration: const InputDecoration(
                    labelText: 'Nome do Acabamento ou Serviço *',
                    hintText: 'Ex: 45 graus (Meia Esquadria), Bisotê, Furo Cuba',
                    prefixIcon: Icon(Icons.handyman_outlined),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Informe o nome' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _tipoCobranca,
                  decoration: const InputDecoration(
                    labelText: 'Métrica de Cobrança',
                    prefixIcon: Icon(Icons.tune),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'metro_linear', child: Text('Metro Linear (m)')),
                    DropdownMenuItem(value: 'unidade', child: Text('Por Unidade / Peça (un)')),
                    DropdownMenuItem(value: 'fixo', child: Text('Valor Fixo')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _tipoCobranca = val);
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _valorController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: r'Valor Cobrado (R$) *',
                    hintText: 'Ex: 65.00',
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Informe o valor' : null,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
                      onPressed: _salvar,
                      icon: const Icon(Icons.save, size: 18),
                      label: const Text('Salvar Acabamento'),
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

  Future<void> _salvar() async {
    if (_formKey.currentState!.validate()) {
      final acabamento = AcabamentoServico(
        id: widget.acabamentoInicial?.id,
        nome: _nomeController.text.trim(),
        tipoCobranca: _tipoCobranca,
        valor: Formatters.parseDouble(_valorController.text),
      );

      if (acabamento.id != null) {
        await _dbService.updateAcabamento(acabamento);
      } else {
        await _dbService.insertAcabamento(acabamento);
      }

      widget.onSalvar();
      if (mounted) Navigator.of(context).pop();
    }
  }
}
