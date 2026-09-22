import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/orcamento_model.dart';
import '../models/cliente_model.dart';
import '../core/utils/formatters.dart';

class PdfService {
  static Future<void> gerarEVisualizarPdf({
    required Orcamento orcamento,
    required Cliente cliente,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Cabeçalho da Marmoraria
            pw.Container(
              padding: const pw.EdgeInsets.only(bottom: 16),
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(color: PdfColors.blueGrey800, width: 2),
                ),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'MARMORARIA & GRANITOS',
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blueGrey900,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Especialistas em Mármores, Granitos, Quartzos e Superfícies Nobres',
                        style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                      ),
                      pw.Text(
                        'Bancadas • Ilhas • Cubas Esculpidas • Soleiras • Nichos • Revestimentos',
                        style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.blueGrey800,
                          borderRadius: pw.BorderRadius.circular(4),
                        ),
                        child: pw.Text(
                          'ORÇAMENTO #${orcamento.id ?? "NOVO"}',
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Emissão: ${Formatters.formatDate(orcamento.dataCriacao)}',
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                      pw.Text(
                        'Validade: ${Formatters.formatDate(orcamento.dataValidade)}',
                        style: const pw.TextStyle(fontSize: 9, color: PdfColors.red800),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 16),

            // Dados do Cliente / Obra
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(6),
                border: pw.Border.all(color: PdfColors.grey300),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'DADOS DO CLIENTE & LOCAL DA OBRA',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 10,
                      color: PdfColors.blueGrey800,
                    ),
                  ),
                  pw.SizedBox(height: 6),
                  pw.Row(
                    children: [
                      pw.Expanded(
                        child: pw.Text('Nome/Razão: ${cliente.nome}', style: const pw.TextStyle(fontSize: 9)),
                      ),
                      pw.Expanded(
                        child: pw.Text('Documento: ${cliente.documento.isNotEmpty ? cliente.documento : "-"}', style: const pw.TextStyle(fontSize: 9)),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 3),
                  pw.Row(
                    children: [
                      pw.Expanded(
                        child: pw.Text('Telefone: ${cliente.telefone}', style: const pw.TextStyle(fontSize: 9)),
                      ),
                      pw.Expanded(
                        child: pw.Text('E-mail: ${cliente.email.isNotEmpty ? cliente.email : "-"}', style: const pw.TextStyle(fontSize: 9)),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 3),
                  pw.Text(
                    'Endereço: ${cliente.endereco} - ${cliente.cidade}',
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 16),

            // Tabela de Itens
            pw.Text(
              'DISCRIMINAÇÃO DOS MATERIAIS, MEDIDAS E SERVIÇOS',
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 10,
                color: PdfColors.blueGrey800,
              ),
            ),
            pw.SizedBox(height: 8),

            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              children: [
                // Header da Tabela
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    _tableCell('Ambiente', isHeader: true),
                    _tableCell('Material / Rocha', isHeader: true),
                    _tableCell('Medidas (L x C x Qtd)', isHeader: true),
                    _tableCell('m² c/ Perda', isHeader: true),
                    _tableCell('Acabamento / Serviços', isHeader: true),
                    _tableCell('Total Item', isHeader: true, align: pw.TextAlign.right),
                  ],
                ),
                // Linhas de Itens
                ...orcamento.itens.map((item) {
                  final perdaStr = '+${Formatters.formatDecimal(item.perdaPercentual, decimals: 0)}%';
                  final medidasStr = item.largura > 0 && item.comprimento > 0
                      ? '${Formatters.formatDecimal(item.largura)} x ${Formatters.formatDecimal(item.comprimento)}m (x${item.quantidade})'
                      : 'Qtd: ${item.quantidade}';
                  final acabamentoStr = item.acabamentoNome != null
                      ? '${item.acabamentoNome!} (${item.acabamentoQuantidade > 0 ? Formatters.formatDecimal(item.acabamentoQuantidade) : ""})'
                      : 'Padrão Reto';

                  final m2Text = item.tipoCalculo == 'fixo'
                      ? (item.m2Total > 0 ? '${Formatters.formatDecimal(item.m2Total)} m² (Fixo)' : 'Valor Fixo')
                      : '${Formatters.formatDecimal(item.m2Total)} m² ($perdaStr)';

                  final materialLabel = item.materialNome ?? 'Material #${item.materialId}';
                  final materialWithPrice = item.tipoCalculo == 'metro' && item.precoMetro > 0
                      ? '$materialLabel\n(${Formatters.formatCurrency(item.precoMetro)}/m²)'
                      : (item.tipoCalculo == 'fixo' ? '$materialLabel\n(Preço Fixo)' : materialLabel);

                  return pw.TableRow(
                    children: [
                      _tableCell(item.ambiente),
                      _tableCell(materialWithPrice),
                      _tableCell(medidasStr),
                      _tableCell(m2Text),
                      _tableCell(acabamentoStr),
                      _tableCell(Formatters.formatCurrency(item.valorParcial), align: pw.TextAlign.right),
                    ],
                  );
                }),
              ],
            ),
            pw.SizedBox(height: 16),

            // Totais e Observações
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  flex: 3,
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey300),
                      borderRadius: pw.BorderRadius.circular(6),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'OBSERVAÇÕES E CONDIÇÕES GERAIS:',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          orcamento.observacoes.isNotEmpty
                              ? orcamento.observacoes
                              : '• Medição final será confirmada na obra após instalação dos móveis.\n'
                                '• Prazo de entrega: 10 a 15 dias úteis após conferência e aprovação do projeto executivo.\n'
                                '• Formas de pagamento: Entrada 50% e saldo na entrega/instalação.',
                          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey800),
                        ),
                      ],
                    ),
                  ),
                ),
                pw.SizedBox(width: 16),
                pw.Expanded(
                  flex: 2,
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.blueGrey50,
                      borderRadius: pw.BorderRadius.circular(6),
                      border: pw.Border.all(color: PdfColors.blueGrey200),
                    ),
                    child: pw.Column(
                      children: [
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('Subtotal:', style: const pw.TextStyle(fontSize: 9)),
                            pw.Text(Formatters.formatCurrency(orcamento.valorTotal), style: const pw.TextStyle(fontSize: 9)),
                          ],
                        ),
                        pw.Divider(color: PdfColors.grey300),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(
                              'TOTAL GERAL:',
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
                            ),
                            pw.Text(
                              Formatters.formatCurrency(orcamento.valorTotal),
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 12,
                                color: PdfColors.blueGrey900,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 32),

            // Campos de Assinatura
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                pw.Column(
                  children: [
                    pw.Container(width: 180, height: 1, color: PdfColors.black),
                    pw.SizedBox(height: 4),
                    pw.Text('MARMORARIA & GRANITOS', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8)),
                    pw.Text('Responsável Técnico', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                  ],
                ),
                pw.Column(
                  children: [
                    pw.Container(width: 180, height: 1, color: PdfColors.black),
                    pw.SizedBox(height: 4),
                    pw.Text(cliente.nome.toUpperCase(), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8)),
                    pw.Text('Cliente / Comprador', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                  ],
                ),
              ],
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

  static pw.Widget _tableCell(String text, {bool isHeader = false, pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
          fontSize: isHeader ? 8 : 8,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isHeader ? PdfColors.blueGrey900 : PdfColors.black,
        ),
      ),
    );
  }
}
