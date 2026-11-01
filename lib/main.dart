import 'package:flutter/material.dart';

import 'screens/login/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/equipamentos/equipamentos_screen.dart';
import 'screens/ocorrencias/new_occurrence_screen.dart';
import 'screens/ocorrencias/my_occurrences_screen.dart';
import 'screens/ordens_servico/my_service_orders_screen.dart';
import 'screens/perfil/profile_screen.dart';
import 'screens/maintenance/maintenance_history_screen.dart';

void main() {
  runApp(const MeuAplicativo());
}

class MeuAplicativo extends StatelessWidget {
  const MeuAplicativo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sistema de Manutenção',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2979FF),
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/equipamentos': (context) => const EquipamentosScreen(),
        '/nova-ocorrencia': (context) => const NewOccurrenceScreen(),
        '/ocorrencias': (context) => const MyOccurrencesScreen(),
        '/minhas-os': (context) => const MyServiceOrdersScreen(apenasDisponiveis: false),
        '/os-disponiveis': (context) => const MyServiceOrdersScreen(apenasDisponiveis: true),
        '/perfil': (context) => const ProfileScreen(),
        '/historico': (context) => const MaintenanceHistoryScreen(),
      },
    );
  }
}
