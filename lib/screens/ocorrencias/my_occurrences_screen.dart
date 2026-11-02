import 'package:flutter/material.dart';
import '../../services/ocorrencia_service.dart';
import '../../widgets/app_bottom_navigation_bar.dart';
import 'my_occurrences_models.dart';
import 'occurrence_details_screen.dart';

/// Lista de ocorrências do usuário integrada à API C#.
class MyOccurrencesScreen extends StatefulWidget {
  const MyOccurrencesScreen({super.key, this.occurrences});

  final List<OccurrenceListItem>? occurrences;

  @override
  State<MyOccurrencesScreen> createState() => _MyOccurrencesScreenState();
}

class _MyOccurrencesScreenState extends State<MyOccurrencesScreen> {
  static const _navy = Color(0xFF122B4B);

  OccurrenceFilter _filter = OccurrenceFilter.all;
  List<OccurrenceListItem> _items = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadOccurrences();
  }

  Future<void> _loadOccurrences() async {
    if (widget.occurrences != null) {
      setState(() {
        _items = widget.occurrences!;
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final list = await OcorrenciaService.getMinhasOcorrencias();
      if (mounted) {
        setState(() {
          _items = list;
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

  List<OccurrenceListItem> get _visibleItems {
    return _items.where(_matchesFilter).toList();
  }

  bool _matchesFilter(OccurrenceListItem item) => switch (_filter) {
        OccurrenceFilter.all => true,
        OccurrenceFilter.open => item.status == OccurrenceItemStatus.open,
        OccurrenceFilter.inProgress =>
          item.status == OccurrenceItemStatus.inProgress,
        OccurrenceFilter.resolved =>
          item.status == OccurrenceItemStatus.resolved,
      };

  void _openDetails(OccurrenceListItem item) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => OccurrenceDetailsScreen(occurrence: item),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visibleItems;

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
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Navigator.pushReplacementNamed(context, '/home');
            }
          },
        ),
        title: const Text(
          'Minhas Ocorrências',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            icon: const Icon(Icons.refresh),
            onPressed: _loadOccurrences,
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
                _buildFilters(),
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
                                      onPressed: _loadOccurrences,
                                      icon: const Icon(Icons.refresh),
                                      label: const Text('Tentar novamente'),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : visible.isEmpty
                              ? const Center(
                                  child: Text(
                                    'Nenhuma ocorrência encontrada.',
                                    style: TextStyle(fontSize: 13),
                                  ),
                                )
                              : ListView.separated(
                                  padding: const EdgeInsets.fromLTRB(
                                      16, 8, 16, 16),
                                  itemCount: visible.length,
                                  separatorBuilder: (context, index) =>
                                      const SizedBox(height: 16),
                                  itemBuilder: (context, index) {
                                    final item = visible[index];
                                    return _OccurrenceCard(
                                      key: ValueKey('occurrence-${item.id}'),
                                      item: item,
                                      onTap: () => _openDetails(item),
                                    );
                                  },
                                ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 1),
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          for (final filter in OccurrenceFilter.values)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(filter.label),
                selected: _filter == filter,
                showCheckmark: false,
                backgroundColor: const Color(0xFFE0E0E0),
                selectedColor: _navy,
                side: BorderSide.none,
                shape: const StadiumBorder(),
                labelStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: _filter == filter ? Colors.white : Colors.black,
                ),
                onSelected: (_) => setState(() => _filter = filter),
              ),
            ),
        ],
      ),
    );
  }
}

/// Formata a data para a lista.
@visibleForTesting
String formatOccurrenceDate(DateTime date, DateTime now) {
  final time = '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  final day = DateTime(date.year, date.month, date.day);

  if (day == DateTime(now.year, now.month, now.day)) return 'Hoje, $time';
  if (day == DateTime(now.year, now.month, now.day - 1)) return 'Ontem, $time';

  final dd = date.day.toString().padLeft(2, '0');
  final mm = date.month.toString().padLeft(2, '0');
  return '$dd/$mm, $time';
}

class _OccurrenceCard extends StatelessWidget {
  const _OccurrenceCard({super.key, required this.item, required this.onTap});

  final OccurrenceListItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
                        _StatusBadge(status: item.status),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${item.equipmentCondition.label} - ${item.priority.label} prioridade',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right,
                          size: 20,
                          color: Colors.black54,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        formatOccurrenceDate(item.createdAt, DateTime.now()),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF616161),
                        ),
                      ),
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

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final OccurrenceItemStatus status;

  @override
  Widget build(BuildContext context) {
    final (String label, Color border, Color background, Color text) =
        switch (status) {
      OccurrenceItemStatus.open => (
          'Aberta',
          const Color(0xFFF5304F),
          const Color(0xFFFFEBEE),
          const Color(0xFFE53950),
        ),
      OccurrenceItemStatus.inProgress => (
          'Em atendimento',
          const Color(0xFFFFA000),
          const Color(0xFFFFF4DC),
          const Color(0xFFE08600),
        ),
      OccurrenceItemStatus.resolved => (
          'Resolvida',
          const Color(0xFF2EB872),
          const Color(0xFFE5F8EE),
          const Color(0xFF1E9A5A),
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
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: text,
        ),
      ),
    );
  }
}
