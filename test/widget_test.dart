import 'package:flutter_test/flutter_test.dart';
import 'package:manutencao_mobile/main.dart';

void main() {
  testWidgets('App starts and displays login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MeuAplicativo());

    expect(find.text('Sistema de\nManutenção'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
  });
}
