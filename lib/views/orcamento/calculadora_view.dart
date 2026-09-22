import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/responsive.dart';
import '../../models/cliente_model.dart';
import '../../models/orcamento_model.dart';
import '../../models/orcamento_item_model.dart';
import '../../providers/orcamento_provider.dart';
import '../../providers/producao_provider.dart';
import '../../providers/financeiro_provider.dart';
import '../../services/pdf_service.dart';
import '../../services/whatsapp_service.dart';
import '../clientes/cliente_form_dialog.dart';
import 'widgets/orcamento_item_dialog.dart';

class CalculadoraView extends StatefulWidget {
  final VoidCallback onVoltar;

  const CalculadoraView({super.key, required this.onVoltar});

  @override
  State<CalculadoraView> createState() => _CalculadoraViewState();
}

class _CalculadoraViewState extends State<CalculadoraView> {
  late TextEditingController _obsController;
  late TextEditingController _condicaoPagamentoController;
  late TextEditingController _dadosBancariosController;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<OrcamentoProvider>(context, listen: false);
    _obsController = TextEditingController(text: provider.observacoes);
    _condicaoPagamentoController = TextEditingController(text: provider.condicaoPagamento);
    _dadosBancariosController = TextEditingController(text: provider.dadosBancarios);
  }

  @override
  void dispose() {
    _obsController.dispose();
    _condicaoPagamentoController.dispose();
    _dadosBancariosController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OrcamentoProvider>(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onVoltar,
        ),
        title: Text(
          provider.editingId != null
              ? 'Editando Orçamento #${provider.editingId}'
              : 'Calculadora de Orçamento & Nova Proposta',
        ),
        actions: [
          IconButton(
            tooltip: 'Gerar Proposta em PDF',
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () => _exportarPdf(context, provider),
          ),
          IconButton(
            tooltip: 'Enviar via WhatsApp',
            icon: const Icon(Icons.send_to_mobile),
            onPressed: () => _enviarWhatsApp(context, provider),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            icon: const Icon(Icons.save, size: 18),
            label: const Text('Salvar no SQLite'),
            onPressed: () => _salvar(context, provider),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cabeçalho: Cliente, Validade e Status
                  _buildHeaderCard(context, provider),
                  const SizedBox(height: 20),

                  // Lista de Itens / Peças
                  _buildItensSection(context, provider),
                  const SizedBox(height: 20),

                  // Observações e Resumo de Totais
                  _buildFooterSection(context, provider),
                ],
              ),
            ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, OrcamentoProvider provider) {
    final isDesktop = Responsive.isDesktop(context);

    final clienteField = Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<Cliente>(
            isExpanded: true,
            initialValue: provider.selectedCliente,
            decoration: const InputDecoration(
              labelText: 'Cliente / Obra',
              prefixIcon: Icon(Icons.business),
            ),
            items: provider.clientes.map((c) {
              return DropdownMenuItem<Cliente>(
                value: c,
                child: Text(
                  '${c.nome} (${c.tipo}) - ${c.cidade}',
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: (cliente) => provider.setSelectedCliente(cliente),
          ),
        ),
        const SizedBox(width: 8),
        IconButton.filledTonal(
          tooltip: 'Cadastrar Novo Cliente',
          icon: const Icon(Icons.person_add),
          onPressed: () => _abrirModalNovoCliente(context, provider),
        ),
      ],
    );

    final validadeField = InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: provider.dataValidade,
          firstDate: DateTime.now().subtract(const Duration(days: 30)),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null) {
          provider.setDataValidade(picked);
        }
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Data de Validade',
          prefixIcon: Icon(Icons.calendar_today),
        ),
        child: Text(Formatters.formatDate(provider.dataValidade)),
      ),
    );

    final statusField = DropdownButtonFormField<String>(
      initialValue: provider.status,
      decoration: const InputDecoration(
        labelText: 'Status da Proposta',
        prefixIcon: Icon(Icons.flag_outlined),
      ),
      items: const [
        DropdownMenuItem(value: 'Rascunho', child: Text('Rascunho')),
        DropdownMenuItem(value: 'Enviado', child: Text('Enviado')),
        DropdownMenuItem(value: 'Aprovado', child: Text('Aprovado')),
        DropdownMenuItem(value: 'Recusado', child: Text('Recusado')),
      ],
      onChanged: (val) {
        if (val != null) provider.setStatus(val);
      },
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.person_outline, color: AppColors.primary),
                SizedBox(width: 8),
                Text(
                  'Dados do Cliente & Validade',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 10),
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: clienteField),
                  const SizedBox(width: 16),
                  Expanded(flex: 2, child: validadeField),
                  const SizedBox(width: 16),
                  Expanded(flex: 2, child: statusField),
                ],
              )
            else
              Column(
                children: [
                  clienteField,
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: validadeField),
                      const SizedBox(width: 12),
                      Expanded(child: statusField),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildItensSection(BuildContext context, OrcamentoProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 10,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.table_view_outlined, color: AppColors.secondary),
                    const SizedBox(width: 8),
                    const Text(
                      'Itens do Orçamento',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    Chip(
                      label: Text('${provider.itensRascunho.length} itens'),
                      backgroundColor: AppColors.surfaceVariant,
                      side: BorderSide.none,
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
                  onPressed: () => _abrirModalItem(context, provider),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Adicionar Peça / Item'),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 10),

            if (provider.itensRascunho.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 36),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(Icons.calculate_outlined, size: 48, color: AppColors.textMuted),
                      const SizedBox(height: 10),
                      const Text(
                        'Nenhuma peça adicionada ainda.',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () => _abrirModalItem(context, provider),
                        icon: const Icon(Icons.add),
                        label: const Text('Adicionar Primeira Peça'),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: provider.itensRascunho.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = provider.itensRascunho[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ),
                    title: Row(
                      children: [
                        Text(
                          item.ambiente,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        const SizedBox(width: 10),
                        Chip(
                          label: Text(
                            item.materialNome ?? 'Material #${item.materialId}',
                            style: const TextStyle(fontSize: 11),
                          ),
                          backgroundColor: AppColors.surfaceVariant,
                          side: BorderSide.none,
                          padding: EdgeInsets.zero,
                        ),
                        if (item.tipoCalculo == 'fixo') ...[
                          const SizedBox(width: 6),
                          Chip(
                            label: const Text(
                              'Preço Fixo',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.secondary),
                            ),
                            backgroundColor: AppColors.secondary.withValues(alpha: 0.15),
                            side: BorderSide.none,
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        if (item.tipoCalculo == 'fixo')
                          Text(
                            'Valor Fixo: ${Formatters.formatCurrency(item.valorFixo)}${item.largura > 0 && item.comprimento > 0 ? " • Medidas: ${Formatters.formatDecimal(item.largura)}m × ${Formatters.formatDecimal(item.comprimento)}m (Qtd: ${item.quantidade})" : ""}',
                            style: const TextStyle(fontSize: 13),
                          )
                        else
                          Text(
                            'Medidas: ${Formatters.formatDecimal(item.largura)}m × ${Formatters.formatDecimal(item.comprimento)}m (Qtd: ${item.quantidade}) • Área c/ perda: ${Formatters.formatM2(item.m2Total)} • ${Formatters.formatCurrency(item.precoMetro)}/m²',
                            style: const TextStyle(fontSize: 13),
                          ),
                        if (item.acabamentoNome != null)
                          Text(
                            'Acabamento: ${item.acabamentoNome} (${Formatters.formatDecimal(item.acabamentoQuantidade)})',
                            style: const TextStyle(fontSize: 12, color: AppColors.secondary, fontWeight: FontWeight.w500),
                          ),
                        if (item.descricao.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            item.descricao,
                            style: const TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          Formatters.formatCurrency(item.valorParcial),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 20),
                          tooltip: 'Editar Peça',
                          onPressed: () => _abrirModalItem(context, provider, item: item, index: index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.danger),
                          tooltip: 'Excluir Peça',
                          onPressed: () => provider.removeItemRascunho(index),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterSection(BuildContext context, OrcamentoProvider provider) {
    final isDesktop = Responsive.isDesktop(context);

    final condicoesPagamentoCard = Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.payment, color: AppColors.secondary, size: 20),
                    SizedBox(width: 8),
                    Text('Condições de Pagamento & Parcelas:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
                Wrap(
                  spacing: 6,
                  children: [
                    ActionChip(
                      label: const Text('1x À Vista', style: TextStyle(fontSize: 11)),
                      onPressed: () => provider.gerarParcelasAutomaticas(1),
                    ),
                    ActionChip(
                      label: const Text('2x', style: TextStyle(fontSize: 11)),
                      onPressed: () => provider.gerarParcelasAutomaticas(2),
                    ),
                    ActionChip(
                      label: const Text('3x', style: TextStyle(fontSize: 11)),
                      onPressed: () => provider.gerarParcelasAutomaticas(3),
                    ),
                    ActionChip(
                      label: const Text('4x', style: TextStyle(fontSize: 11)),
                      onPressed: () => provider.gerarParcelasAutomaticas(4),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _condicaoPagamentoController,
              decoration: const InputDecoration(
                labelText: 'Condição Comercial de Pagamento',
                hintText: 'Ex: 50% de entrada + 50% na colocação',
                prefixIcon: Icon(Icons.credit_card_outlined),
              ),
              onChanged: (val) => provider.setCondicaoPagamento(val),
            ),
            if (provider.parcelas.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Column(
                  children: provider.parcelas.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final p = entry.value;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${p.numero}ª Parcela',
                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            Formatters.formatCurrency(p.valor),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          const Spacer(),
                          const Icon(Icons.calendar_today, size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            'Venc: ${Formatters.formatDate(p.vencimento)}',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.danger),
                            onPressed: () => provider.removeParcela(idx),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
            const SizedBox(height: 12),
            TextFormField(
              controller: _dadosBancariosController,
              decoration: const InputDecoration(
                labelText: 'Dados Bancários & Chave PIX (Rodapé do Orçamento)',
                hintText: 'Caixa Econômica Ag: 0242 Op: 013 CP: 7675-7 / PIX: 148.374.878-23',
                prefixIcon: Icon(Icons.account_balance_outlined),
              ),
              onChanged: (val) => provider.setDadosBancarios(val),
            ),
          ],
        ),
      ),
    );

    final observacoesCard = Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Observações da Proposta:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextFormField(
              controller: _obsController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Ex: Material para instalação por conta do cliente. Medição final sujeita a conferência na obra.',
              ),
              onChanged: (val) => provider.setObservacoes(val),
            ),
          ],
        ),
      ),
    );

    final resumoCard = Card(
      color: AppColors.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'RESUMO DA PROPOSTA',
              style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
            const Divider(color: Colors.white24, height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total de Peças:', style: TextStyle(color: Colors.white)),
                Text('${provider.itensRascunho.length}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Metragem Total:', style: TextStyle(color: Colors.white)),
                Text(Formatters.formatM2(provider.m2TotalRascunho), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(color: Colors.white24, height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'VALOR TOTAL:',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  Formatters.formatCurrency(provider.valorTotalRascunho),
                  style: const TextStyle(
                    color: AppColors.secondaryLight,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (isDesktop) {
      return Column(
        children: [
          condicoesPagamentoCard,
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: observacoesCard),
              const SizedBox(width: 20),
              Expanded(flex: 2, child: resumoCard),
            ],
          ),
        ],
      );
    } else {
      return Column(
        children: [
          condicoesPagamentoCard,
          const SizedBox(height: 16),
          observacoesCard,
          const SizedBox(height: 16),
          resumoCard,
        ],
      );
    }
  }

  void _abrirModalItem(BuildContext context, OrcamentoProvider provider, {OrcamentoItem? item, int? index}) {
    showDialog(
      context: context,
      builder: (ctx) => OrcamentoItemDialog(
        materiais: provider.materiais,
        acabamentos: provider.acabamentos,
        itemInicial: item,
        onSalvar: (novoItem) {
          if (index != null) {
            provider.updateItemRascunho(index, novoItem);
          } else {
            provider.addItemRascunho(novoItem);
          }
        },
      ),
    );
  }

  void _abrirModalNovoCliente(BuildContext context, OrcamentoProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => ClienteFormDialog(
        onSalvar: (clienteSalvo) async {
          await provider.carregarDados();
          provider.setSelectedCliente(clienteSalvo);
        },
      ),
    );
  }

  Future<void> _salvar(BuildContext context, OrcamentoProvider provider) async {
    if (provider.selectedCliente == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um cliente para a proposta.')),
      );
      return;
    }
    if (provider.itensRascunho.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adicione ao menos uma peça ao orçamento.')),
      );
      return;
    }

    provider.setObservacoes(_obsController.text.trim());
    provider.setCondicaoPagamento(_condicaoPagamentoController.text.trim());
    provider.setDadosBancarios(_dadosBancariosController.text.trim());

    final id = await provider.salvarOrcamento();
    if (id != null && context.mounted) {
      // Atualiza também os providers de produção e financeiro
      Provider.of<ProducaoProvider>(context, listen: false).carregarOrdens();
      Provider.of<FinanceiroProvider>(context, listen: false).carregarContas();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Orçamento #$id salvo com sucesso no banco de dados local SQLite!'),
          backgroundColor: AppColors.success,
        ),
      );
      widget.onVoltar();
    }
  }

  void _exportarPdf(BuildContext context, OrcamentoProvider provider) {
    if (provider.selectedCliente == null || provider.itensRascunho.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Defina o cliente e itens antes de exportar.')),
      );
      return;
    }

    final orcamento = Orcamento(
      id: provider.editingId,
      clienteId: provider.selectedCliente!.id ?? 0,
      dataCriacao: Formatters.toIsoDate(DateTime.now()),
      dataValidade: Formatters.toIsoDate(provider.dataValidade),
      status: provider.status,
      valorTotal: provider.valorTotalRascunho,
      observacoes: _obsController.text.trim(),
      condicaoPagamento: _condicaoPagamentoController.text.trim(),
      dadosBancarios: _dadosBancariosController.text.trim(),
      parcelas: provider.parcelas,
      itens: provider.itensRascunho,
    );

    PdfService.gerarEVisualizarPdf(
      orcamento: orcamento,
      cliente: provider.selectedCliente!,
      empresaConfig: provider.empresaConfig,
    );
  }

  void _enviarWhatsApp(BuildContext context, OrcamentoProvider provider) {
    if (provider.selectedCliente == null || provider.itensRascunho.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Defina o cliente e itens antes de enviar.')),
      );
      return;
    }

    final cliente = provider.selectedCliente!;
    if (cliente.telefone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('O cliente selecionado não possui telefone cadastrado.')),
      );
      return;
    }

    final orcamento = Orcamento(
      id: provider.editingId,
      clienteId: cliente.id ?? 0,
      dataCriacao: Formatters.toIsoDate(DateTime.now()),
      dataValidade: Formatters.toIsoDate(provider.dataValidade),
      status: provider.status,
      valorTotal: provider.valorTotalRascunho,
      observacoes: _obsController.text.trim(),
      condicaoPagamento: _condicaoPagamentoController.text.trim(),
      dadosBancarios: _dadosBancariosController.text.trim(),
      parcelas: provider.parcelas,
      itens: provider.itensRascunho,
    );

    final texto = WhatsAppService.gerarTextoProposta(
      orcamento: orcamento,
      cliente: cliente,
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Enviar Proposta por WhatsApp'),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Destinatário: ${cliente.nome} (${cliente.telefone})', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(texto, style: const TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366)),
            onPressed: () {
              Navigator.of(ctx).pop();
              WhatsAppService.enviarWhatsApp(telefone: cliente.telefone, mensagem: texto);
            },
            icon: const Icon(Icons.send, color: Colors.white),
            label: const Text('Disparar WhatsApp', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
