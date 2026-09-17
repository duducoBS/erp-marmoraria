import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/cliente_model.dart';
import '../../services/database_service.dart';
import '../../services/whatsapp_service.dart';
import 'cliente_form_dialog.dart';

class ClientesView extends StatefulWidget {
  const ClientesView({super.key});

  @override
  State<ClientesView> createState() => _ClientesViewState();
}

class _ClientesViewState extends State<ClientesView> {
  final DatabaseService _dbService = DatabaseService();
  final TextEditingController _searchController = TextEditingController();

  List<Cliente> _clientes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarClientes();
  }

  Future<void> _carregarClientes() async {
    setState(() => _isLoading = true);
    try {
      final list = await _dbService.getClientes(search: _searchController.text);
      if (mounted) {
        setState(() {
          _clientes = list;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                      'Cadastro de Clientes & Obras',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Base de contatos de construtoras, arquitetos e clientes finais',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  ),
                  onPressed: () => _abrirDialogCliente(),
                  icon: const Icon(Icons.person_add, size: 20),
                  label: const Text('Novo Cliente'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Search Bar
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar por nome, telefone, CPF/CNPJ ou cidade...',
                    prefixIcon: const Icon(Icons.search),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _carregarClientes();
                            },
                          )
                        : null,
                  ),
                  onChanged: (_) => _carregarClientes(),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Clientes Grid / List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _clientes.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.person_off_outlined, size: 64, color: AppColors.textMuted),
                              const SizedBox(height: 12),
                              const Text('Nenhum cliente cadastrado.', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () => _abrirDialogCliente(),
                                icon: const Icon(Icons.person_add),
                                label: const Text('Cadastrar Primeiro Cliente'),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          itemCount: _clientes.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final c = _clientes[index];
                            return _buildClienteCard(c);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClienteCard(Cliente c) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: Text(
                c.nome.isNotEmpty ? c.nome[0].toUpperCase() : 'C',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary),
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
                        c.nome,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(width: 8),
                      Chip(
                        label: Text(c.tipo, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                        backgroundColor: AppColors.surfaceVariant,
                        side: BorderSide.none,
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.phone, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(c.telefone.isNotEmpty ? c.telefone : 'Sem telefone', style: const TextStyle(fontSize: 13)),
                      if (c.email.isNotEmpty) ...[
                        const SizedBox(width: 16),
                        const Icon(Icons.email_outlined, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(c.email, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                      ],
                    ],
                  ),
                  if (c.endereco.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text('${c.endereco} - ${c.cidade}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (c.telefone.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.send_to_mobile, color: Color(0xFF25D366)),
                    tooltip: 'Conversar no WhatsApp',
                    onPressed: () {
                      WhatsAppService.enviarWhatsApp(
                        telefone: c.telefone,
                        mensagem: 'Olá, ${c.nome}! Entramos em contato da Marmoraria para falar sobre o seu projeto.',
                      );
                    },
                  ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                  tooltip: 'Editar Cliente',
                  onPressed: () => _abrirDialogCliente(cliente: c),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.danger),
                  tooltip: 'Excluir Cliente',
                  onPressed: () => _confirmarExclusao(c),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _abrirDialogCliente({Cliente? cliente}) {
    showDialog(
      context: context,
      builder: (ctx) => ClienteFormDialog(
        clienteInicial: cliente,
        onSalvar: (_) => _carregarClientes(),
      ),
    );
  }

  void _confirmarExclusao(Cliente c) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir Cliente?'),
        content: Text('Deseja realmente remover o cliente "${c.nome}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () async {
              Navigator.of(ctx).pop();
              if (c.id != null) {
                await _dbService.deleteCliente(c.id!);
                _carregarClientes();
              }
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}
