import 'package:flutter/material.dart';

class AppProvider extends ChangeNotifier {
  int _currentIndex = 0;
  bool _sidebarExpanded = true;
  bool _isDarkMode = false;

  int get currentIndex => _currentIndex;
  bool get sidebarExpanded => _sidebarExpanded;
  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setPageIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void toggleSidebar() {
    _sidebarExpanded = !_sidebarExpanded;
    notifyListeners();
  }

  void openNovoOrcamento() {
    _currentIndex = 1; // Tela de Orçamentos
    notifyListeners();
  }

  void openNovaMedicao() {
    _currentIndex = 2; // Tela de Produção / Kanban
    notifyListeners();
  }

  void openClientes() {
    _currentIndex = 3;
    notifyListeners();
  }
}
