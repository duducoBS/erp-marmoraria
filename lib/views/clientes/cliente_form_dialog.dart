import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/cliente_model.dart';
import '../../services/database_service.dart';

class ClienteFormDialog extends StatefulWidget {
  final Cliente? clienteInicial;
  final Function(Cliente)? onSalvar;

  const ClienteFormDialog({super.key, this.clienteInicial, this.onSalvar});

  @override
  State<ClienteFormDialog> createState() => _ClienteFormDialogState();
}

class _ClienteFormDialogState extends State<ClienteFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseService _dbService = DatabaseService();

  late TextEditingController _nomeController;
  late TextEditingController _documentoController;
  late TextEditingController _telefoneController;
  late TextEditingController _emailController;
  late TextEditingController _enderecoController;
  late TextEditingController _cidadeController;
  String _tipo = 'PF';

  @override
  void initState() {
    super.initState();
    final c = widget.clienteInicial;
    _nomeController = TextEditingController(text: c?.nome ?? '');
    _tipo = c?.tipo ?? 'PF';
    _documentoController = TextEditingController(text: c?.documento ?? '');
    _telefoneController = TextEditingController(text: c?.telefone ?? '');
    _emailController = TextEditingController(text: c?.email ?? '');
    _enderecoController = TextEditingController(text: c?.endereco ?? '');
    _cidadeController = TextEditingController(text: c?.cidade ?? 'São Paulo');
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _documentoController.dispose();
    _telefoneController.dispose();
    _emailController.dispose();
    _enderecoController.dispose();
    _cidadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.clienteInicial != null;

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
                      isEdit ? 'Editar Cliente' : 'Cadastrar Novo Cliente / Obra',
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
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: _nomeController,
                        decoration: const InputDecoration(
                          labelText: 'Nome Completo / Razão Social *',
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Informe o nome' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: DropdownButtonFormField<String>(
                        initialValue: _tipo,
                        decoration: const InputDecoration(labelText: 'Tipo'),
                        items: const [
                          DropdownMenuItem(value: 'PF', child: Text('PF')),
                          DropdownMenuItem(value: 'PJ', child: Text('PJ')),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _tipo = val);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _documentoController,
                        decoration: InputDecoration(
                          labelText: _tipo == 'PF' ? 'CPF' : 'CNPJ',
                          prefixIcon: const Icon(Icons.badge_outlined),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _telefoneController,
                        decoration: const InputDecoration(
                          labelText: 'Telefone / WhatsApp *',
                          prefixIcon: Icon(Icons.phone),
                        ),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Informe o telefone' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'E-mail',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _enderecoController,
                        decoration: const InputDecoration(
                          labelText: 'Endereço da Obra / Entrega',
                          prefixIcon: Icon(Icons.location_on_outlined),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        controller: _cidadeController,
                        decoration: const InputDecoration(
                          labelText: 'Cidade',
                        ),
                      ),
                    ),
                  ],
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
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                      onPressed: _salvar,
                      icon: const Icon(Icons.save, size: 18),
                      label: const Text('Salvar Cliente'),
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
      final cliente = Cliente(
        id: widget.clienteInicial?.id,
        nome: _nomeController.text.trim(),
        tipo: _tipo,
        documento: _documentoController.text.trim(),
        telefone: _telefoneController.text.trim(),
        email: _emailController.text.trim(),
        endereco: _enderecoController.text.trim(),
        cidade: _cidadeController.text.trim(),
      );

      int id;
      if (cliente.id != null) {
        await _dbService.updateCliente(cliente);
        id = cliente.id!;
      } else {
        id = await _dbService.insertCliente(cliente);
      }

      final clienteSalvo = cliente.copyWith(id: id);
      if (widget.onSalvar != null) {
        widget.onSalvar!(clienteSalvo);
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }
}
