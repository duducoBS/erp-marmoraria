import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/material_model.dart';
import '../../services/database_service.dart';

class MaterialFormDialog extends StatefulWidget {
  final MaterialItem? materialInicial;
  final VoidCallback onSalvar;

  const MaterialFormDialog({super.key, this.materialInicial, required this.onSalvar});

  @override
  State<MaterialFormDialog> createState() => _MaterialFormDialogState();
}

class _MaterialFormDialogState extends State<MaterialFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseService _dbService = DatabaseService();

  late TextEditingController _nomeController;
  late TextEditingController _custoController;
  late TextEditingController _vendaController;
  late TextEditingController _espessuraController;
  String _tipo = 'Granito';

  final List<String> _tiposPedra = [
    'Granito',
    'Mármore',
    'Quartzo',
    'Super Nano',
    'Dekton / Ultracompacto',
    'Lâmina Sinterizada',
    'Ardósia',
    'Outro',
  ];

  @override
  void initState() {
    super.initState();
    final m = widget.materialInicial;
    _nomeController = TextEditingController(text: m?.nome ?? '');
    _tipo = m?.tipo ?? 'Granito';
    _custoController = TextEditingController(text: m != null ? Formatters.formatDecimal(m.precoM2Custo) : '');
    _vendaController = TextEditingController(text: m != null ? Formatters.formatDecimal(m.precoM2Venda) : '');
    _espessuraController = TextEditingController(text: m?.espessura ?? '2cm');
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _custoController.dispose();
    _vendaController.dispose();
    _espessuraController.dispose();
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
                      widget.materialInicial != null ? 'Editar Material' : 'Cadastrar Material / Pedra',
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
                    labelText: 'Nome da Rocha / Chapa *',
                    hintText: 'Ex: Granito Preto São Gabriel',
                    prefixIcon: Icon(Icons.layers_outlined),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Informe o nome' : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        initialValue: _tiposPedra.contains(_tipo) ? _tipo : _tiposPedra.first,
                        decoration: const InputDecoration(labelText: 'Tipo de Rocha'),
                        items: _tiposPedra.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _tipo = val);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        controller: _espessuraController,
                        decoration: const InputDecoration(labelText: 'Espessura', hintText: '2cm'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _custoController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: r'Preço Custo / m² (R$)',
                          prefixIcon: Icon(Icons.money_off),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _vendaController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: r'Preço Venda / m² (R$) *',
                          prefixIcon: Icon(Icons.attach_money),
                        ),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Informe o valor de venda' : null,
                      ),
                    ),
                  ],
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
                      onPressed: _salvar,
                      icon: const Icon(Icons.save, size: 18),
                      label: const Text('Salvar Material'),
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
      final material = MaterialItem(
        id: widget.materialInicial?.id,
        nome: _nomeController.text.trim(),
        tipo: _tipo,
        precoM2Custo: Formatters.parseDouble(_custoController.text),
        precoM2Venda: Formatters.parseDouble(_vendaController.text),
        espessura: _espessuraController.text.trim(),
      );

      if (material.id != null) {
        await _dbService.updateMaterial(material);
      } else {
        await _dbService.insertMaterial(material);
      }

      widget.onSalvar();
      if (mounted) Navigator.of(context).pop();
    }
  }
}
