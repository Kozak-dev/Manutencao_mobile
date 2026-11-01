import 'package:flutter/material.dart';
import 'package:manutencao_mobile/screens/ocorrencias/new_occurrence_models.dart';
import '../../services/ordem_servico_service.dart';

import 'my_service_orders_models.dart';
import 'perform_maintenance_screen.dart';

/// Tela de detalhes de uma OS, aberta a partir de "Minhas Ordens de Serviços".
///
/// Sem [serviceOrder], usa dados simulados. O botão "Assumir OS" aparece em
/// todas as OS, mas só fica habilitado quando a OS está Aberta, sem técnico e
/// [canAssumeServiceOrder] é verdadeiro (o PIM permite assumir somente ao
/// Técnico). Ao assumir, abre a tela "Realizar Manutenção". Para ocultar o
/// botão nas demais OS, troque `_AssumeButton` por `if (canAssume)` em [build].
class ServiceOrderDetailsScreen extends StatelessWidget {
  const ServiceOrderDetailsScreen({
    super.key,
    this.serviceOrder,
    this.canAssumeServiceOrder = true,
    this.onAssumeServiceOrder,
  });

  final ServiceOrderListItem? serviceOrder;
  final bool canAssumeServiceOrder;
  final VoidCallback? onAssumeServiceOrder;

  static const _navy = Color(0xFF122B4B);

  @override
  Widget build(BuildContext context) {
    final order = serviceOrder ?? demoServiceOrders.first;
    final canAssume = canAssumeServiceOrder &&
        order.status == ServiceOrderStatus.open &&
        order.technicianName == null;

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
          'Detalhes da OS',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _SummaryCard(order: order),
                  const SizedBox(height: 16),
                  _AssumeButton(
                    enabled: canAssume,
                    onPressed: onAssumeServiceOrder ??
                            () => _openMaintenance(context, order),
                  ),
                  const SizedBox(height: 16),
                  _HistoryCard(order: order),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Future<void> _openMaintenance(
    BuildContext context,
    ServiceOrderListItem order,
  ) async {
    try {
      await OrdemServicoService.assumirOrdemServico(order.id);
    } catch (_) {}
    if (!context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PerformMaintenanceScreen(serviceOrder: order),
      ),
    );
  }
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(10),
    boxShadow: const [
      BoxShadow(
        color: Color(0x33000000),
        blurRadius: 8,
        offset: Offset(0, 2),
      ),
    ],
  );
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.order});

  final ServiceOrderListItem order;

  @override
  Widget build(BuildContext context) {
    const divider = Divider(height: 1, color: Colors.black26);
    const sectionTitle = TextStyle(fontSize: 12, fontWeight: FontWeight.w700);
    const sectionValue = TextStyle(fontSize: 11);

    final occurrenceId = order.occurrenceId;
    final occurrenceText = occurrenceId == null
        ? 'Não informada'
        : '#${occurrenceId.toString().padLeft(4, '0')} - ${order.equipmentName}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  order.code,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              _StatusBadge(status: order.status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            order.equipmentName,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(order.maintenanceType.label, style: sectionValue),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.event_outlined, size: 22),
              const SizedBox(width: 8),
              Text(
                formatServiceOrderDate(order.createdAt),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF616161),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          divider,
          const SizedBox(height: 12),
          const Text('Ocorrência relacionada', style: sectionTitle),
          const SizedBox(height: 4),
          Text(occurrenceText, style: sectionValue),
          if (order.occurrencePriority != null) ...[
            const SizedBox(height: 8),
            _PriorityChip(priority: order.occurrencePriority!),
          ],
          const SizedBox(height: 14),
          divider,
          const SizedBox(height: 12),
          const Text('Técnico responsável', style: sectionTitle),
          const SizedBox(height: 4),
          Text(order.technicianName ?? 'Não definido', style: sectionValue),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class _AssumeButton extends StatelessWidget {
  const _AssumeButton({required this.enabled, required this.onPressed});

  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton(
            onPressed: enabled ? onPressed : null,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF2979FF),
              disabledBackgroundColor: const Color(0xFFA9C4FA),
              foregroundColor: Colors.white,
              disabledForegroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            child: const Text('Assumir OS'),
          ),
        ),
        if (!enabled)
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Text(
              'Somente OS abertas e sem técnico podem ser assumidas.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Color(0xFF616161)),
            ),
          ),
      ],
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.order});

  final ServiceOrderListItem order;

  /// Etapas montadas a partir do status (o PIM não tem histórico de OS).
  List<_TimelineEntry> _buildEntries() {
    final created = _TimelineEntry(
      title: 'OS criada',
      subtitle: formatServiceOrderDate(order.createdAt),
      color: const Color(0xFF2979FF),
    );

    const currentColor = Color(0xFF2B5FA8);
    final _TimelineEntry current = switch (order.status) {
      ServiceOrderStatus.open => _TimelineEntry(
        title: order.technicianName == null
            ? 'Aguardando técnico'
            : 'Aguardando início',
        color: currentColor,
        pending: true,
      ),
      ServiceOrderStatus.inProgress => const _TimelineEntry(
        title: 'Em atendimento',
        color: currentColor,
      ),
      ServiceOrderStatus.completed => const _TimelineEntry(
        title: 'Concluída',
        color: currentColor,
      ),
    };

    return [created, current];
  }

  @override
  Widget build(BuildContext context) {
    final entries = _buildEntries();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Histórico',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < entries.length; i++)
            _TimelineRow(entry: entries[i], isLast: i == entries.length - 1),
        ],
      ),
    );
  }
}

class _TimelineEntry {
  const _TimelineEntry({
    required this.title,
    required this.color,
    this.subtitle,
    this.pending = false,
  });

  final String title;
  final String? subtitle;
  final Color color;

  /// Etapa ainda não concluída (texto em cinza).
  final bool pending;
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.entry, required this.isLast});

  final _TimelineEntry entry;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 16,
            child: Column(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: entry.color,
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(width: 2, color: const Color(0xFFBDBDBD)),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                      entry.pending ? FontWeight.w500 : FontWeight.w600,
                      color: entry.pending
                          ? const Color(0xFF757575)
                          : Colors.black,
                    ),
                  ),
                  if (entry.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      entry.subtitle!,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF616161),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
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

/// Chip com a prioridade da ocorrência relacionada.
class _PriorityChip extends StatelessWidget {
  const _PriorityChip({required this.priority});

  final OccurrencePriority priority;

  @override
  Widget build(BuildContext context) {
    final (Color border, Color background, Color text) = switch (priority) {
      OccurrencePriority.high => (
      const Color(0xFFF5304F),
      const Color(0xFFFFEBEE),
      const Color(0xFFE53950),
      ),
      OccurrencePriority.medium => (
      const Color(0xFFFFA000),
      const Color(0xFFFFF4DC),
      const Color(0xFFE08600),
      ),
      OccurrencePriority.low => (
      const Color(0xFF2EB872),
      const Color(0xFFE5F8EE),
      const Color(0xFF1E9A5A),
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.priority_high, size: 14, color: text),
          const SizedBox(width: 4),
          Text(
            '${priority.label} prioridade',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: text,
            ),
          ),
        ],
      ),
    );
  }
}