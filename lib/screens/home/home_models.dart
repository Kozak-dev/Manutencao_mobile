/// Quantidade de equipamentos por situação.
class EquipmentStatusSummary {
  const EquipmentStatusSummary({
    required this.running,
    required this.underMaintenance,
    required this.stopped,
  });

  final int running;
  final int underMaintenance;
  final int stopped;
}

enum OccurrenceStatus { open, inProgress }

/// Resumo de uma ocorrência exibida na lista da tela inicial.
class OccurrenceSummary {
  const OccurrenceSummary({
    required this.equipmentName,
    required this.status,
  });

  final String equipmentName;
  final OccurrenceStatus status;
}
