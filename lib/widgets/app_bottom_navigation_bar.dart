import 'package:flutter/material.dart';

/// Barra de navegação inferior profissional reutilizável em todas as telas principais.
class AppBottomNavigationBar extends StatelessWidget {
  const AppBottomNavigationBar({
    super.key,
    required this.currentIndex,
  });

  final int currentIndex;

  static const _navy = Color(0xFF122B4B);
  static const _blue = Color(0xFF2979FF);

  static const List<({String label, IconData icon, IconData activeIcon, String route})> _items = [
    (
      label: 'Início',
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      route: '/home',
    ),
    (
      label: 'Ocorrências',
      icon: Icons.warning_amber_rounded,
      activeIcon: Icons.warning_rounded,
      route: '/ocorrencias',
    ),
    (
      label: 'OS',
      icon: Icons.assignment_outlined,
      activeIcon: Icons.assignment_rounded,
      route: '/minhas-os',
    ),
    (
      label: 'Histórico',
      icon: Icons.history_outlined,
      activeIcon: Icons.history_rounded,
      route: '/historico',
    ),
  ];

  void _onTap(BuildContext context, int index) {
    if (index == currentIndex) return;

    final targetRoute = _items[index].route;
    Navigator.pushReplacementNamed(context, targetRoute);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: NavigationBarTheme(
        data: NavigationBarThemeData(
          height: 64,
          backgroundColor: Colors.white,
          indicatorColor: _blue.withValues(alpha: 0.12),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final isSelected = states.contains(WidgetState.selected);
            return TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? _navy : const Color(0xFF757575),
            );
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            final isSelected = states.contains(WidgetState.selected);
            return IconThemeData(
              size: 24,
              color: isSelected ? _blue : const Color(0xFF757575),
            );
          }),
        ),
        child: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: (index) => _onTap(context, index),
          elevation: 0,
          destinations: [
            for (final item in _items)
              NavigationDestination(
                icon: Icon(item.icon),
                selectedIcon: Icon(item.activeIcon),
                label: item.label,
              ),
          ],
        ),
      ),
    );
  }
}
