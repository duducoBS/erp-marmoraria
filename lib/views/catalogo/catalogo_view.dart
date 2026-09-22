import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/responsive.dart';
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
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 10,
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
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkSurfaceVariant
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkBorder
                      : Colors.transparent,
                ),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorColor: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.secondary
                    : AppColors.primary,
                labelColor: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.secondaryLight
                    : AppColors.primary,
                unselectedLabelColor: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
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

    final isDesktop = Responsive.isDesktop(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView.separated(
      itemCount: _materiais.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final mat = _materiais[index];
        final margem = mat.margemLucro;

        final iconBox = Container(
          width: isDesktop ? 48 : 40,
          height: isDesktop ? 48 : 40,
          decoration: BoxDecoration(
            color: isDark ? AppColors.secondary.withValues(alpha: 0.15) : AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.layers, color: isDark ? AppColors.secondaryLight : AppColors.primary, size: isDesktop ? 24 : 20),
        );

        final actions = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit_outlined, color: isDark ? AppColors.secondaryLight : AppColors.primary),
              onPressed: () => _abrirDialogMaterial(material: mat),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.danger),
              onPressed: () => _confirmarExclusaoMaterial(mat),
            ),
          ],
        );

        if (isDesktop) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  iconBox,
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                mat.nome,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Chip(
                              label: Text(
                                '${mat.tipo} • ${mat.espessura}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                ),
                              ),
                              backgroundColor: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
                              side: BorderSide.none,
                              padding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Custo: ${Formatters.formatCurrency(mat.precoM2Custo)}/m² • Margem Bruta: ${margem.toStringAsFixed(1)}%',
                          style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Preço de Venda / m²', style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)),
                        Text(
                          Formatters.formatCurrency(mat.precoM2Venda),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: isDark ? const Color(0xFF34D399) : AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions,
                ],
              ),
            ),
          );
        } else {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      iconBox,
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          mat.nome,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Chip(
                        label: Text(
                          '${mat.tipo} • ${mat.espessura}',
                          style: TextStyle(
                            fontSize: 10,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                          ),
                        ),
                        backgroundColor: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
                        side: BorderSide.none,
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Custo: ${Formatters.formatCurrency(mat.precoM2Custo)}/m² • Margem: ${margem.toStringAsFixed(1)}%',
                    style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                  ),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Preço Venda / m²', style: TextStyle(fontSize: 10, color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)),
                          Text(
                            Formatters.formatCurrency(mat.precoM2Venda),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isDark ? const Color(0xFF34D399) : AppColors.success,
                            ),
                          ),
                        ],
                      ),
                      actions,
                    ],
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildAcabamentosTab() {
    if (_acabamentos.isEmpty) {
      return const Center(child: Text('Nenhum acabamento cadastrado.'));
    }

    final isDesktop = Responsive.isDesktop(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView.separated(
      itemCount: _acabamentos.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final acab = _acabamentos[index];

        final iconBox = Container(
          width: isDesktop ? 48 : 40,
          height: isDesktop ? 48 : 40,
          decoration: BoxDecoration(
            color: AppColors.secondary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.handyman, color: AppColors.secondary, size: isDesktop ? 24 : 20),
        );

        final actions = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit_outlined, color: isDark ? AppColors.secondaryLight : AppColors.primary),
              onPressed: () => _abrirDialogAcabamento(acabamento: acab),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.danger),
              onPressed: () => _confirmarExclusaoAcabamento(acab),
            ),
          ],
        );

        if (isDesktop) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  iconBox,
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
                          style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Valor do Serviço', style: TextStyle(fontSize: 11, color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)),
                        Text(
                          Formatters.formatCurrency(acab.valor),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: isDark ? const Color(0xFF38BDF8) : AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions,
                ],
              ),
            ),
          );
        } else {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      iconBox,
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          acab.nome,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Cobrança: ${acab.tipoCobrancaLabel}',
                    style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                  ),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Valor do Serviço', style: TextStyle(fontSize: 10, color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)),
                          Text(
                            Formatters.formatCurrency(acab.valor),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isDark ? const Color(0xFF38BDF8) : AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      actions,
                    ],
                  ),
                ],
              ),
            ),
          );
        }
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
