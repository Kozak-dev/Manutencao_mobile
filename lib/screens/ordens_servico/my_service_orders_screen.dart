import 'package:flutter/material.dart';
import '../../services/ordem_servico_service.dart';
import '../../widgets/app_bottom_navigation_bar.dart';
import 'my_service_orders_models.dart';
import 'service_order_details_screen.dart';

/// Lista de ordens de serviço integrada ao backend C#.
class MyServiceOrdersScreen extends StatefulWidget {
  const MyServiceOrdersScreen({
    super.key,
    this.serviceOrders,
    this.apenasDisponiveis = false,
  });

  final List<ServiceOrderListItem>? serviceOrders;
  final bool apenasDisponiveis;

  @override
  State<MyServiceOrdersScreen> createState() => _MyServiceOrdersScreenState();
}

class _MyServiceOrdersScreenState extends State<MyServiceOrdersScreen> {
  static const _navy = Color(0xFF122B4B);

  ServiceOrderFilter? _filter;
  List<ServiceOrderListItem> _orders = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadServiceOrders();
  }

  Future<void> _loadServiceOrders() async {
    if (widget.serviceOrders != null) {
      setState(() {
        _orders = widget.serviceOrders!;
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final list = await OrdemServicoService.getOrdensServico(
        apenasDisponiveis: widget.apenasDisponiveis,
      );
      if (mounted) {
        setState(() {
          _orders = list;
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

  List<ServiceOrderListItem> get _visibleItems {
    final filter = _filter;
    if (filter == null) return _orders;
    return _orders.where((item) => item.status == filter.status).toList();
  }

  void _openDetails(ServiceOrderListItem item) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ServiceOrderDetailsScreen(serviceOrder: item),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _visibleItems;
    final title = widget.apenasDisponiveis ? 'OS Disponíveis' : 'Minhas Ordens de Serviços';

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
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            icon: const Icon(Icons.refresh),
            onPressed: _loadServiceOrders,
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
                                      onPressed: _loadServiceOrders,
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
                                    'Nenhuma ordem de serviço encontrada.',
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
                                    return _ServiceOrderCard(
                                      key: ValueKey('service-order-${item.id}'),
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
      bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 2),
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          for (final filter in ServiceOrderFilter.values)
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
                onSelected: (_) => setState(
                  () => _filter = _filter == filter ? null : filter,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ServiceOrderCard extends StatelessWidget {
  const _ServiceOrderCard({super.key, required this.item, required this.onTap});

  final ServiceOrderListItem item;
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
                child: const Icon(Icons.assignment_outlined),
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
                            item.code,
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
                    Text(
                      item.equipmentName,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.maintenanceType.label,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        formatServiceOrderDate(item.createdAt),
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

  final ServiceOrderStatus status;

  @override
  Widget build(BuildContext context) {
    final (String label, Color border, Color background, Color text) =
        switch (status) {
      ServiceOrderStatus.open => (
          'Aberta',
          const Color(0xFFF5304F),
          const Color(0xFFFFEBEE),
          const Color(0xFFE53950),
        ),
      ServiceOrderStatus.inProgress => (
          'Em atendimento',
          const Color(0xFFFFA000),
          const Color(0xFFFFF4DC),
          const Color(0xFFE08600),
        ),
      ServiceOrderStatus.completed => (
          'Concluída',
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
