import 'package:flutter_test/flutter_test.dart';
import 'package:erp_marmoraria/models/orcamento_model.dart';
import 'package:erp_marmoraria/models/orcamento_item_model.dart';
import 'package:erp_marmoraria/models/orcamento_parcela_model.dart';
import 'package:erp_marmoraria/models/empresa_config_model.dart';
import 'package:erp_marmoraria/models/material_model.dart';
import 'package:erp_marmoraria/models/cliente_model.dart';
import 'package:erp_marmoraria/core/utils/formatters.dart';

void main() {
  group('Cálculos da Marmoraria', () {
    test('Cálculo de m² com 10% de perda', () {
      // Bancada 0.60m x 2.00m = 1.20 m²
      // Com 10% de perda: 1.20 * 1.10 = 1.32 m²
      final m2 = OrcamentoItem.calcularM2Total(
        largura: 0.60,
        comprimento: 2.00,
        quantidade: 1,
        perdaPercentual: 10.0,
      );
      expect(m2, closeTo(1.32, 0.001));
    });

    test('Cálculo do valor parcial com acabamento linear (ex: 45 graus)', () {
      // 1.32 m² a R$ 580,00/m² = R$ 765,60
      // 2.00 metros de acabamento 45º a R$ 65,00/m = R$ 130,00
      // Total parcial = R$ 895,60
      final total = OrcamentoItem.calcularValorParcial(
        m2Total: 1.32,
        precoM2Venda: 580.0,
        acabamentoValorUnitario: 65.0,
        acabamentoQuantidade: 2.0,
      );
      expect(total, closeTo(895.60, 0.01));
    });

    test('Margem de lucro do material', () {
      final material = MaterialItem(
        nome: 'Preto São Gabriel',
        precoM2Custo: 320.0,
        precoM2Venda: 580.0,
      );
      // Lucro = 580 - 320 = 260. Margem = (260/320)*100 = 81.25%
      expect(material.margemLucro, closeTo(81.25, 0.01));
    });

    test('Instanciação e cópia do Cliente', () {
      final cliente = Cliente(
        nome: 'Construtora Teste',
        tipo: 'PJ',
        documento: '12.345.678/0001-90',
        telefone: '(11) 99999-9999',
      );
      final clienteEditado = cliente.copyWith(cidade: 'Campinas');
      expect(clienteEditado.cidade, equals('Campinas'));
      expect(clienteEditado.nome, equals('Construtora Teste'));
    });

    test('Formatters.parseDouble converte corretamente entradas BRL e numpad', () {
      expect(Formatters.parseDouble('0.60'), equals(0.60));
      expect(Formatters.parseDouble('0,60'), equals(0.60));
      expect(Formatters.parseDouble('2.00'), equals(2.00));
      expect(Formatters.parseDouble('2,00'), equals(2.00));
      expect(Formatters.parseDouble('1.250,50'), equals(1250.50));
      expect(Formatters.parseDouble('1,250.50'), equals(1250.50));
      expect(Formatters.parseDouble('R\$ 3.450,00'), equals(3450.00));
      expect(Formatters.parseDouble('10'), equals(10.0));
      expect(Formatters.parseDouble(''), equals(0.0));
    });

    test('Formatters de exibição no padrão BRL', () {
      expect(Formatters.formatCurrency(1250.50), contains('1.250,50'));
      expect(Formatters.formatCurrency(1250.50), contains(r'R$'));
      expect(Formatters.formatDecimal(0.60), equals('0,60'));
      expect(Formatters.formatDecimal(2.00), equals('2,00'));
      expect(Formatters.formatM2(1.32), equals('1,32 m²'));
      expect(Formatters.formatMeters(3.20), equals('3,20 m'));
    });

    test('Somatório correto de múltiplos itens de orçamento', () {
      final item1 = OrcamentoItem(
        ambiente: 'Cozinha',
        materialId: 1,
        largura: Formatters.parseDouble('0,60'),
        comprimento: Formatters.parseDouble('3,20'),
        quantidade: 1,
        perdaPercentual: 10.0,
        m2Total: OrcamentoItem.calcularM2Total(largura: 0.60, comprimento: 3.20, quantidade: 1, perdaPercentual: 10.0),
        valorParcial: OrcamentoItem.calcularValorParcial(
          m2Total: OrcamentoItem.calcularM2Total(largura: 0.60, comprimento: 3.20, quantidade: 1, perdaPercentual: 10.0),
          precoM2Venda: 550.0,
          acabamentoValorUnitario: 60.0,
          acabamentoQuantidade: 3.20,
        ),
      );

      final item2 = OrcamentoItem(
        ambiente: 'Ilha',
        materialId: 1,
        largura: Formatters.parseDouble('0.90'),
        comprimento: Formatters.parseDouble('2.00'),
        quantidade: 1,
        perdaPercentual: 10.0,
        m2Total: OrcamentoItem.calcularM2Total(largura: 0.90, comprimento: 2.00, quantidade: 1, perdaPercentual: 10.0),
        valorParcial: OrcamentoItem.calcularValorParcial(
          m2Total: OrcamentoItem.calcularM2Total(largura: 0.90, comprimento: 2.00, quantidade: 1, perdaPercentual: 10.0),
          precoM2Venda: 550.0,
          acabamentoValorUnitario: 60.0,
          acabamentoQuantidade: 4.00,
        ),
      );

      expect(item1.valorParcial, equals(1353.60));
      expect(item2.valorParcial, equals(1329.00));

      final somatorio = item1.valorParcial + item2.valorParcial;
      expect(somatorio, equals(2682.60));
      expect(Formatters.formatCurrency(somatorio), contains('2.682,60'));
    });

    test('Cálculo com inserção livre do valor do m²', () {
      // Bancada 0.60m x 2.00m = 1.20 m² -> Com 10% perda = 1.32 m²
      // Usuário digita livremente R$ 450,00/m² (em vez de preço padrão)
      final m2 = OrcamentoItem.calcularM2Total(
        largura: 0.60,
        comprimento: 2.00,
        quantidade: 1,
        perdaPercentual: 10.0,
      );
      final total = OrcamentoItem.calcularValorParcial(
        tipoCalculo: 'metro',
        m2Total: m2,
        precoM2Venda: 450.0, // preço livre
        acabamentoValorUnitario: 50.0,
        acabamentoQuantidade: 2.0,
      );
      // 1.32 * 450 = 594.00 + (2.0 * 50 = 100.00) = 694.00
      expect(total, equals(694.00));
    });

    test('Cálculo de item com Valor Fixo por peça', () {
      // Peça fechada com valor fixo de R$ 1.200,00
      final totalFixo = OrcamentoItem.calcularValorParcial(
        tipoCalculo: 'fixo',
        m2Total: 0.8,
        precoM2Venda: 0.0,
        valorFixo: 1200.00,
        acabamentoValorUnitario: 80.0,
        acabamentoQuantidade: 1.0,
      );
      // 1200.00 + 80.00 = 1280.00
      expect(totalFixo, equals(1280.00));
    });

    test('Somatório de orçamento misto (m² livre + valor fixo)', () {
      final itemM2 = OrcamentoItem(
        ambiente: 'Cozinha',
        materialId: 1,
        largura: 0.60,
        comprimento: 2.00,
        quantidade: 1,
        perdaPercentual: 10.0,
        m2Total: 1.32,
        tipoCalculo: 'metro',
        precoMetro: 500.0,
        valorParcial: 660.00, // 1.32 * 500
      );

      final itemFixo = OrcamentoItem(
        ambiente: 'Nicho Banheiro',
        materialId: 2,
        largura: 0.30,
        comprimento: 0.60,
        quantidade: 1,
        perdaPercentual: 10.0,
        m2Total: 0.198,
        tipoCalculo: 'fixo',
        valorFixo: 350.00,
        valorParcial: 350.00,
      );

      final totalOrcamento = itemM2.valorParcial + itemFixo.valorParcial;
      expect(totalOrcamento, equals(1010.00));
      expect(Formatters.formatCurrency(totalOrcamento), contains('1.010,00'));
    });

    test('OrcamentoItem suporta campo de descrição detalhada', () {
      final item = OrcamentoItem(
        ambiente: 'Bancada Cozinha',
        materialId: 1,
        largura: 0.60,
        comprimento: 2.50,
        quantidade: 1,
        m2Total: 1.65,
        valorParcial: 1200.00,
        descricao: 'Bancada em L com cuba esculpida e frontão de 15cm',
      );

      expect(item.descricao, equals('Bancada em L com cuba esculpida e frontão de 15cm'));

      final map = item.toMap();
      expect(map['descricao'], equals('Bancada em L com cuba esculpida e frontão de 15cm'));

      final fromMap = OrcamentoItem.fromMap(map);
      expect(fromMap.descricao, equals('Bancada em L com cuba esculpida e frontão de 15cm'));

      final modificado = item.copyWith(descricao: 'Alterado para furo de torneira duplo');
      expect(modificado.descricao, equals('Alterado para furo de torneira duplo'));
    });

    test('OrcamentoParcela e EmpresaConfig suportam serialização completa', () {
      final parcela = OrcamentoParcela(numero: 1, valor: 650.0, vencimento: '2026-10-18');
      expect(parcela.numero, equals(1));
      expect(parcela.valor, equals(650.0));
      expect(parcela.vencimento, equals('2026-10-18'));

      final pMap = parcela.toMap();
      final pFromMap = OrcamentoParcela.fromMap(pMap);
      expect(pFromMap.numero, equals(1));
      expect(pFromMap.valor, equals(650.0));

      final config = EmpresaConfig(
        nome: 'EDU MÁRMORES',
        cnpj: '26.106.792/0001-77',
        fone1: '(11) 94031-1110',
        resp1: 'Edu',
        dadosBancarios: 'PIX: 148.374.878-23',
      );
      expect(config.nome, equals('EDU MÁRMORES'));
      final cMap = config.toMap();
      final cFromMap = EmpresaConfig.fromMap(cMap);
      expect(cFromMap.cnpj, equals('26.106.792/0001-77'));
      expect(cFromMap.fone1, equals('(11) 94031-1110'));
    });

    test('Orcamento suporta condicaoPagamento, dadosBancarios e parcelas', () {
      final parcelas = [
        OrcamentoParcela(numero: 1, valor: 500.0, vencimento: '2026-10-18'),
        OrcamentoParcela(numero: 2, valor: 500.0, vencimento: '2026-11-18'),
      ];

      final orcamento = Orcamento(
        clienteId: 1,
        dataCriacao: '2026-09-22',
        dataValidade: '2026-10-07',
        valorTotal: 1000.0,
        condicaoPagamento: 'Entrada 50% e saldo 30 dias',
        dadosBancarios: 'PIX: 148.374.878-23',
        parcelas: parcelas,
      );

      expect(orcamento.condicaoPagamento, equals('Entrada 50% e saldo 30 dias'));
      expect(orcamento.dadosBancarios, equals('PIX: 148.374.878-23'));
      expect(orcamento.parcelas.length, equals(2));

      final map = orcamento.toMap();
      final fromMap = Orcamento.fromMap(map);
      expect(fromMap.condicaoPagamento, equals('Entrada 50% e saldo 30 dias'));
      expect(fromMap.dadosBancarios, equals('PIX: 148.374.878-23'));
      expect(fromMap.parcelas.length, equals(2));
      expect(fromMap.parcelas[0].valor, equals(500.0));
      expect(fromMap.parcelas[1].vencimento, equals('2026-11-18'));
    });
  });
}
