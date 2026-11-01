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

// ---------------------------------------------------------------------------
// DADOS SIMULADOS (apenas para demonstração do protótipo).
// Substituir pelos dados reais quando a API estiver disponível.
// ---------------------------------------------------------------------------
const demoEquipmentSummary = EquipmentStatusSummary(
  running: 12,
  underMaintenance: 3,
  stopped: 2,
);

const demoOccurrences = [
  OccurrenceSummary(equipmentName: 'Prensa 02', status: OccurrenceStatus.open),
  OccurrenceSummary(
    equipmentName: 'Compressor 01',
    status: OccurrenceStatus.inProgress,
  ),
];