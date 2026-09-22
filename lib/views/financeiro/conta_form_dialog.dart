import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/conta_model.dart';

class ContaFormDialog extends StatefulWidget {
  final Conta? contaInicial;
  final Function(Conta) onSalvar;

  const ContaFormDialog({super.key, this.contaInicial, required this.onSalvar});

  @override
  State<ContaFormDialog> createState() => _ContaFormDialogState();
}

class _ContaFormDialogState extends State<ContaFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _descricaoController;
  late TextEditingController _valorController;
  String _tipo = 'pagar';
  String _status = 'Pendente';
  DateTime _vencimento = DateTime.now().add(const Duration(days: 7));

  @override
  void initState() {
    super.initState();
    final c = widget.contaInicial;
    _descricaoController = TextEditingController(text: c?.descricao ?? '');
    _valorController = TextEditingController(text: c != null ? Formatters.formatDecimal(c.valor) : '');
    _tipo = c?.tipo ?? 'pagar';
    _status = c?.statusPagamento ?? 'Pendente';

    if (c != null) {
      try {
        _vencimento = DateTime.parse(c.dataVencimento);
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    _valorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
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
                      widget.contaInicial != null ? 'Editar Lançamento' : 'Novo Lançamento Financeiro',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Center(child: Text('Receita (A Receber)')),
                        selected: _tipo == 'receber',
                        selectedColor: AppColors.success.withValues(alpha: 0.2),
                        onSelected: (_) => setState(() => _tipo = 'receber'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        label: const Center(child: Text('Despesa (A Pagar)')),
                        selected: _tipo == 'pagar',
                        selectedColor: AppColors.danger.withValues(alpha: 0.2),
                        onSelected: (_) => setState(() => _tipo = 'pagar'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _descricaoController,
                  decoration: const InputDecoration(
                    labelText: 'Descrição do Lançamento *',
                    hintText: 'Ex: Compra de Discos de Corte, Entrada Pedido #12',
                    prefixIcon: Icon(Icons.description_outlined),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Informe a descrição' : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _valorController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: r'Valor (R$) *',
                          prefixIcon: Icon(Icons.attach_money),
                        ),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Informe o valor' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _vencimento,
                            firstDate: DateTime.now().subtract(const Duration(days: 365)),
                            lastDate: DateTime.now().add(const Duration(days: 730)),
                          );
                          if (picked != null) setState(() => _vencimento = picked);
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Data de Vencimento',
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                          child: Text(Formatters.formatDate(_vencimento)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _status,
                  decoration: const InputDecoration(labelText: 'Status do Pagamento'),
                  items: const [
                    DropdownMenuItem(value: 'Pendente', child: Text('Pendente')),
                    DropdownMenuItem(value: 'Pago', child: Text('Pago / Recebido')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _status = val);
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.secondary
                            : AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final conta = Conta(
                            id: widget.contaInicial?.id,
                            orcamentoId: widget.contaInicial?.orcamentoId,
                            tipo: _tipo,
                            descricao: _descricaoController.text.trim(),
                            valor: Formatters.parseDouble(_valorController.text),
                            dataVencimento: Formatters.toIsoDate(_vencimento),
                            statusPagamento: _status,
                          );
                          widget.onSalvar(conta);
                          Navigator.of(context).pop();
                        }
                      },
                      icon: const Icon(Icons.save, size: 18),
                      label: const Text('Salvar Lançamento'),
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
