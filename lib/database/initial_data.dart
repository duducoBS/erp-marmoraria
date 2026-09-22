import '../models/material_model.dart';
import '../models/acabamento_model.dart';
import '../models/cliente_model.dart';

class InitialData {
  static List<MaterialItem> get defaultMaterials => [
    MaterialItem(
      nome: 'Granito Preto São Gabriel',
      tipo: 'Granito',
      precoM2Custo: 320.0,
      precoM2Venda: 580.0,
      espessura: '2cm',
    ),
    MaterialItem(
      nome: 'Branco Prime (Sintético)',
      tipo: 'Super Nano',
      precoM2Custo: 450.0,
      precoM2Venda: 790.0,
      espessura: '2cm',
    ),
    MaterialItem(
      nome: 'Mármore Travertino Nacional (Bege Bahia)',
      tipo: 'Mármore',
      precoM2Custo: 260.0,
      precoM2Venda: 480.0,
      espessura: '2cm',
    ),
    MaterialItem(
      nome: 'Quartzo Branco Stellar',
      tipo: 'Quartzo',
      precoM2Custo: 680.0,
      precoM2Venda: 1150.0,
      espessura: '2cm',
    ),
    MaterialItem(
      nome: 'Granito Branco Itaúnas',
      tipo: 'Granito',
      precoM2Custo: 210.0,
      precoM2Venda: 390.0,
      espessura: '2cm',
    ),
    MaterialItem(
      nome: 'Granito Verde Ubatuba',
      tipo: 'Granito',
      precoM2Custo: 190.0,
      precoM2Venda: 350.0,
      espessura: '2cm',
    ),
    MaterialItem(
      nome: 'Mármore Branco Carrara',
      tipo: 'Mármore',
      precoM2Custo: 950.0,
      precoM2Venda: 1650.0,
      espessura: '2cm',
    ),
    MaterialItem(
      nome: 'Granito Cinza Corumbá',
      tipo: 'Granito',
      precoM2Custo: 170.0,
      precoM2Venda: 310.0,
      espessura: '2cm',
    ),
  ];

  static List<AcabamentoServico> get defaultAcabamentos => [
    // Acabamentos de Bordas Tradicionais (Padrão Marmoraria)
    AcabamentoServico(
      nome: '01 - Reto (2,0 cm)',
      tipoCobranca: 'metro_linear',
      valor: 25.0,
    ),
    AcabamentoServico(
      nome: '02 - Chanfrado (2,0 cm)',
      tipoCobranca: 'metro_linear',
      valor: 30.0,
    ),
    AcabamentoServico(
      nome: '03 - Meia Cana (2,0 cm)',
      tipoCobranca: 'metro_linear',
      valor: 35.0,
    ),
    AcabamentoServico(
      nome: '04 - Boleado (2,0 cm)',
      tipoCobranca: 'metro_linear',
      valor: 40.0,
    ),
    AcabamentoServico(
      nome: '05 - Peito de Pombo (2,0 cm)',
      tipoCobranca: 'metro_linear',
      valor: 50.0,
    ),
    AcabamentoServico(
      nome: '06 - Reto Engrossado (4,0 cm)',
      tipoCobranca: 'metro_linear',
      valor: 55.0,
    ),
    AcabamentoServico(
      nome: '07 - 1/2 Cana Engrossado (4,0 cm)',
      tipoCobranca: 'metro_linear',
      valor: 60.0,
    ),
    AcabamentoServico(
      nome: '08 - Chanfrado Simples Engrossado (4,0 cm)',
      tipoCobranca: 'metro_linear',
      valor: 60.0,
    ),
    AcabamentoServico(
      nome: '09 - Boleado Duplo Engrossado (4,0 cm)',
      tipoCobranca: 'metro_linear',
      valor: 65.0,
    ),
    AcabamentoServico(
      nome: '10 - 45º com Saia (6,0 cm+)',
      tipoCobranca: 'metro_linear',
      valor: 75.0,
    ),
    AcabamentoServico(
      nome: '11 - Outros Desenhos Moldurados',
      tipoCobranca: 'metro_linear',
      valor: 80.0,
    ),
    // Serviços Complementares de Marmoraria
    AcabamentoServico(
      nome: 'Furo para Cuba Embutida / Sobrepor',
      tipoCobranca: 'unidade',
      valor: 80.0,
    ),
    AcabamentoServico(
      nome: 'Furo para Cooktop',
      tipoCobranca: 'unidade',
      valor: 70.0,
    ),
    AcabamentoServico(
      nome: 'Furo para Torneira / Dosador',
      tipoCobranca: 'unidade',
      valor: 35.0,
    ),
    AcabamentoServico(
      nome: 'Cuba Esculpida com Válvula Oculta',
      tipoCobranca: 'unidade',
      valor: 450.0,
    ),
    AcabamentoServico(
      nome: 'Instalação e Frete Técnico',
      tipoCobranca: 'fixo',
      valor: 250.0,
    ),
  ];

  static List<Cliente> get defaultClientes => [
    Cliente(
      nome: 'Construtora Horizonte Ltda',
      tipo: 'PJ',
      documento: '28.192.481/0001-90',
      telefone: '(11) 98765-4321',
      email: 'contato@horizonte.com.br',
      endereco: 'Av. Paulista, 1000, Sala 12',
      bairro: 'Bela Vista',
      cidade: 'São Paulo',
      cep: '01310-100',
    ),
    Cliente(
      nome: 'Dra. Camila Vasconcelos',
      tipo: 'PF',
      documento: '321.654.987-12',
      telefone: '(11) 99123-8877',
      email: 'camila.vasconcelos@email.com',
      endereco: 'Rua das Palmeiras, 450 - Apto 102',
      bairro: 'Jardins',
      cidade: 'São Paulo',
      cep: '01420-001',
    ),
    Cliente(
      nome: 'Eng. Ricardo Silveira',
      tipo: 'PF',
      documento: '456.789.012-34',
      telefone: '(11) 97333-2211',
      email: 'ricardo.obras@gmail.com',
      endereco: 'Rua dos Pinheiros, 820',
      bairro: 'Pinheiros',
      cidade: 'São Paulo',
      cep: '05422-001',
    ),
  ];
}
