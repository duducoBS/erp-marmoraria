import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/empresa_config_model.dart';

class EmpresaConfigDialog extends StatefulWidget {
  final EmpresaConfig configAtual;
  final Function(EmpresaConfig) onSalvar;

  const EmpresaConfigDialog({
    super.key,
    required this.configAtual,
    required this.onSalvar,
  });

  @override
  State<EmpresaConfigDialog> createState() => _EmpresaConfigDialogState();
}

class _EmpresaConfigDialogState extends State<EmpresaConfigDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nomeController;
  late TextEditingController _cnpjController;
  late TextEditingController _enderecoController;
  late TextEditingController _especialidadesController;
  late TextEditingController _fone1Controller;
  late TextEditingController _resp1Controller;
  late TextEditingController _cidadePadraoController;
  late TextEditingController _dadosBancariosController;
  late TextEditingController _observacoesPadraoController;

  @override
  void initState() {
    super.initState();
    final c = widget.configAtual;
    _nomeController = TextEditingController(text: c.nome);
    _cnpjController = TextEditingController(text: c.cnpj);
    _enderecoController = TextEditingController(text: c.endereco);
    _especialidadesController = TextEditingController(text: c.especialidades);
    _fone1Controller = TextEditingController(text: c.fone1);
    _resp1Controller = TextEditingController(text: c.resp1);
    _cidadePadraoController = TextEditingController(text: c.cidadePadrao);
    _dadosBancariosController = TextEditingController(text: c.dadosBancarios);
    _observacoesPadraoController = TextEditingController(text: c.observacoesPadrao);
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cnpjController.dispose();
    _enderecoController.dispose();
    _especialidadesController.dispose();
    _fone1Controller.dispose();
    _resp1Controller.dispose();
    _cidadePadraoController.dispose();
    _dadosBancariosController.dispose();
    _observacoesPadraoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620, maxHeight: 720),
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
                    const Row(
                      children: [
                        Icon(Icons.business_outlined, color: AppColors.secondary, size: 28),
                        SizedBox(width: 10),
                        Text(
                          'Dados da Empresa / Marmoraria',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Text(
                  'Essas informações aparecem no cabeçalho e rodapé dos orçamentos e propostas comerciais.',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const Divider(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _nomeController,
                          decoration: const InputDecoration(
                            labelText: 'Nome Comercial da Marmoraria *',
                            prefixIcon: Icon(Icons.store_outlined),
                          ),
                          validator: (val) => val == null || val.trim().isEmpty ? 'Informe o nome' : null,
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              flex: 5,
                              child: TextFormField(
                                controller: _cnpjController,
                                decoration: const InputDecoration(
                                  labelText: 'CNPJ',
                                  hintText: '00.000.000/0001-00',
                                  prefixIcon: Icon(Icons.badge_outlined),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 5,
                              child: TextFormField(
                                controller: _cidadePadraoController,
                                decoration: const InputDecoration(
                                  labelText: 'Cidade Padrão',
                                  hintText: 'São Paulo',
                                  prefixIcon: Icon(Icons.location_city_outlined),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _enderecoController,
                          decoration: const InputDecoration(
                            labelText: 'Endereço Completo',
                            hintText: 'Av. Exemplo, 1234 - Bairro - Cidade - UF',
                            prefixIcon: Icon(Icons.location_on_outlined),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              flex: 6,
                              child: TextFormField(
                                controller: _fone1Controller,
                                decoration: const InputDecoration(
                                  labelText: 'Telefone / WhatsApp',
                                  hintText: '(11) 94031-1110',
                                  prefixIcon: Icon(Icons.phone_outlined),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 4,
                              child: TextFormField(
                                controller: _resp1Controller,
                                decoration: const InputDecoration(
                                  labelText: 'Responsável / Contato',
                                  hintText: 'Edu',
                                  prefixIcon: Icon(Icons.person_outline),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _especialidadesController,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            labelText: 'Especialidades (Cabeçalho da Proposta)',
                            hintText: 'MÁRMORES • GRANITOS • PEDRAS DECORATIVAS\nPIAS • LAVATÓRIOS • PISOS • ESCADAS',
                            prefixIcon: Icon(Icons.stars_outlined),
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _dadosBancariosController,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            labelText: 'Dados Bancários & Chave PIX (Rodapé)',
                            hintText: 'Caixa Econômica Ag: 0242 Op: 013 CP: 7675-7 / PIX: 148.374.878-23',
                            prefixIcon: Icon(Icons.account_balance_outlined),
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _observacoesPadraoController,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            labelText: 'Observações Padrão das Propostas',
                            hintText: 'Material para instalação será por conta do cliente.',
                            prefixIcon: Icon(Icons.notes_outlined),
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
                          final config = widget.configAtual.copyWith(
                            nome: _nomeController.text.trim(),
                            cnpj: _cnpjController.text.trim(),
                            endereco: _enderecoController.text.trim(),
                            especialidades: _especialidadesController.text.trim(),
                            fone1: _fone1Controller.text.trim(),
                            resp1: _resp1Controller.text.trim(),
                            cidadePadrao: _cidadePadraoController.text.trim(),
                            dadosBancarios: _dadosBancariosController.text.trim(),
                            observacoesPadrao: _observacoesPadraoController.text.trim(),
                          );
                          widget.onSalvar(config);
                          Navigator.of(context).pop();
                        }
                      },
                      icon: const Icon(Icons.save_outlined, size: 18),
                      label: const Text('Salvar Configurações'),
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
