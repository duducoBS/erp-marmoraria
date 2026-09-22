import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/orcamento_model.dart';
import '../models/cliente_model.dart';
import '../models/empresa_config_model.dart';
import '../core/utils/formatters.dart';

class PdfService {
  static Future<void> gerarEVisualizarPdf({
    required Orcamento orcamento,
    required Cliente cliente,
    EmpresaConfig? empresaConfig,
  }) async {
    final empresa = empresaConfig ?? EmpresaConfig();
    final pdf = pw.Document();

    pw.ImageProvider? logoImage;
    try {
      logoImage = await imageFromAssetBundle('assets/images/logo_edu_transparent.png');
    } catch (_) {}

    pw.ImageProvider? acabamentosImage;
    try {
      acabamentosImage = await imageFromAssetBundle('assets/images/acabamentos.png');
    } catch (_) {}

    pw.ThemeData? themeData;
    try {
      final fontRegular = await PdfGoogleFonts.robotoRegular();
      final fontBold = await PdfGoogleFonts.robotoBold();
      final fontItalic = await PdfGoogleFonts.robotoItalic();
      themeData = pw.ThemeData.withFont(
        base: fontRegular,
        bold: fontBold,
        italic: fontItalic,
      );
    } catch (_) {}

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        theme: themeData,
        build: (pw.Context context) {
          return [
            // 1. CABEÇALHO DA EMPRESA (LAYOUT MODELO TRADICIONAL)
            pw.Container(
              padding: const pw.EdgeInsets.only(bottom: 10),
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(color: PdfColors.blueGrey800, width: 1.5),
                ),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  // Logo + Dados da Empresa
                  pw.Expanded(
                    flex: 6,
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        if (logoImage != null)
                          pw.Container(
                            height: 44,
                            width: 75,
                            margin: const pw.EdgeInsets.only(right: 10),
                            child: pw.Image(logoImage, fit: pw.BoxFit.contain),
                          ),
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                empresa.nome,
                                style: pw.TextStyle(
                                  fontSize: 14,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.blueGrey900,
                                ),
                              ),
                              pw.SizedBox(height: 2),
                              pw.Text(
                                'CNPJ: ${empresa.cnpj}',
                                style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
                              ),
                              pw.Text(
                                empresa.endereco,
                                style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey700),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Especialidades & Contato
                  pw.Expanded(
                    flex: 4,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'MÁRMORES | GRANITOS | PEDRAS DECORATIVAS',
                          style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey800),
                          textAlign: pw.TextAlign.right,
                        ),
                        pw.Text(
                          'PIAS | LAVATÓRIOS | PISOS | ESCADAS | SOLEIRAS',
                          style: const pw.TextStyle(fontSize: 6.5, color: PdfColors.grey700),
                          textAlign: pw.TextAlign.right,
                        ),
                        pw.SizedBox(height: 4),
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: pw.BoxDecoration(
                            color: PdfColors.blueGrey50,
                            borderRadius: pw.BorderRadius.circular(4),
                            border: pw.Border.all(color: PdfColors.blueGrey200, width: 0.5),
                          ),
                          child: pw.Row(
                            mainAxisSize: pw.MainAxisSize.min,
                            children: [
                              pw.Text(
                                'Contato: ${empresa.fone1} | ${empresa.resp1}',
                                style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey900),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 8),

            // 2. BANNER DE DATA E NÚMERO DO ORÇAMENTO
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: pw.BoxDecoration(
                color: PdfColors.blueGrey50,
                borderRadius: pw.BorderRadius.circular(4),
                border: pw.Border.all(color: PdfColors.blueGrey200, width: 0.5),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    '${empresa.cidadePadrao}, ${_formatarDataExtenso(orcamento.dataCriacao)}',
                    style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.blueGrey800),
                  ),
                  pw.Row(
                    children: [
                      pw.Text(
                        'PROPOSTA / ORÇAMENTO  ',
                        style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey700),
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.blueGrey800,
                          borderRadius: pw.BorderRadius.circular(3),
                        ),
                        child: pw.Text(
                          'Nº ${orcamento.id ?? "NOVO"}',
                          style: pw.TextStyle(
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 8),

            // 3. DADOS DO CLIENTE / SOLICITANTE
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300, width: 0.8),
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.only(bottom: 4),
                    decoration: const pw.BoxDecoration(
                      border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200, width: 0.5)),
                    ),
                    child: pw.Row(
                      children: [
                        pw.Text('NOME / RAZÃO SOCIAL: ', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey900)),
                        pw.Expanded(
                          child: pw.Text(cliente.nome.toUpperCase(), style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Row(
                    children: [
                      pw.Expanded(
                        flex: 5,
                        child: pw.Text('ENDEREÇO: ${cliente.endereco.isNotEmpty ? cliente.endereco : "-"}', style: const pw.TextStyle(fontSize: 7.5)),
                      ),
                      pw.Expanded(
                        flex: 3,
                        child: pw.Text('BAIRRO: ${cliente.bairro.isNotEmpty ? cliente.bairro : "-"}', style: const pw.TextStyle(fontSize: 7.5)),
                      ),
                      pw.Expanded(
                        flex: 2,
                        child: pw.Text('CEP: ${cliente.cep.isNotEmpty ? cliente.cep : "-"}', style: const pw.TextStyle(fontSize: 7.5)),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 3),
                  pw.Row(
                    children: [
                      pw.Expanded(
                        flex: 3,
                        child: pw.Text('CIDADE / UF: ${cliente.cidade.isNotEmpty ? cliente.cidade : empresa.cidadePadrao}', style: const pw.TextStyle(fontSize: 7.5)),
                      ),
                      pw.Expanded(
                        flex: 3,
                        child: pw.Text('CPF / CNPJ: ${cliente.documento.isNotEmpty ? cliente.documento : "-"}', style: const pw.TextStyle(fontSize: 7.5)),
                      ),
                      pw.Expanded(
                        flex: 4,
                        child: pw.Text('TELEFONE / WHATSAPP: ${cliente.telefone.isNotEmpty ? cliente.telefone : "-"}', style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  ),
                  if (orcamento.condicaoPagamento.isNotEmpty) ...[
                    pw.SizedBox(height: 3),
                    pw.Text(
                      'CONDIÇÃO DE PAGAMENTO: ${orcamento.condicaoPagamento}',
                      style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey800),
                    ),
                  ],
                ],
              ),
            ),
            pw.SizedBox(height: 8),

            // 4. TABELA DE ITENS / MERCADORIAS
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              children: [
                // Header da Tabela
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
                  children: [
                    _tableCell('Qtd', isHeader: true, align: pw.TextAlign.center, isLight: true),
                    _tableCell('Descrição da Mercadoria / Ambiente / Peça', isHeader: true, isLight: true),
                    _tableCell('Acabamento', isHeader: true, isLight: true),
                    _tableCell('Cor / Material', isHeader: true, isLight: true),
                    _tableCell(r'Total (R$)', isHeader: true, align: pw.TextAlign.right, isLight: true),
                  ],
                ),
                // Linhas de Itens
                ...orcamento.itens.map((item) {
                  final perdaStr = '+${Formatters.formatDecimal(item.perdaPercentual, decimals: 0)}%';
                  final medidasStr = item.largura > 0 && item.comprimento > 0
                      ? '${Formatters.formatDecimal(item.largura)}m x ${Formatters.formatDecimal(item.comprimento)}m'
                      : '';
                  final m2Str = item.tipoCalculo == 'fixo'
                      ? 'Preço Fixo'
                      : '${Formatters.formatDecimal(item.m2Total)} m2 ($perdaStr)';

                  final descricaoCompleta = pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(item.ambiente, style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                      if (medidasStr.isNotEmpty || item.tipoCalculo != 'fixo')
                        pw.Text('$medidasStr | Área: $m2Str', style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey700)),
                      if (item.descricao.isNotEmpty)
                        pw.Text('- ${item.descricao}', style: pw.TextStyle(fontSize: 7, fontStyle: pw.FontStyle.italic, color: PdfColors.blueGrey800)),
                    ],
                  );

                  final acabamentoStr = item.acabamentoNome != null
                      ? '${item.acabamentoNome!} ${item.acabamentoQuantidade > 0 ? "(${Formatters.formatDecimal(item.acabamentoQuantidade)})" : ""}'
                      : '01 - Padrão Reto';

                  final materialLabel = item.materialNome ?? 'Material #${item.materialId}';
                  final materialWithPrice = item.tipoCalculo == 'metro' && item.precoMetro > 0
                      ? '$materialLabel\n(${Formatters.formatCurrency(item.precoMetro)}/m2)'
                      : materialLabel;

                  return pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                        child: pw.Text('${item.quantidade}', textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 8)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                        child: descricaoCompleta,
                      ),
                      _tableCell(acabamentoStr),
                      _tableCell(materialWithPrice),
                      _tableCell(Formatters.formatCurrency(item.valorParcial), align: pw.TextAlign.right),
                    ],
                  );
                }),
              ],
            ),
            pw.SizedBox(height: 8),

            // 5. GUIA TÉCNICO ILUSTRADO DE ACABAMENTOS (BORDAS E COLUNAS)
            if (acabamentosImage != null) ...[
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.symmetric(vertical: 3),
                decoration: const pw.BoxDecoration(
                  color: PdfColors.blueGrey100,
                  borderRadius: pw.BorderRadius.all(pw.Radius.circular(2)),
                ),
                child: pw.Center(
                  child: pw.Text(
                    'GUIA TÉCNICO DE ACABAMENTOS DE BORDAS E COLUNAS',
                    style: pw.TextStyle(
                      fontSize: 7.5,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blueGrey900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              pw.SizedBox(height: 3),
              pw.Container(
                height: 110,
                width: double.infinity,
                alignment: pw.Alignment.center,
                decoration: pw.BoxDecoration(
                  color: PdfColors.white,
                  border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Center(
                  child: pw.Image(
                    acabamentosImage,
                    fit: pw.BoxFit.contain,
                    alignment: pw.Alignment.center,
                  ),
                ),
              ),
              pw.SizedBox(height: 8),
            ],

            // 6. SEÇÃO FINANCEIRA: PARCELAMENTO, TOTAL E OBSERVAÇÕES
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Parcelamento
                pw.Expanded(
                  flex: 3,
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(6),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey300, width: 0.6),
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('PARCELAMENTO / VENCIMENTOS', style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey800)),
                        pw.Divider(color: PdfColors.grey300, height: 6),
                        if (orcamento.parcelas.isNotEmpty) ...[
                          ...orcamento.parcelas.map((p) {
                            final label = (p.descricao != null && p.descricao!.trim().isNotEmpty)
                                ? '${p.descricao!}:'
                                : '${p.numero}ª Parcela:';
                            return pw.Padding(
                              padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
                              child: pw.Row(
                                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Text(label, style: const pw.TextStyle(fontSize: 7.5)),
                                  pw.Text(Formatters.formatCurrency(p.valor), style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold)),
                                  pw.Text('Venc: ${Formatters.formatDate(p.vencimento)}', style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey700)),
                                ],
                              ),
                            );
                          }),
                        ] else ...[
                          pw.Text(
                            orcamento.condicaoPagamento.isNotEmpty ? orcamento.condicaoPagamento : 'À vista na colocação / entrega',
                            style: const pw.TextStyle(fontSize: 7.5),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                pw.SizedBox(width: 8),

                // Valor Total e Observações
                pw.Expanded(
                  flex: 3,
                  child: pw.Column(
                    children: [
                      // Total Card
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.blueGrey900,
                          borderRadius: pw.BorderRadius.circular(4),
                        ),
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('VALOR TOTAL:', style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 10)),
                            pw.Text(
                              Formatters.formatCurrency(orcamento.valorTotal),
                              style: pw.TextStyle(color: PdfColors.amber300, fontWeight: pw.FontWeight.bold, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      pw.SizedBox(height: 6),

                      // Caixa de Observações
                      pw.Container(
                        width: double.infinity,
                        padding: const pw.EdgeInsets.all(6),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.red50,
                          border: pw.Border.all(color: PdfColors.red200, width: 0.5),
                          borderRadius: pw.BorderRadius.circular(4),
                        ),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              orcamento.observacoes.isNotEmpty
                                  ? orcamento.observacoes
                                  : empresa.observacoesPadrao,
                              style: const pw.TextStyle(fontSize: 7, color: PdfColors.red900),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 12),

            // 7. BLOCO DE ASSINATURAS E FECHAMENTO
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    children: [
                      pw.Container(height: 0.8, color: PdfColors.black),
                      pw.SizedBox(height: 2),
                      pw.Text(empresa.nome, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 7.5)),
                      pw.Text('Responsável Técnico / Vendedor', style: const pw.TextStyle(fontSize: 6.5, color: PdfColors.grey700)),
                    ],
                  ),
                ),
                pw.SizedBox(width: 30),
                pw.Expanded(
                  child: pw.Column(
                    children: [
                      pw.Container(height: 0.8, color: PdfColors.black),
                      pw.SizedBox(height: 2),
                      pw.Text('DE ACORDO DO CLIENTE', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 7.5)),
                      pw.Text('Assinatura do Solicitante / Data: ____/____/________', style: const pw.TextStyle(fontSize: 6.5, color: PdfColors.grey700)),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 8),

            // 8. DADOS BANCÁRIOS E CHAVE PIX NO RODAPÉ
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Text(
                'DADOS BANCÁRIOS & PIX: ${orcamento.dadosBancarios.isNotEmpty ? orcamento.dadosBancarios : empresa.dadosBancarios}',
                style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey900),
                textAlign: pw.TextAlign.center,
              ),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Orcamento_${orcamento.id ?? "Proposta"}_${cliente.nome.replaceAll(" ", "_")}.pdf',
    );
  }

  static pw.Widget _tableCell(String text, {bool isHeader = false, pw.TextAlign align = pw.TextAlign.left, bool isLight = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 3.5),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
          fontSize: isHeader ? 7.5 : 7.5,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isLight ? PdfColors.white : PdfColors.black,
        ),
      ),
    );
  }

  static String _formatarDataExtenso(String dataIso) {
    try {
      final dt = DateTime.parse(dataIso);
      final meses = [
        'janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho',
        'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro'
      ];
      return '${dt.day} de ${meses[dt.month - 1]} de ${dt.year}';
    } catch (_) {
      return dataIso;
    }
  }
}
