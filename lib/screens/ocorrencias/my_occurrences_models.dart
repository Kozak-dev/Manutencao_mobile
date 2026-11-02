import 'new_occurrence_models.dart';

enum OccurrenceItemStatus { open, inProgress, resolved }

/// Situação do equipamento exibida na lista (estados definidos no PIM).
enum EquipmentCondition {
  running('Funcionando'),
  underMaintenance('Em manutenção'),
  stopped('Parado');

  const EquipmentCondition(this.label);

  final String label;
}

enum OccurrenceFilter {
  all('Todas'),
  open('Abertas'),
  inProgress('Em andamento'),
  resolved('Resolvidas');

  const OccurrenceFilter(this.label);

  final String label;
}

/// Dados de uma ocorrência exibida na lista e na tela de detalhes.
///
/// [reporterName] e [description] são opcionais porque a lista pode não
/// trazê-los; a tela de detalhes mostra um texto padrão quando faltam.
class OccurrenceListItem {
  const OccurrenceListItem({
    required this.id,
    required this.equipmentName,
    required this.equipmentCondition,
    required this.priority,
    required this.status,
    required this.createdAt,
    this.reporterName,
    this.description,
  });

  final int id;
  final String equipmentName;
  final EquipmentCondition equipmentCondition;
  final OccurrencePriority priority;
  final OccurrenceItemStatus status;
  final DateTime createdAt;

  /// Nome do usuário que registrou a ocorrência.
  final String? reporterName;
  final String? description;

  factory OccurrenceListItem.fromJson(Map<String, dynamic> json) {
    OccurrencePriority priorityEnum = OccurrencePriority.medium;
    final prioStr = (json['prioridade'] ?? '').toString().toLowerCase();
    if (prioStr.contains('alta') || prioStr == '2') {
      priorityEnum = OccurrencePriority.high;
    } else if (prioStr.contains('baixa') || prioStr == '0') {
      priorityEnum = OccurrencePriority.low;
    }

    OccurrenceItemStatus statusEnum = OccurrenceItemStatus.open;
    final statusStr = (json['status'] ?? '').toString().toLowerCase();
    if (statusStr.contains('atendimento') || statusStr.contains('andamento') || statusStr == '1') {
      statusEnum = OccurrenceItemStatus.inProgress;
    } else if (statusStr.contains('resolv') || statusStr.contains('conclu') || statusStr == '2') {
      statusEnum = OccurrenceItemStatus.resolved;
    }

    EquipmentCondition conditionEnum = EquipmentCondition.stopped;
    final condStr = (json['equipamentoStatus'] ?? json['statusEquipamento'] ?? '').toString().toLowerCase();
    if (condStr.contains('funcio') || condStr.contains('opera')) {
      conditionEnum = EquipmentCondition.running;
    } else if (condStr.contains('manuten')) {
      conditionEnum = EquipmentCondition.underMaintenance;
    }

    String eqName = 'Equipamento #${json['equipamentoId'] ?? ''}';
    if (json['equipamentoNome'] != null) {
      eqName = json['equipamentoNome'].toString();
    } else if (json['equipamento'] is Map && json['equipamento']['nome'] != null) {
      eqName = json['equipamento']['nome'].toString();
    }

    String? userRep = json['usuarioNome'];
    if (userRep == null && json['usuario'] is Map && json['usuario']['nome'] != null) {
      userRep = json['usuario']['nome'].toString();
    }

    return OccurrenceListItem(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '1') ?? 1,
      equipmentName: eqName,
      equipmentCondition: conditionEnum,
      priority: priorityEnum,
      status: statusEnum,
      createdAt: json['dataRegistro'] != null
          ? DateTime.tryParse(json['dataRegistro'].toString()) ?? DateTime.now()
          : DateTime.now(),
      reporterName: userRep,
      description: json['descricao'],
    );
  }
}

// ---------------------------------------------------------------------------
// DADOS SIMULADOS (apenas para demonstração do protótipo).
// Substituir pelas ocorrências reais quando a API estiver disponível.
// ---------------------------------------------------------------------------
List<OccurrenceListItem> buildDemoOccurrences(DateTime now) {
  return [
    OccurrenceListItem(
      id: 4,
      equipmentName: 'Prensa 02',
      equipmentCondition: EquipmentCondition.stopped,
      priority: OccurrencePriority.high,
      status: OccurrenceItemStatus.open,
      createdAt: DateTime(now.year, now.month, now.day, 8, 15),
      reporterName: 'Carlos',
      description: 'Ruído estranho durante o funcionamento e perda de força',
    ),
    OccurrenceListItem(
      id: 3,
      equipmentName: 'Compressor 01',
      equipmentCondition: EquipmentCondition.stopped,
      priority: OccurrencePriority.medium,
      status: OccurrenceItemStatus.inProgress,
      createdAt: DateTime(now.year, now.month, now.day - 1, 16, 30),
      reporterName: 'Ana',
      description: 'Vazamento de óleo na base do compressor',
    ),
    OccurrenceListItem(
      id: 2,
      equipmentName: 'Torno CVN',
      equipmentCondition: EquipmentCondition.underMaintenance,
      priority: OccurrencePriority.low,
      status: OccurrenceItemStatus.inProgress,
      createdAt: DateTime(2026, 9, 6, 10, 22),
      reporterName: 'Carlos',
      description: 'Vibração excessiva durante a usinagem',
    ),
    OccurrenceListItem(
      id: 1,
      equipmentName: 'Esteira 01',
      equipmentCondition: EquipmentCondition.running,
      priority: OccurrencePriority.low,
      status: OccurrenceItemStatus.resolved,
      createdAt: DateTime(2026, 9, 5, 14, 30),
      reporterName: 'Ana',
      description: 'Correia travando em baixa velocidade',
    ),
  ];
}