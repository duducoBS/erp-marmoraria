import 'package:flutter_test/flutter_test.dart';
import 'package:erp_marmoraria/models/orcamento_item_model.dart';
import 'package:erp_marmoraria/models/material_model.dart';
import 'package:erp_marmoraria/models/cliente_model.dart';

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
  });
}
