import 'package:flutter/material.dart';
import '../../models/equipamento/equipamento.dart';
import '../../services/equipamento_service.dart';
import '../../widgets/app_bottom_navigation_bar.dart';

class EquipamentosScreen extends StatefulWidget {
  const EquipamentosScreen({super.key, this.equipamentos});

  final List<Equipamento>? equipamentos;

  @override
  State<EquipamentosScreen> createState() => _EquipamentosScreenState();
}

class _EquipamentosScreenState extends State<EquipamentosScreen> {
  static const _navy = Color(0xFF122B4B);

  List<Equipamento> _list = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String? _statusFilter;

  @override
  void initState() {
    super.initState();
    _loadEquipamentos();
  }

  Future<void> _loadEquipamentos() async {
    if (widget.equipamentos != null) {
      setState(() {
        _list = widget.equipamentos!;
        _isLoading = false;
      });
      return;
    }

    try {
      final items = await EquipamentoService.getEquipamentos();
      if (mounted) {
        setState(() {
          _list = items;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Equipamento> get _filteredList {
    return _list.where((item) {
      final matchesQuery = _searchQuery.isEmpty ||
          item.nome.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.patrimonio.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.modelo.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesStatus = _statusFilter == null ||
          item.status.toLowerCase() == _statusFilter!.toLowerCase();

      return matchesQuery && matchesStatus;
    }).toList();
  }

  void _showDetails(Equipamento item) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.nome,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  _StatusBadge(status: item.status),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),
              _DetailRow(label: 'Patrimônio', value: item.patrimonio),
              _DetailRow(label: 'Fabricante', value: item.fabricante),
              _DetailRow(label: 'Modelo', value: item.modelo),
              _DetailRow(label: 'Número de Série', value: item.numeroSerie),
              _DetailRow(
                label: 'Data de Aquisição',
                value: '${item.dataAquisicao.day.toString().padLeft(2, '0')}/'
                    '${item.dataAquisicao.month.toString().padLeft(2, '0')}/'
                    '${item.dataAquisicao.year}',
              ),
              _DetailRow(label: 'Setor ID', value: '#${item.setorId}'),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  style: FilledButton.styleFrom(backgroundColor: _navy),
                  child: const Text('Fechar'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredList;

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
          'Equipamentos',
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
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: TextField(
                    onChanged: (value) => setState(() => _searchQuery = value),
                    decoration: InputDecoration(
                      hintText: 'Buscar por nome, patrimônio ou modelo...',
                      prefixIcon: const Icon(Icons.search),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                _buildStatusFilters(),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : filtered.isEmpty
                          ? const Center(
                              child: Text(
                                'Nenhum equipamento encontrado.',
                                style: TextStyle(fontSize: 13),
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                              itemCount: filtered.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final item = filtered[index];
                                return _EquipamentoCard(
                                  item: item,
                                  onTap: () => _showDetails(item),
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 0),
    );
  }

  Widget _buildStatusFilters() {
    const statuses = ['Funcionando', 'Em Manutenção', 'Parado'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Row(
        children: [
          ChoiceChip(
            label: const Text('Todos'),
            selected: _statusFilter == null,
            showCheckmark: false,
            backgroundColor: const Color(0xFFE0E0E0),
            selectedColor: _navy,
            labelStyle: TextStyle(
              fontSize: 12,
              color: _statusFilter == null ? Colors.white : Colors.black,
            ),
            onSelected: (_) => setState(() => _statusFilter = null),
          ),
          const SizedBox(width: 8),
          for (final st in statuses)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(st),
                selected: _statusFilter?.toLowerCase() == st.toLowerCase(),
                showCheckmark: false,
                backgroundColor: const Color(0xFFE0E0E0),
                selectedColor: _navy,
                labelStyle: TextStyle(
                  fontSize: 12,
                  color: _statusFilter?.toLowerCase() == st.toLowerCase()
                      ? Colors.white
                      : Colors.black,
                ),
                onSelected: (_) => setState(
                  () => _statusFilter =
                      _statusFilter?.toLowerCase() == st.toLowerCase()
                          ? null
                          : st,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _EquipamentoCard extends StatelessWidget {
  const _EquipamentoCard({required this.item, required this.onTap});

  final Equipamento item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black38,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
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
                    Text(
                      item.nome,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Patrimônio: ${item.patrimonio} | Modelo: ${item.modelo}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF616161),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _StatusBadge(status: item.status),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final stLower = status.toLowerCase();
    final (String label, Color border, Color background, Color text) =
        switch (stLower) {
      'funcionando' || 'operando' => (
          'Funcionando',
          const Color(0xFF2EB872),
          const Color(0xFFE5F8EE),
          const Color(0xFF1E9A5A),
        ),
      'em manutenção' || 'em manutencao' => (
          'Em manutenção',
          const Color(0xFFFFA000),
          const Color(0xFFFFF4DC),
          const Color(0xFFE08600),
        ),
      'parado' || 'parada' => (
          'Parado',
          const Color(0xFFF5304F),
          const Color(0xFFFFEBEE),
          const Color(0xFFE53950),
        ),
      _ => (
          status,
          const Color(0xFF9E9E9E),
          const Color(0xFFF5F5F5),
          const Color(0xFF616161),
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

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
