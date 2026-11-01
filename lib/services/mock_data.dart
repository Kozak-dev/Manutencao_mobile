
import '../models/usuario/usuario.dart';
import '../models/equipamento/equipamento.dart';

final usuarioMock = Usuario(
  id: 1,
  nome: 'João da Silva',
  email: 'joao@empresa.com',
  perfil: 'Funcionario',
  funcao: 'Tecnico',
  ativo: true,
);

final equipamentoMock = Equipamento(
  id: 1,
  nome: 'Prensa Hidráulica',
  patrimonio: 'PAT-001',
  fabricante: 'Fabricante Teste',
  modelo: 'PH-100',
  numeroSerie: 'SN-001',
  dataAquisicao: DateTime(2024, 1, 15),
  status: 'Operando',
  setorId: 1,
  ativo: true,
);

final equipamentosMock = [
  equipamentoMock,
  Equipamento(
    id: 2,
    nome: 'Esteira Industrial',
    patrimonio: 'PAT-002',
    fabricante: 'Fabricante Teste',
    modelo: 'EI-200',
    numeroSerie: 'SN-002',
    dataAquisicao: DateTime(2023, 6, 10),
    status: 'Parado',
    setorId: 1,
    ativo: true,
  ),
];
