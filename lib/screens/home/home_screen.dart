import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'home_models.dart';

/// Tela inicial do aplicativo com atalhos adaptados por perfil do usuário.
class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    this.userName,
    this.statusSummary = demoEquipmentSummary,
    this.occurrences = demoOccurrences,
  });

  final String? userName;
  final EquipmentStatusSummary statusSummary;
  final List<OccurrenceSummary> occurrences;

  static const _blue = Color(0xFF2F6BFF);
  static const _green = Color(0xFF2DB783);
  static const _orange = Color(0xFFFFA726);
  static const _purple = Color(0xFF6C4DDB);
  static const _red = Color(0xFFF5304F);
  static const _yellow = Color(0xFFFFB927);

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;
    final displayName = userName ?? user?.nome ?? 'Usuário';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SizedBox(
              width: double.infinity,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Olá $displayName!',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user != null ? 'Função: ${user.funcao}' : 'Bem vindo ao sistema',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF616161)),
                    ),
                    const SizedBox(height: 20),
                    _buildQuickAccess(context),
                    const SizedBox(height: 20),
                    _buildEquipmentStatus(),
                    const SizedBox(height: 20),
                    _buildOccurrences(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: _blue,
        unselectedItemColor: Colors.black87,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        onTap: (index) {
          if (index == 0) return;
          if (index == 1) Navigator.pushNamed(context, '/ocorrencias');
          if (index == 2) Navigator.pushNamed(context, '/minhas-os');
          if (index == 3) Navigator.pushNamed(context, '/historico');
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Ocorrência',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            label: 'OS',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz),
            label: 'Mais',
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccess(BuildContext context) {
    final user = AuthService.currentUser;
    final isTecnico = user?.isTecnico ?? false;

    Widget tile(IconData icon, Color color, Color background, String label, String route) {
      return Expanded(
        child: _QuickAccessTile(
          icon: icon,
          color: color,
          background: background,
          label: label,
          onTap: () {
            if (route.isNotEmpty) {
              Navigator.pushNamed(context, route);
            } else {
              _showUnavailable(context, label);
            }
          },
        ),
      );
    }

    if (isTecnico) {
      return _SectionCard(
        title: 'Acessos Rápidos — Técnico',
        child: Column(
          children: [
            Row(
              children: [
                tile(
                  Icons.warning_amber_rounded,
                  _blue,
                  const Color(0xFFF0FAFF),
                  'Registrar Ocorrência',
                  '/nova-ocorrencia',
                ),
                const SizedBox(width: 12),
                tile(
                  Icons.assignment_late_outlined,
                  _green,
                  const Color(0xFFEEF9F3),
                  'OS Disponíveis',
                  '/os-disponiveis',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                tile(
                  Icons.precision_manufacturing_outlined,
                  _orange,
                  const Color(0xFFFFF7E8),
                  'Equipamentos',
                  '/equipamentos',
                ),
                const SizedBox(width: 12),
                tile(
                  Icons.person_outline,
                  _purple,
                  const Color(0xFFF1F1FA),
                  'Perfil',
                  '/perfil',
                ),
              ],
            ),
          ],
        ),
      );
    }

    // Menu do Operador
    return _SectionCard(
      title: 'Acessos Rápidos — Operador',
      child: Column(
        children: [
          Row(
            children: [
              tile(
                Icons.warning_amber_rounded,
                _blue,
                const Color(0xFFF0FAFF),
                'Registrar Ocorrência',
                '/nova-ocorrencia',
              ),
              const SizedBox(width: 12),
              tile(
                Icons.build_outlined,
                _green,
                const Color(0xFFEEF9F3),
                'Minhas Ocorrências',
                '/ocorrencias',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              tile(
                Icons.precision_manufacturing_outlined,
                _orange,
                const Color(0xFFFFF7E8),
                'Equipamentos',
                '/equipamentos',
              ),
              const SizedBox(width: 12),
              tile(
                Icons.person_outline,
                _purple,
                const Color(0xFFF1F1FA),
                'Perfil',
                '/perfil',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEquipmentStatus() {
    const divider = VerticalDivider(
      width: 1,
      thickness: 1,
      color: Color(0xFFE0E0E0),
    );

    return _SectionCard(
      title: 'Status equipamento',
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _StatusItem(
                color: const Color(0xFF2EC27E),
                count: statusSummary.running,
                label: 'Funcionando',
              ),
            ),
            divider,
            Expanded(
              child: _StatusItem(
                color: _yellow,
                count: statusSummary.underMaintenance,
                label: 'Em manutenção',
              ),
            ),
            divider,
            Expanded(
              child: _StatusItem(
                color: _red,
                count: statusSummary.stopped,
                label: 'Parado',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOccurrences(BuildContext context) {
    return _SectionCard(
      color: const Color(0xFFF7F8FC),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Minhas Ocorrências',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/ocorrencias'),
                style: TextButton.styleFrom(
                  foregroundColor: _blue,
                  minimumSize: const Size(48, 48),
                ),
                child: const Text(
                  'Ver todas',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const Divider(height: 1, color: Colors.black54),
          if (occurrences.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'Nenhuma ocorrência no momento.',
                style: TextStyle(fontSize: 13),
              ),
            )
          else
            for (var i = 0; i < occurrences.length; i++) ...[
              if (i > 0) const Divider(height: 1, color: Colors.black54),
              _OccurrenceRow(
                occurrence: occurrences[i],
                onTap: () => Navigator.pushNamed(context, '/ocorrencias'),
              ),
            ],
        ],
      ),
    );
  }

  static void _showUnavailable(BuildContext context, String destination) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('"$destination" ainda não está disponível.')),
      );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.child,
    this.title,
    this.color = Colors.white,
  });

  final Widget child;
  final String? title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 14),
          ],
          child,
        ],
      ),
    );
  }
}

class _QuickAccessTile extends StatelessWidget {
  const _QuickAccessTile({
    required this.icon,
    required this.color,
    required this.background,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final Color background;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      elevation: 2,
      shadowColor: Colors.black38,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 72),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: Colors.white),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusItem extends StatelessWidget {
  const _StatusItem({
    required this.color,
    required this.count,
    required this.label,
  });

  final Color color;
  final int count;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(
                '$count',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(width: 3, height: 20, color: color),
              const SizedBox(width: 8),
              Flexible(
                child: Text(label, style: const TextStyle(fontSize: 10)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OccurrenceRow extends StatelessWidget {
  const _OccurrenceRow({required this.occurrence, required this.onTap});

  final OccurrenceSummary occurrence;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isOpen = occurrence.status == OccurrenceStatus.open;
    final dotColor = isOpen ? HomeScreen._red : HomeScreen._yellow;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                occurrence.equipmentName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            _StatusBadge(status: occurrence.status),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final OccurrenceStatus status;

  @override
  Widget build(BuildContext context) {
    final isOpen = status == OccurrenceStatus.open;
    final text = isOpen ? 'Aberto' : 'Em andamento';
    final border = isOpen ? HomeScreen._red : const Color(0xFFFFA000);
    final background =
        isOpen ? const Color(0xFFFFEBEE) : const Color(0xFFFFF4DC);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isOpen ? HomeScreen._red : const Color(0xFFE08600),
        ),
      ),
    );
  }
}
