import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../providers/app_provider.dart';
import '../dashboard/dashboard_view.dart';
import '../orcamento/orcamentos_list_view.dart';
import '../producao/kanban_view.dart';
import '../clientes/clientes_view.dart';
import '../catalogo/catalogo_view.dart';
import '../agenda/agenda_view.dart';
import '../financeiro/financeiro_view.dart';

class MainLayout extends StatelessWidget {
  const MainLayout({super.key});

  final List<Widget> _pages = const [
    DashboardView(),
    OrcamentosListView(),
    KanbanView(),
    ClientesView(),
    CatalogoView(),
    AgendaView(),
    FinanceiroView(),
  ];

  static const List<_NavItem> _navItems = [
    _NavItem('Dashboard', Icons.dashboard_outlined, Icons.dashboard),
    _NavItem('Orçamentos & Calculadora', Icons.request_quote_outlined, Icons.request_quote),
    _NavItem('Fábrica & Kanban', Icons.view_kanban_outlined, Icons.view_kanban),
    _NavItem('Clientes & Obras', Icons.people_outline, Icons.people),
    _NavItem('Catálogo de Materiais', Icons.layers_outlined, Icons.layers),
    _NavItem('Agenda & Medições', Icons.calendar_month_outlined, Icons.calendar_month),
    _NavItem('Financeiro & Caixa', Icons.monetization_on_outlined, Icons.monetization_on),
  ];

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final isDesktop = Responsive.isDesktop(context);

    if (isDesktop) {
      // Layout Desktop / Tablet com Sidebar Fixa Retrátil
      return Scaffold(
        body: Row(
          children: [
            _buildSidebar(context, appProvider),
            Expanded(
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: _pages[appProvider.currentIndex],
              ),
            ),
          ],
        ),
      );
    } else {
      // Layout Mobile com Drawer e Barra Inferior
      return Scaffold(
        appBar: AppBar(
          title: Text(_navItems[appProvider.currentIndex].title),
          actions: [
            IconButton(
              icon: Icon(
                appProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                color: appProvider.isDarkMode ? Colors.amber : Colors.white,
              ),
              tooltip: appProvider.isDarkMode ? 'Mudar para Tema Claro' : 'Mudar para Tema Escuro',
              onPressed: () => appProvider.toggleTheme(),
            ),
          ],
        ),
        drawer: _buildDrawer(context, appProvider),
        body: _pages[appProvider.currentIndex],
        bottomNavigationBar: NavigationBar(
          selectedIndex: appProvider.currentIndex < 4 ? appProvider.currentIndex : 0,
          onDestinationSelected: (index) {
            if (index == 3 && appProvider.currentIndex >= 4) {
              // Mantém drawer para mais opções
            } else {
              appProvider.setPageIndex(index);
            }
          },
          destinations: const [
            NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Início'),
            NavigationDestination(icon: Icon(Icons.request_quote_outlined), label: 'Orçamentos'),
            NavigationDestination(icon: Icon(Icons.view_kanban_outlined), label: 'Produção'),
            NavigationDestination(icon: Icon(Icons.people_outline), label: 'Clientes'),
          ],
        ),
      );
    }
  }

  Widget _buildSidebar(BuildContext context, AppProvider appProvider) {
    final expanded = appProvider.sidebarExpanded;
    final width = expanded ? 260.0 : 78.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: width,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        border: Border(right: BorderSide(color: AppColors.primaryLight, width: 1)),
      ),
      child: Column(
        children: [
          // Top Brand Header com Logo Edu
          Container(
            height: 70,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            alignment: Alignment.centerLeft,
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.primaryLight, width: 1)),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(3),
                  child: Image.asset(
                    'assets/images/logo_edu.png',
                    fit: BoxFit.contain,
                  ),
                ),
                if (expanded) ...[
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ERP Marmoraria',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          'Edu Mármores & Granitos',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 10.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                IconButton(
                  icon: Icon(
                    expanded ? Icons.chevron_left : Icons.chevron_right,
                    color: Colors.white70,
                    size: 20,
                  ),
                  onPressed: () => appProvider.toggleSidebar(),
                ),
              ],
            ),
          ),

          // Menu de Navegação
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              itemCount: _navItems.length,
              itemBuilder: (context, index) {
                final item = _navItems[index];
                final isSelected = appProvider.currentIndex == index;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Material(
                    color: isSelected ? AppColors.secondary : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => appProvider.setPageIndex(index),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        child: Row(
                          children: [
                            Icon(
                              isSelected ? item.activeIcon : item.icon,
                              color: isSelected ? Colors.white : Colors.white70,
                              size: 22,
                            ),
                            if (expanded) ...[
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  item.title,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.white70,
                                    fontSize: 13,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Alternador de Tema Escuro / Claro (Sidebar)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.primaryLight, width: 1)),
            ),
            child: Row(
              mainAxisAlignment: expanded ? MainAxisAlignment.spaceBetween : MainAxisAlignment.center,
              children: [
                if (expanded) ...[
                  Row(
                    children: [
                      Icon(
                        appProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                        color: appProvider.isDarkMode ? Colors.amber : Colors.amber.shade200,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        appProvider.isDarkMode ? 'Modo Escuro' : 'Modo Claro',
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  Transform.scale(
                    scale: 0.8,
                    child: Switch(
                      value: appProvider.isDarkMode,
                      onChanged: (_) => appProvider.toggleTheme(),
                      activeThumbColor: Colors.amber,
                      activeTrackColor: Colors.amber.withValues(alpha: 0.4),
                    ),
                  ),
                ] else ...[
                  IconButton(
                    icon: Icon(
                      appProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                      color: appProvider.isDarkMode ? Colors.amber : Colors.amber.shade200,
                      size: 20,
                    ),
                    tooltip: appProvider.isDarkMode ? 'Mudar para Modo Claro' : 'Mudar para Modo Escuro',
                    onPressed: () => appProvider.toggleTheme(),
                  ),
                ],
              ],
            ),
          ),

          // Rodapé do Menu (Status SQLite Local)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.primaryLight, width: 1)),
            ),
            child: Row(
              children: [
                const Icon(Icons.storage, color: AppColors.success, size: 18),
                if (expanded) ...[
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('SQLite Local Ativo', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                        Text('Windows Desktop / Android', style: TextStyle(color: Colors.white54, fontSize: 10)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, AppProvider appProvider) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: AppColors.primary),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(5),
                    child: Image.asset(
                      'assets/images/logo_edu.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'ERP Marmoraria',
                    style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Edu Mármores & Granitos',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 11.5),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _navItems.length,
              itemBuilder: (context, index) {
                final item = _navItems[index];
                final isSelected = appProvider.currentIndex == index;

                return ListTile(
                  leading: Icon(
                    isSelected ? item.activeIcon : item.icon,
                    color: isSelected ? AppColors.secondary : null,
                  ),
                  title: Text(
                    item.title,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? AppColors.secondary : null,
                    ),
                  ),
                  selected: isSelected,
                  onTap: () {
                    appProvider.setPageIndex(index);
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(
              appProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: Colors.amber,
            ),
            title: Text(
              appProvider.isDarkMode ? 'Modo Escuro' : 'Modo Claro',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            trailing: Switch(
              value: appProvider.isDarkMode,
              onChanged: (_) => appProvider.toggleTheme(),
              activeThumbColor: Colors.amber,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final String title;
  final IconData icon;
  final IconData activeIcon;

  const _NavItem(this.title, this.icon, this.activeIcon);
}
