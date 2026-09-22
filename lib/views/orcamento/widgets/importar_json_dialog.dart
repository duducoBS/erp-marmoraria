import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../services/json_import_service.dart';

class ImportarJsonDialog extends StatefulWidget {
  final VoidCallback onImportado;

  const ImportarJsonDialog({
    super.key,
    required this.onImportado,
  });

  @override
  State<ImportarJsonDialog> createState() => _ImportarJsonDialogState();
}

class _ImportarJsonDialogState extends State<ImportarJsonDialog> {
  final TextEditingController _jsonController = TextEditingController();
  bool _processando = false;
  String? _resultadoMsg;
  bool _sucesso = false;

  @override
  void dispose() {
    _jsonController.dispose();
    super.dispose();
  }

  Future<void> _executarImportacao() async {
    final text = _jsonController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cole o conteúdo do arquivo JSON de backup')),
      );
      return;
    }

    setState(() {
      _processando = true;
      _resultadoMsg = null;
    });

    final service = JsonImportService();
    final res = await service.importarBackupJson(text);

    setState(() {
      _processando = false;
      if (res.sucesso) {
        _sucesso = true;
        _resultadoMsg = 'Sucesso!\n'
            '• ${res.orcamentosImportados} orçamentos importados\n'
            '• ${res.clientesImportados} novos clientes cadastrados\n'
            '• Configurações da empresa: ${res.empresaAtualizada ? "Atualizadas" : "Mantidas"}';
      } else {
        _sucesso = false;
        _resultadoMsg = 'Falha na importação:\n${res.erro}';
      }
    });

    if (res.sucesso) {
      widget.onImportado();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580, maxHeight: 600),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.file_download_outlined, color: AppColors.secondary, size: 28),
                      SizedBox(width: 10),
                      Text(
                        'Importar Backup JSON',
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
              const SizedBox(height: 6),
              const Text(
                'Importe os orçamentos e dados da marmoraria exportados do outro sistema (orcamentos-marmoraria). Cole o texto do arquivo .json abaixo:',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const Divider(height: 20),
              Expanded(
                child: TextField(
                  controller: _jsonController,
                  maxLines: null,
                  expands: true,
                  style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                  decoration: const InputDecoration(
                    hintText: 'Cole aqui o conteúdo do arquivo JSON exportado (ex: orcamentos_backup_2026-09-18.json)...',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                ),
              ),
              if (_resultadoMsg != null) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _sucesso ? AppColors.success.withValues(alpha: 0.1) : AppColors.danger.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _sucesso ? AppColors.success : AppColors.danger),
                  ),
                  child: Text(
                    _resultadoMsg!,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _sucesso ? AppColors.success : AppColors.danger,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Fechar'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
                    onPressed: _processando ? null : _executarImportacao,
                    icon: _processando
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.upload_file, size: 18),
                    label: Text(_processando ? 'Processando...' : 'Iniciar Importação'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
