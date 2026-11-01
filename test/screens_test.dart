import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manutencao_mobile/models/usuario/usuario.dart';
import 'package:manutencao_mobile/screens/login/login_screen.dart';
import 'package:manutencao_mobile/screens/home/home_screen.dart';
import 'package:manutencao_mobile/screens/equipamentos/equipamentos_screen.dart';
import 'package:manutencao_mobile/screens/ordens_servico/perform_maintenance_screen.dart';
import 'package:manutencao_mobile/screens/ordens_servico/my_service_orders_models.dart';
import 'package:manutencao_mobile/services/auth_service.dart';

void main() {
  setUp(() {
    AuthService.logout();
  });

  testWidgets('LoginScreen valida campos obrigatorios', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LoginScreen(),
      ),
    );

    expect(find.text('Entrar'), findsOneWidget);

    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    expect(find.text('Informe seu e-mail ou usuário.'), findsOneWidget);
  });

  testWidgets('HomeScreen exibe atalhos adaptados para Operador', (WidgetTester tester) async {
    AuthService.currentUser = Usuario(
      id: 1,
      nome: 'Carlos Operador',
      email: 'operador@empresa.com',
      perfil: 'Funcionario',
      funcao: 'Operador',
      ativo: true,
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(),
      ),
    );

    expect(find.text('Acessos Rápidos — Operador'), findsOneWidget);
    expect(find.text('Registrar Ocorrência'), findsOneWidget);
    expect(find.text('Minhas Ocorrências'), findsWidgets);
  });

  testWidgets('HomeScreen exibe atalhos adaptados para Técnico', (WidgetTester tester) async {
    AuthService.currentUser = Usuario(
      id: 2,
      nome: 'João Técnico',
      email: 'tecnico@empresa.com',
      perfil: 'Funcionario',
      funcao: 'Tecnico',
      ativo: true,
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(),
      ),
    );

    expect(find.text('Acessos Rápidos — Técnico'), findsOneWidget);
    expect(find.text('Registrar Ocorrência'), findsOneWidget);
    expect(find.text('OS Disponíveis'), findsOneWidget);
  });

  testWidgets('EquipamentosScreen exibe lista e busca', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: EquipamentosScreen(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Equipamentos'), findsWidgets);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('PerformMaintenanceScreen valida selecao de problema resolvido', (WidgetTester tester) async {
    final os = demoServiceOrders.first;

    await tester.pumpWidget(
      MaterialApp(
        home: PerformMaintenanceScreen(serviceOrder: os),
      ),
    );

    expect(find.text('O problema foi resolvido?'), findsOneWidget);
    expect(find.text('SIM (Resolvido)'), findsOneWidget);
    expect(find.text('NÃO (Continua Parado)'), findsOneWidget);
  });
}
