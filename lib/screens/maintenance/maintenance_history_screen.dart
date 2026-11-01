import 'package:flutter/material.dart';

import 'maintenance_history_models.dart';

/// Histórico de manutenções, com filtro por equipamento.
///
/// A API ainda não existe: sem [items] e [equipments], usa dados simulados.
/// O filtro é apenas de exibição.
class MaintenanceHistoryScreen extends StatefulWidget {
  const MaintenanceHistoryScreen({super.key, this.items, this.equipments});

  final List<MaintenanceHistoryItem>? items;
  final List<HistoryEquipmentOption>? equipments;

  @override
  State<MaintenanceHistoryScreen> createState() =>
      _MaintenanceHistoryScreenState();
}

class _MaintenanceHistoryScreenState extends State<MaintenanceHistoryScreen> {
  static const _navy = Color(0xFF122B4B);
  static const _blue = Color(0xFF2F6BFF);

  /// Nulo = "Todos os equipamentos".
  int? _equipmentId;

  List<MaintenanceHistoryItem> get _visibleItems {
    final all = widget.items ?? demoMaintenanceHistory;
    final id = _equipmentId;
    if (id == null) return all;
    return all.where((item) => item.equipmentId == id).toList();
  }

  void _showUnavailable(String destination) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('"$destination" ainda não está disponível.')),
      );
  }

  @override
  Widget build(BuildContext context) {
    final items = _visibleItems;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: _navy,
        foregroundColor: Colors.white,
        titleSpacing: 0,
        centerTitle: false,
        leading: IconButton(
          tooltip: 'Voltar',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Histórico de Manutenção',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: _buildEquipmentFilter(),
                ),
                Expanded(
                  child: items.isEmpty
                      ? const Center(
                    child: Text(
                      'Nenhuma manutenção encontrada.',
                      style: TextStyle(fontSize: 13),
                    ),
                  )
                      : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: items.length,
                    separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _MaintenanceCard(
                        key: ValueKey('maintenance-${item.id}'),
                        item: item,
                        onTap: () => _showUnavailable(item.equipmentName),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: _blue,
        unselectedItemColor: Colors.black87,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/ocorrencias');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/minhas-os');
              break;
            case 3:
              break;
          }
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

  Widget _buildEquipmentFilter() {
    final equipments = widget.equipments ?? demoHistoryEquipments;

    return Semantics(
      label: 'Filtrar por equipamento',
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFBDBDBD)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<int?>(
            value: _equipmentId,
            isExpanded: true,
            borderRadius: BorderRadius.circular(10),
            icon: const Icon(Icons.keyboard_arrow_down),
            style: const TextStyle(fontSize: 14, color: Color(0xFF424242)),
            items: [
              const DropdownMenuItem<int?>(
                value: null,
                child: Text('Todos os equipamentos'),
              ),
              for (final equipment in equipments)
                DropdownMenuItem<int?>(
                  value: equipment.id,
                  child: Text(equipment.name),
                ),
            ],
            onChanged: (id) => setState(() => _equipmentId = id),
          ),
        ),
      ),
    );
  }
}

/// Formata a data como "10/09/2026".
@visibleForTesting
String formatMaintenanceDate(DateTime date) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(date.day)}/${two(date.month)}/${date.year}';
}

class _MaintenanceCard extends StatelessWidget {
  const _MaintenanceCard({super.key, required this.item, required this.onTap});

  final MaintenanceHistoryItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const detailStyle = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: Color(0xFF616161),
    );

    return Material(
      color: Colors.white,
      elevation: 3,
      shadowColor: Colors.black45,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Color(0xFFE0E0E0),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.precision_manufacturing_outlined),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.equipmentName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        _TypeBadge(type: item.maintenanceType),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(item.serviceDescription, style: detailStyle),
                    const SizedBox(height: 2),
                    Text('Técnico: ${item.technicianName}', style: detailStyle),
                    const SizedBox(height: 2),
                    Text(
                      formatMaintenanceDate(item.completedAt),
                      style: detailStyle,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.type});

  final MaintenanceHistoryType type;

  @override
  Widget build(BuildContext context) {
    final (Color border, Color background, Color text) = switch (type) {
      MaintenanceHistoryType.preventive => (
      const Color(0xFF2EB872),
      const Color(0xFFE5F8EE),
      const Color(0xFF1E9A5A),
      ),
      MaintenanceHistoryType.corrective => (
      const Color(0xFF3B82F6),
      const Color(0xFFE8F0FF),
      const Color(0xFF2F6BFF),
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        type.label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: text,
        ),
      ),
    );
  }
}