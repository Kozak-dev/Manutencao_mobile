import 'package:flutter_test/flutter_test.dart';
import 'package:manutencao_mobile/models/usuario/usuario.dart';
import 'package:manutencao_mobile/models/equipamento/equipamento.dart';
import 'package:manutencao_mobile/services/api_client.dart';
import 'package:manutencao_mobile/services/auth_service.dart';
import 'package:manutencao_mobile/services/equipamento_service.dart';
import 'package:manutencao_mobile/services/ocorrencia_service.dart';
import 'package:manutencao_mobile/services/ordem_servico_service.dart';
import 'package:manutencao_mobile/screens/ocorrencias/new_occurrence_models.dart';

void main() {
  setUp(() {
    ApiClient.authToken = 'mock_test_token';
  });

  group('Usuario Model & Roles', () {
    test('Identifica papel de Operador corretamente', () {
      final user = Usuario(
        id: 1,
        nome: 'Operador Teste',
        email: 'operador@empresa.com',
        perfil: 'Funcionario',
        funcao: 'Operador',
        ativo: true,
      );

      expect(user.isOperador, isTrue);
      expect(user.isTecnico, isFalse);
      expect(user.isAdmin, isFalse);
    });

    test('Identifica papel de Técnico corretamente', () {
      final user = Usuario(
        id: 2,
        nome: 'Tecnico Teste',
        email: 'tecnico@empresa.com',
        perfil: 'Funcionario',
        funcao: 'Tecnico',
        ativo: true,
      );

      expect(user.isOperador, isFalse);
      expect(user.isTecnico, isTrue);
      expect(user.isAdmin, isFalse);
    });
  });

  group('AuthService', () {
    test('Realiza login e salva usuario logado', () async {
      final user = await AuthService.login('operador@empresa.com', '123456');

      expect(user.email, equals('operador@empresa.com'));
      expect(user.isOperador, isTrue);
      expect(AuthService.currentUser, equals(user));

      AuthService.logout();
      expect(AuthService.currentUser, null);
    });
  });

  group('EquipamentoService', () {
    test('Retorna lista de equipamentos', () async {
      final list = await EquipamentoService.getEquipamentos();
      expect(list, isNotEmpty);
      expect(list.first, isA<Equipamento>());
    });

    test('Retorna equipamento por ID', () async {
      final eq = await EquipamentoService.getEquipamentoById(1);
      expect(eq, isNotNull);
      expect(eq.id, equals(1));
    });
  });

  group('OcorrenciaService', () {
    test('Retorna ocorrencias cadastradas', () async {
      final list = await OcorrenciaService.getMinhasOcorrencias();
      expect(list, isNotEmpty);
    });

    test('Registra nova ocorrencia sem erros', () async {
      final data = NewOccurrenceData(
        equipmentId: 1,
        description: 'Vazamento de óleo identificado',
        priority: OccurrencePriority.high,
      );

      await expectLater(
        OcorrenciaService.registrarOcorrencia(data),
        completes,
      );
    });
  });

  group('OrdemServicoService', () {
    test('Retorna lista de OS e suporta filtro de disponiveis', () async {
      final all = await OrdemServicoService.getOrdensServico(apenasDisponiveis: false);
      final disponiveis = await OrdemServicoService.getOrdensServico(apenasDisponiveis: true);

      expect(all, isNotEmpty);
      expect(disponiveis.every((os) => os.technicianName == null), isTrue);
    });
  });
}
