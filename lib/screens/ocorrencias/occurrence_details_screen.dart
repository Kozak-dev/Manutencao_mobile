import 'package:flutter/material.dart';

import 'my_occurrences_models.dart';
import 'new_occurrence_models.dart';

/// Tela de detalhes de uma ocorrência, aberta a partir de "Minhas Ocorrências".
///
/// Sem [occurrence], usa dados simulados. O PIM atribui ao Administrador a
/// criação da OS, por isso o botão pode ser ocultado com
/// [canCreateServiceOrder]. Ele só aparece com a ocorrência Aberta (uma OS
/// por ocorrência).
class OccurrenceDetailsScreen extends StatelessWidget {
  const OccurrenceDetailsScreen({
    super.key,
    this.occurrence,
    this.canCreateServiceOrder = true,
    this.onCreateServiceOrder,
  });

  final OccurrenceListItem? occurrence;
  final bool canCreateServiceOrder;
  final VoidCallback? onCreateServiceOrder;

  static const _navy = Color(0xFF122B4B);
  static const _blue = Color(0xFF2979FF);

  @override
  Widget build(BuildContext context) {
    final details =
        occurrence ?? buildDemoOccurrences(DateTime.now()).first;
    final showCreateButton =
        canCreateServiceOrder && details.status == OccurrenceItemStatus.open;

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
          'Detalhes da Ocorrência',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _DetailsCard(details: details),
                  if (showCreateButton) ...[
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton(
                        onPressed: onCreateServiceOrder ??
                                () => _showUnavailable(
                              context,
                              'Criar ordem de serviço',
                            ),
                        style: FilledButton.styleFrom(
                          backgroundColor: _blue,
                          foregroundColor: Colors.white,
                          elevation: 3,
                          shadowColor: Colors.black45,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        child: const Text('Criar ordem de serviço'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
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

/// Formata a data como "07/09/2026 - 08:15".
@visibleForTesting
String formatOccurrenceDetailsDate(DateTime date) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(date.day)}/${two(date.month)}/${date.year} - '
      '${two(date.hour)}:${two(date.minute)}';
}

class _DetailsCard extends StatelessWidget {
  const _DetailsCard({required this.details});

  final OccurrenceListItem details;

  Color get _priorityColor => switch (details.priority) {
    OccurrencePriority.low => const Color(0xFF2EC27E),
    OccurrencePriority.medium => const Color(0xFFFFB927),
    OccurrencePriority.high => const Color(0xFFF5304F),
  };

  @override
  Widget build(BuildContext context) {
    const divider = Divider(height: 1, color: Colors.black26);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                    Text(
                      details.equipmentName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(width: 3, height: 16, color: _priorityColor),
                        const SizedBox(width: 6),
                        Text(
                          '${details.priority.label} prioridade',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _Badge.status(details.status),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 20),
              const SizedBox(width: 8),
              Text(
                formatOccurrenceDetailsDate(details.createdAt),
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.person_outline, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  details.reporterName ?? 'Não informado',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          divider,
          const SizedBox(height: 14),
          const Text(
            'Detalhes do problema',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            details.description ?? 'Descrição não informada.',
            style: const TextStyle(fontSize: 12, color: Color(0xFF424242)),
          ),
          const SizedBox(height: 14),
          divider,
          const SizedBox(height: 14),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Status do equipamento',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
              ),
              _Badge.condition(details.equipmentCondition),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

/// Etiqueta colorida com borda, usada para o status da ocorrência e do
/// equipamento.
class _Badge extends StatelessWidget {
  const _Badge._({
    required this.label,
    required this.border,
    required this.background,
    required this.text,
  });

  factory _Badge.status(OccurrenceItemStatus status) {
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
    return _Badge._(
      label: label,
      border: border,
      background: background,
      text: text,
    );
  }

  factory _Badge.condition(EquipmentCondition condition) {
    final (Color border, Color background, Color text) = switch (condition) {
      EquipmentCondition.stopped => (
      const Color(0xFFF5304F),
      const Color(0xFFFFEBEE),
      const Color(0xFFE53950),
      ),
      EquipmentCondition.underMaintenance => (
      const Color(0xFFFFA000),
      const Color(0xFFFFF4DC),
      const Color(0xFFE08600),
      ),
      EquipmentCondition.running => (
      const Color(0xFF2EB872),
      const Color(0xFFE5F8EE),
      const Color(0xFF1E9A5A),
      ),
    };
    return _Badge._(
      label: condition.label,
      border: border,
      background: background,
      text: text,
    );
  }

  final String label;
  final Color border;
  final Color background;
  final Color text;

  @override
  Widget build(BuildContext context) {
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