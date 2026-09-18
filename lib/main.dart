import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'core/constants/app_theme.dart';
import 'database/database_helper.dart';
import 'providers/app_provider.dart';
import 'providers/orcamento_provider.dart';
import 'providers/producao_provider.dart';
import 'providers/financeiro_provider.dart';
import 'views/layout/main_layout.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicialização FFI para SQLite no Windows e Linux nativo
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Assegura criação das tabelas e carga inicial de dados
  await DatabaseHelper.instance.database;

  runApp(const ErpMarmorariaApp());
}

class ErpMarmorariaApp extends StatelessWidget {
  const ErpMarmorariaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => OrcamentoProvider()),
        ChangeNotifierProvider(create: (_) => ProducaoProvider()),
        ChangeNotifierProvider(create: (_) => FinanceiroProvider()),
      ],
      child: MaterialApp(
        title: 'ERP Marmoraria',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const MainLayout(),
      ),
    );
  }
}
