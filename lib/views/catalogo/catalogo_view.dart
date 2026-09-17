import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/material_model.dart';
import '../../models/acabamento_model.dart';
import '../../providers/orcamento_provider.dart';
import '../../services/database_service.dart';
import 'material_form_dialog.dart';
import 'acabamento_form_dialog.dart';

class CatalogoView extends StatefulWidget {
  const CatalogoView({super.key});

  @override
  State<CatalogoView> createState() => _CatalogoViewState();
}

class _CatalogoViewState extends State<CatalogoView> with SingleTickerProviderStateMixin {
  final DatabaseService _dbService = DatabaseService();
  late TabController _tabController;

  List<MaterialItem> _materiais = [];
  List<AcabamentoServico> _acabamentos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() => _isLoading = true);
    try {
      final mats = await _dbService.getMateriais();
      final acabs = await _dbService.getAcabamentos();
      if (mounted) {
        setState(() {
          _materiais = mats;
          _acabamentos = acabs;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
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
                      'Catálogo de Preços & Materiais',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Tabela de custos e preços de venda por m² e serviços de corte/acabamento',
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
                    if (_tabController.index == 0) {
                      _abrirDialogMaterial();
                    } else {
                      _abrirDialogAcabamento();
                    }
                  },
                  icon: const Icon(Icons.add, size: 20),
                  label: Text(_tabController.index == 0 ? 'Novo Material' : 'Novo Acabamento'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Abas
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorColor: AppColors.primary,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorWeight: 3,
                onTap: (_) => setState(() {}),
                tabs: [
                  Tab(
                    icon: const Icon(Icons.layers_outlined, size: 20),
                    text: 'Materiais & Pedras (${_materiais.length})',
                  ),
                  Tab(
                    icon: const Icon(Icons.handyman_outlined, size: 20),
                    text: 'Acabamentos & Serviços (${_acabamentos.length})',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Conteúdo das Abas
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildMateriaisTab(),
                        _buildAcabamentosTab(),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMateriaisTab() {
    if (_materiais.isEmpty) {
      return const Center(child: Text('Nenhum material cadastrado.'));
    }

    return ListView.separated(
      itemCount: _materiais.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final mat = _materiais[index];
        final margem = mat.margemLucro;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.layers, color: AppColors.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            mat.nome,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(width: 8),
                          Chip(
                            label: Text('${mat.tipo} • ${mat.espessura}', style: const TextStyle(fontSize: 10)),
                            backgroundColor: AppColors.surfaceVariant,
                            side: BorderSide.none,
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Custo: ${Formatters.formatCurrency(mat.precoM2Custo)}/m² • Margem Bruta: ${margem.toStringAsFixed(1)}%',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Preço de Venda / m²', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      Text(
                        Formatters.formatCurrency(mat.precoM2Venda),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                      onPressed: () => _abrirDialogMaterial(material: mat),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppColors.danger),
                      onPressed: () => _confirmarExclusaoMaterial(mat),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAcabamentosTab() {
    if (_acabamentos.isEmpty) {
      return const Center(child: Text('Nenhum acabamento cadastrado.'));
    }

    return ListView.separated(
      itemCount: _acabamentos.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final acab = _acabamentos[index];

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.handyman, color: AppColors.secondary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        acab.nome,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Cobrança: ${acab.tipoCobrancaLabel}',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Valor do Serviço', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      Text(
                        Formatters.formatCurrency(acab.valor),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                      onPressed: () => _abrirDialogAcabamento(acabamento: acab),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppColors.danger),
                      onPressed: () => _confirmarExclusaoAcabamento(acab),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _abrirDialogMaterial({MaterialItem? material}) {
    showDialog(
      context: context,
      builder: (ctx) => MaterialFormDialog(
        materialInicial: material,
        onSalvar: () {
          _carregarDados();
          Provider.of<OrcamentoProvider>(context, listen: false).carregarDados();
        },
      ),
    );
  }

  void _abrirDialogAcabamento({AcabamentoServico? acabamento}) {
    showDialog(
      context: context,
      builder: (ctx) => AcabamentoFormDialog(
        acabamentoInicial: acabamento,
        onSalvar: () {
          _carregarDados();
          Provider.of<OrcamentoProvider>(context, listen: false).carregarDados();
        },
      ),
    );
  }

  void _confirmarExclusaoMaterial(MaterialItem mat) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir Material?'),
        content: Text('Deseja remover "${mat.nome}" do catálogo?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () async {
              Navigator.of(ctx).pop();
              if (mat.id != null) {
                await _dbService.deleteMaterial(mat.id!);
                _carregarDados();
                if (mounted) {
                  Provider.of<OrcamentoProvider>(context, listen: false).carregarDados();
                }
              }
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  void _confirmarExclusaoAcabamento(AcabamentoServico acab) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir Acabamento?'),
        content: Text('Deseja remover "${acab.nome}" do catálogo?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () async {
              Navigator.of(ctx).pop();
              if (acab.id != null) {
                await _dbService.deleteAcabamento(acab.id!);
                _carregarDados();
                if (mounted) {
                  Provider.of<OrcamentoProvider>(context, listen: false).carregarDados();
                }
              }
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}
