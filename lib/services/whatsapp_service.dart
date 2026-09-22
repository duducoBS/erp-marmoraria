import 'package:url_launcher/url_launcher.dart';
import '../models/orcamento_model.dart';
import '../models/cliente_model.dart';
import '../core/utils/formatters.dart';

class WhatsAppService {
  static String gerarTextoProposta({
    required Orcamento orcamento,
    required Cliente cliente,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('Olá, *${cliente.nome}*! Tudo bem?');
    buffer.writeln('Segue o resumo da sua proposta comercial de marmoraria:');
    buffer.writeln('');
    buffer.writeln('📋 *PROPOSTA / ORÇAMENTO #${orcamento.id ?? "NOVO"}*');
    buffer.writeln('📅 Data: ${Formatters.formatDate(orcamento.dataCriacao)}');
    buffer.writeln('⏳ Validade: ${Formatters.formatDate(orcamento.dataValidade)}');
    buffer.writeln('--------------------------------');
    buffer.writeln('*ITENS DO PROJETO:*');

    for (var i = 0; i < orcamento.itens.length; i++) {
      final item = orcamento.itens[i];
      buffer.writeln('');
      buffer.writeln('*${i + 1}. ${item.ambiente}*');
      if (item.descricao.isNotEmpty) {
        buffer.writeln('• Detalhes: ${item.descricao}');
      }
      buffer.writeln('• Rocha/Material: ${item.materialNome ?? "Material #${item.materialId}"}');
      if (item.tipoCalculo == 'fixo') {
        buffer.writeln('• Modalidade: Valor Fixo da Peça (${Formatters.formatCurrency(item.valorFixo)})');
        if (item.largura > 0 && item.comprimento > 0) {
          buffer.writeln('• Medidas: ${Formatters.formatDecimal(item.largura)}m x ${Formatters.formatDecimal(item.comprimento)}m (Qtd: ${item.quantidade})');
        }
      } else {
        buffer.writeln('• Medidas: ${Formatters.formatDecimal(item.largura)}m x ${Formatters.formatDecimal(item.comprimento)}m (Qtd: ${item.quantidade})');
        buffer.writeln('• Área c/ perda: ${Formatters.formatM2(item.m2Total)} (+${Formatters.formatDecimal(item.perdaPercentual, decimals: 0)}%)');
        if (item.precoMetro > 0) {
          buffer.writeln('• Preço m²: ${Formatters.formatCurrency(item.precoMetro)}/m²');
        }
      }
      if (item.acabamentoNome != null) {
        buffer.writeln('• Acabamento: ${item.acabamentoNome}');
      }
      buffer.writeln('• Subtotal: ${Formatters.formatCurrency(item.valorParcial)}');
    }

    buffer.writeln('');
    buffer.writeln('--------------------------------');
    buffer.writeln('💰 *VALOR TOTAL: ${Formatters.formatCurrency(orcamento.valorTotal)}*');
    if (orcamento.observacoes.isNotEmpty) {
      buffer.writeln('');
      buffer.writeln('📝 *Observações:*');
      buffer.writeln(orcamento.observacoes);
    }
    buffer.writeln('');
    buffer.writeln('Ficamos à disposição para agendar a medição final ou tirar qualquer dúvida!');
    buffer.writeln('Marmoraria & Granitos.');

    return buffer.toString();
  }

  static Future<bool> enviarWhatsApp({
    required String telefone,
    required String mensagem,
  }) async {
    // Normaliza telefone (apenas números)
    String numeroLimpo = telefone.replaceAll(RegExp(r'\D'), '');
    if (numeroLimpo.isEmpty) return false;

    // Adiciona código do país se necessário (Brasil: 55)
    if (numeroLimpo.length <= 11) {
      numeroLimpo = '55$numeroLimpo';
    }

    final encodedMessage = Uri.encodeComponent(mensagem);
    final url = Uri.parse('https://wa.me/$numeroLimpo?text=$encodedMessage');

    try {
      if (await canLaunchUrl(url)) {
        return await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        return false;
      }
    } catch (_) {
      return false;
    }
  }
}
