import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/material_model.dart';
import '../../../models/acabamento_model.dart';
import '../../../models/orcamento_item_model.dart';

class OrcamentoItemDialog extends StatefulWidget {
  final List<MaterialItem> materiais;
  final List<AcabamentoServico> acabamentos;
  final OrcamentoItem? itemInicial;
  final Function(OrcamentoItem) onSalvar;

  const OrcamentoItemDialog({
    super.key,
    required this.materiais,
    required this.acabamentos,
    this.itemInicial,
    required this.onSalvar,
  });

  @override
  State<OrcamentoItemDialog> createState() => _OrcamentoItemDialogState();
}

class _OrcamentoItemDialogState extends State<OrcamentoItemDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _ambienteController;
  late TextEditingController _larguraController;
  late TextEditingController _comprimentoController;
  late TextEditingController _quantidadeController;
  late TextEditingController _perdaController;
  late TextEditingController _acabamentoQtdController;

  MaterialItem? _materialSelecionado;
  AcabamentoServico? _acabamentoSelecionado;

  double _m2Total = 0.0;
  double _valorParcial = 0.0;

  final List<String> _ambientesSugeridos = [
    'Cozinha Principal',
    'Ilha / Bancada Seca',
    'Lavabo Social',
    'Banho Master',
    'Área Gourmet / Churrasqueira',
    'Lavanderia',
    'Soleiras & Peitoris',
    'Nicho de Banheiro',
  ];

  @override
  void initState() {
    super.initState();
    final item = widget.itemInicial;

    _ambienteController = TextEditingController(text: item?.ambiente ?? 'Cozinha');
    _larguraController = TextEditingController(text: item != null ? Formatters.formatDecimal(item.largura) : '0,60');
    _comprimentoController = TextEditingController(text: item != null ? Formatters.formatDecimal(item.comprimento) : '2,00');
    _quantidadeController = TextEditingController(text: item != null ? item.quantidade.toString() : '1');
    _perdaController = TextEditingController(text: item != null ? item.perdaPercentual.toStringAsFixed(0) : '10');
    _acabamentoQtdController = TextEditingController(text: item != null ? Formatters.formatDecimal(item.acabamentoQuantidade) : '2,00');

    if (item != null) {
      _materialSelecionado = widget.materiais.firstWhere(
        (m) => m.id == item.materialId,
        orElse: () => widget.materiais.first,
      );
      if (item.acabamentoId != null) {
        _acabamentoSelecionado = widget.acabamentos.firstWhere(
          (a) => a.id == item.acabamentoId,
          orElse: () => widget.acabamentos.first,
        );
      }
    } else {
      if (widget.materiais.isNotEmpty) _materialSelecionado = widget.materiais.first;
      if (widget.acabamentos.isNotEmpty) _acabamentoSelecionado = widget.acabamentos.first;
    }

    _calcularValores();
  }

  void _calcularValores() {
    final largura = Formatters.parseDouble(_larguraController.text);
    final comprimento = Formatters.parseDouble(_comprimentoController.text);
    final quantidade = int.tryParse(_quantidadeController.text) ?? 1;
    final perda = Formatters.parseDouble(_perdaController.text);

    _m2Total = OrcamentoItem.calcularM2Total(
      largura: largura,
      comprimento: comprimento,
      quantidade: quantidade,
      perdaPercentual: perda,
    );

    final precoM2 = _materialSelecionado?.precoM2Venda ?? 0.0;
    final valorAcabamentoUnit = _acabamentoSelecionado?.valor ?? 0.0;
    final qtdAcabamento = Formatters.parseDouble(_acabamentoQtdController.text);

    _valorParcial = OrcamentoItem.calcularValorParcial(
      m2Total: _m2Total,
      precoM2Venda: precoM2,
      acabamentoValorUnitario: valorAcabamentoUnit,
      acabamentoQuantidade: qtdAcabamento,
    );

    setState(() {});
  }

  @override
  void dispose() {
    _ambienteController.dispose();
    _larguraController.dispose();
    _comprimentoController.dispose();
    _quantidadeController.dispose();
    _perdaController.dispose();
    _acabamentoQtdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 720),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calculate_outlined, color: AppColors.secondary, size: 28),
                        const SizedBox(width: 8),
                        Text(
                          widget.itemInicial != null ? 'Editar Peça / Item' : 'Adicionar Nova Peça / Item',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Ambiente
                        const Text('Ambiente ou Local da Peça:', style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Autocomplete<String>(
                          initialValue: TextEditingValue(text: _ambienteController.text),
                          optionsBuilder: (textEditingValue) {
                            if (textEditingValue.text.isEmpty) return _ambientesSugeridos;
                            return _ambientesSugeridos.where((amb) => amb.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                          },
                          onSelected: (val) {
                            _ambienteController.text = val;
                          },
                          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                            controller.text = _ambienteController.text;
                            return TextFormField(
                              controller: controller,
                              focusNode: focusNode,
                              decoration: const InputDecoration(
                                hintText: 'Ex: Cozinha Principal, Ilha, Lavabo',
                                prefixIcon: Icon(Icons.room_preferences_outlined),
                              ),
                              onChanged: (val) => _ambienteController.text = val,
                              validator: (val) => val == null || val.trim().isEmpty ? 'Informe o ambiente' : null,
                            );
                          },
                        ),
                        const SizedBox(height: 16),

                        // Seleção de Material
                        const Text('Material / Rocha Ornamental:', style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<MaterialItem>(
                          isExpanded: true,
                          initialValue: _materialSelecionado,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.layers_outlined),
                          ),
                          items: widget.materiais.map((mat) {
                            return DropdownMenuItem<MaterialItem>(
                              value: mat,
                              child: Text(
                                '${mat.nome} (${Formatters.formatCurrency(mat.precoM2Venda)}/m²)',
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            _materialSelecionado = val;
                            _calcularValores();
                          },
                        ),
                        const SizedBox(height: 16),

                        // Dimensões (Largura, Comprimento, Quantidade, Perda %)
                        // Dimensões (Largura, Comprimento, Quantidade, Perda %)
                        const Text('Dimensões e Fator de Perda:', style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isCompact = constraints.maxWidth < 450;
                            final fieldLargura = TextFormField(
                              controller: _larguraController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(labelText: 'Largura (m)', hintText: '0,60'),
                              onChanged: (_) => _calcularValores(),
                            );
                            final fieldComprimento = TextFormField(
                              controller: _comprimentoController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(labelText: 'Comprimento (m)', hintText: '2,00'),
                              onChanged: (_) => _calcularValores(),
                            );
                            final fieldQuantidade = TextFormField(
                              controller: _quantidadeController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Qtd (un)', hintText: '1'),
                              onChanged: (_) => _calcularValores(),
                            );
                            final fieldPerda = TextFormField(
                              controller: _perdaController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(labelText: 'Perda (%)', hintText: '10'),
                              onChanged: (_) => _calcularValores(),
                            );

                            if (isCompact) {
                              return Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(child: fieldLargura),
                                      const SizedBox(width: 8),
                                      Expanded(child: fieldComprimento),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Expanded(child: fieldQuantidade),
                                      const SizedBox(width: 8),
                                      Expanded(child: fieldPerda),
                                    ],
                                  ),
                                ],
                              );
                            } else {
                              return Row(
                                children: [
                                  Expanded(child: fieldLargura),
                                  const SizedBox(width: 8),
                                  Expanded(child: fieldComprimento),
                                  const SizedBox(width: 8),
                                  Expanded(child: fieldQuantidade),
                                  const SizedBox(width: 8),
                                  Expanded(child: fieldPerda),
                                ],
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 16),

                        // Acabamentos e Serviços Especiais
                        const Text('Acabamento de Borda / Serviço Especial:', style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isCompact = constraints.maxWidth < 450;
                            final acabamentoDropdown = DropdownButtonFormField<AcabamentoServico?>(
                              isExpanded: true,
                              initialValue: _acabamentoSelecionado,
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.handyman_outlined),
                              ),
                              items: [
                                const DropdownMenuItem<AcabamentoServico?>(
                                  value: null,
                                  child: Text('Nenhum acabamento extra'),
                                ),
                                ...widget.acabamentos.map((acab) {
                                  return DropdownMenuItem<AcabamentoServico?>(
                                    value: acab,
                                    child: Text(
                                      '${acab.nome} (${Formatters.formatCurrency(acab.valor)} / ${acab.tipoCobrancaLabel})',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }),
                              ],
                              onChanged: (val) {
                                _acabamentoSelecionado = val;
                                _calcularValores();
                              },
                            );

                            final acabamentoQtdField = TextFormField(
                              controller: _acabamentoQtdController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: InputDecoration(
                                labelText: _acabamentoSelecionado?.tipoCobranca == 'unidade' ? 'Qtd (un)' : 'Metros Lineares (m)',
                                hintText: '2,00',
                              ),
                              onChanged: (_) => _calcularValores(),
                            );

                            if (isCompact) {
                              return Column(
                                children: [
                                  acabamentoDropdown,
                                  const SizedBox(height: 10),
                                  acabamentoQtdField,
                                ],
                              );
                            } else {
                              return Row(
                                children: [
                                  Expanded(flex: 3, child: acabamentoDropdown),
                                  const SizedBox(width: 8),
                                  Expanded(flex: 2, child: acabamentoQtdField),
                                ],
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 20),

                        // Banner de Cálculo em Tempo Real
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Área com Fator de Perda:', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                                  Text(Formatters.formatM2(_m2Total), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Fórmula Aplicada:', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                                  Text(
                                    'L × C × Qtd × (1 + ${_perdaController.text}%)',
                                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontFamily: 'monospace'),
                                  ),
                                ],
                              ),
                              const Divider(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('VALOR PARCIAL DO ITEM:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  Text(
                                    Formatters.formatCurrency(_valorParcial),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
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
                          if (_materialSelecionado == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Selecione um material')),
                            );
                            return;
                          }

                          final item = OrcamentoItem(
                            id: widget.itemInicial?.id,
                            orcamentoId: widget.itemInicial?.orcamentoId,
                            ambiente: _ambienteController.text.trim(),
                            materialId: _materialSelecionado!.id!,
                            materialNome: _materialSelecionado!.nome,
                            largura: Formatters.parseDouble(_larguraController.text),
                            comprimento: Formatters.parseDouble(_comprimentoController.text),
                            quantidade: int.tryParse(_quantidadeController.text) ?? 1,
                            m2Total: _m2Total,
                            perdaPercentual: Formatters.parseDouble(_perdaController.text),
                            acabamentoId: _acabamentoSelecionado?.id,
                            acabamentoNome: _acabamentoSelecionado?.nome,
                            acabamentoQuantidade: Formatters.parseDouble(_acabamentoQtdController.text),
                            valorParcial: _valorParcial,
                          );

                          widget.onSalvar(item);
                          Navigator.of(context).pop();
                        }
                      },
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Confirmar Item'),
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
