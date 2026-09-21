import 'package:flutter_test/flutter_test.dart';
import 'package:erp_marmoraria/models/orcamento_item_model.dart';
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
  });
}
