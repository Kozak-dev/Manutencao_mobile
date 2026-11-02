import 'package:flutter/material.dart';
import '../../services/equipamento_service.dart';
import '../../services/manutencao_service.dart';
import '../../widgets/app_bottom_navigation_bar.dart';
import 'maintenance_history_models.dart';

/// Histórico de manutenções integrado à API real C#.
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

  int? _equipmentId;
  List<MaintenanceHistoryItem> _historyItems = [];
  List<HistoryEquipmentOption> _equipmentOptions = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (widget.items != null && widget.equipments != null) {
      setState(() {
        _historyItems = widget.items!;
        _equipmentOptions = widget.equipments!;
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final history = await ManutencaoService.getHistorico();
      final eqList = await EquipamentoService.getEquipamentos();

      final eqOptions = eqList
          .map((eq) => HistoryEquipmentOption(id: eq.id, name: eq.nome))
          .toList();

      if (mounted) {
        setState(() {
          _historyItems = history;
          _equipmentOptions = eqOptions;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  List<MaintenanceHistoryItem> get _visibleItems {
    final id = _equipmentId;
    if (id == null) return _historyItems;
    return _historyItems.where((item) => item.equipmentId == id).toList();
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
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
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
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _errorMessage != null
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.error_outline,
                                        size: 48, color: Color(0xFFD32F2F)),
                                    const SizedBox(height: 12),
                                    Text(
                                      _errorMessage!,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton.icon(
                                      onPressed: _loadData,
                                      icon: const Icon(Icons.refresh),
                                      label: const Text('Tentar novamente'),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : items.isEmpty
                              ? const Center(
                                  child: Text(
                                    'Nenhuma manutenção registrada no histórico.',
                                    style: TextStyle(fontSize: 13),
                                  ),
                                )
                              : ListView.separated(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 8, 16, 16),
                                  itemCount: items.length,
                                  separatorBuilder: (context, index) =>
                                      const SizedBox(height: 16),
                                  itemBuilder: (context, index) {
                                    final item = items[index];
                                    return _MaintenanceCard(
                                      key: ValueKey('maintenance-${item.id}'),
                                      item: item,
                                    );
                                  },
                                ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 3),
    );
  }

  Widget _buildEquipmentFilter() {
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
              for (final equipment in _equipmentOptions)
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
  const _MaintenanceCard({super.key, required this.item});

  final MaintenanceHistoryItem item;

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
