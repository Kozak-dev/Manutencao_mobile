import 'package:manutencao_mobile/screens/ocorrencias/new_occurrence_models.dart';

enum ServiceOrderStatus { open, inProgress, completed }

/// Tipos de manutenção definidos no PIM (TipoManutencao).
enum MaintenanceType {
  corrective('Corretiva'),
  preventive('Preventiva');

  const MaintenanceType(this.label);

  final String label;
}

enum ServiceOrderFilter {
  open('Abertas', ServiceOrderStatus.open),
  inProgress('Em atendimento', ServiceOrderStatus.inProgress),
  completed('Concluídas', ServiceOrderStatus.completed);

  const ServiceOrderFilter(this.label, this.status);

  final String label;
  final ServiceOrderStatus status;
}

/// Dados de uma ordem de serviço, usados na lista e nos detalhes.
///
/// [technicianName] é nulo enquanto nenhum técnico assumiu a OS (o PIM
/// permite OS sem técnico). [occurrenceId] e [occurrencePriority] referem-se
/// à ocorrência relacionada, quando houver.
class ServiceOrderListItem {
  const ServiceOrderListItem({
    required this.id,
    required this.equipmentName,
    required this.maintenanceType,
    required this.status,
    required this.createdAt,
    this.technicianName,
    this.occurrenceId,
    this.occurrencePriority,
  });

  final int id;
  final String equipmentName;
  final MaintenanceType maintenanceType;
  final ServiceOrderStatus status;
  final DateTime createdAt;
  final String? technicianName;
  final int? occurrenceId;
  final OccurrencePriority? occurrencePriority;

  /// Código exibido, por exemplo "OS-0017".
  String get code => 'OS-${id.toString().padLeft(4, '0')}';

  factory ServiceOrderListItem.fromJson(Map<String, dynamic> json) {
    ServiceOrderStatus statusEnum = ServiceOrderStatus.open;
    final statusStr = (json['status'] ?? '').toString().toLowerCase();
    if (statusStr.contains('atendimento') || statusStr.contains('andamento') || statusStr == '1') {
      statusEnum = ServiceOrderStatus.inProgress;
    } else if (statusStr.contains('conclu') || statusStr.contains('finaliz') || statusStr == '2') {
      statusEnum = ServiceOrderStatus.completed;
    }

    MaintenanceType typeEnum = MaintenanceType.corrective;
    final typeStr = (json['tipoManutencao'] ?? json['tipo'] ?? '').toString().toLowerCase();
    if (typeStr.contains('preventiva') || typeStr == '1') {
      typeEnum = MaintenanceType.preventive;
    }

    OccurrencePriority? prioEnum;
    if (json['occurrencePriority'] != null || json['ocorrenciaPrioridade'] != null) {
      final pStr = (json['occurrencePriority'] ?? json['ocorrenciaPrioridade']).toString().toLowerCase();
      if (pStr.contains('alta')) prioEnum = OccurrencePriority.high;
      if (pStr.contains('media') || pStr.contains('média')) prioEnum = OccurrencePriority.medium;
      if (pStr.contains('baixa')) prioEnum = OccurrencePriority.low;
    }

    String eqName = 'Equipamento';
    if (json['equipamentoNome'] != null) {
      eqName = json['equipamentoNome'].toString();
    } else if (json['equipamento'] is Map && json['equipamento']['nome'] != null) {
      eqName = json['equipamento']['nome'].toString();
    }

    String? techName = json['tecnicoNome'];
    if (techName == null && json['tecnico'] is Map && json['tecnico']['nome'] != null) {
      techName = json['tecnico']['nome'].toString();
    }

    return ServiceOrderListItem(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '1') ?? 1,
      equipmentName: eqName,
      maintenanceType: typeEnum,
      status: statusEnum,
      createdAt: json['dataAbertura'] != null || json['dataCriacao'] != null
          ? DateTime.tryParse((json['dataAbertura'] ?? json['dataCriacao']).toString()) ?? DateTime.now()
          : DateTime.now(),
      technicianName: techName,
      occurrenceId: json['ocorrenciaId'] is int
          ? json['ocorrenciaId']
          : int.tryParse(json['ocorrenciaId']?.toString() ?? ''),
      occurrencePriority: prioEnum,
    );
  }
}

/// Formata a data como "07/09/2026, 10:22".
String formatServiceOrderDate(DateTime date) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(date.day)}/${two(date.month)}/${date.year}, '
      '${two(date.hour)}:${two(date.minute)}';
}

// ---------------------------------------------------------------------------
// DADOS SIMULADOS (apenas para demonstração do protótipo).
// Substituir pelas OS reais quando a API estiver disponível.
// ---------------------------------------------------------------------------
final demoServiceOrders = [
  ServiceOrderListItem(
    id: 17,
    equipmentName: 'Prensa 02',
    maintenanceType: MaintenanceType.corrective,
    status: ServiceOrderStatus.open,
    createdAt: DateTime(2026, 9, 7, 10, 22),
    occurrenceId: 123,
    occurrencePriority: OccurrencePriority.high,
  ),
  ServiceOrderListItem(
    id: 18,
    equipmentName: 'Compressor 01',
    maintenanceType: MaintenanceType.corrective,
    status: ServiceOrderStatus.inProgress,
    createdAt: DateTime(2026, 9, 7, 10, 3),
    technicianName: 'João Lima',
    occurrenceId: 124,
    occurrencePriority: OccurrencePriority.medium,
  ),
  ServiceOrderListItem(
    id: 19,
    equipmentName: 'Torno CNC',
    maintenanceType: MaintenanceType.preventive,
    status: ServiceOrderStatus.inProgress,
    createdAt: DateTime(2026, 9, 7, 11, 47),
    technicianName: 'Carlos Lima',
  ),
  ServiceOrderListItem(
    id: 20,
    equipmentName: 'Esteira 01',
    maintenanceType: MaintenanceType.corrective,
    status: ServiceOrderStatus.inProgress,
    createdAt: DateTime(2026, 9, 7, 13, 26),
    technicianName: 'João Lima',
    occurrenceId: 125,
    occurrencePriority: OccurrencePriority.low,
  ),
];