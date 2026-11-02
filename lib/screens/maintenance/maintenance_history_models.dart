enum MaintenanceHistoryType {
  preventive('Preventiva'),
  corrective('Corretiva');

  const MaintenanceHistoryType(this.label);

  final String label;
}

/// Equipamento exibido no filtro do histórico.
class HistoryEquipmentOption {
  const HistoryEquipmentOption({required this.id, required this.name});

  final int id;
  final String name;
}

/// Manutenção concluída exibida no histórico.
///
/// [maintenanceType] e [technicianName] vêm da Ordem de Serviço relacionada
/// (OrdemServico 1:1 Manutencao, conforme o PIM).
class MaintenanceHistoryItem {
  const MaintenanceHistoryItem({
    required this.id,
    required this.equipmentId,
    required this.equipmentName,
    required this.maintenanceType,
    required this.serviceDescription,
    required this.technicianName,
    required this.completedAt,
  });

  final int id;
  final int equipmentId;
  final String equipmentName;
  final MaintenanceHistoryType maintenanceType;

  /// Corresponde ao campo ServicoRealizado.
  final String serviceDescription;
  final String technicianName;

  /// Corresponde ao campo DataConclusao.
  final DateTime completedAt;

  factory MaintenanceHistoryItem.fromJson(Map<String, dynamic> json) {
    MaintenanceHistoryType typeEnum = MaintenanceHistoryType.corrective;
    final typeStr = (json['tipoManutencao'] ?? json['tipo'] ?? '').toString().toLowerCase();
    if (typeStr.contains('preventiva') || typeStr == '1') {
      typeEnum = MaintenanceHistoryType.preventive;
    }

    String eqName = 'Equipamento';
    if (json['equipamentoNome'] != null) {
      eqName = json['equipamentoNome'].toString();
    } else if (json['equipamento'] is Map && json['equipamento']['nome'] != null) {
      eqName = json['equipamento']['nome'].toString();
    }

    String techName = 'Técnico';
    if (json['tecnicoNome'] != null) {
      techName = json['tecnicoNome'].toString();
    } else if (json['tecnico'] is Map && json['tecnico']['nome'] != null) {
      techName = json['tecnico']['nome'].toString();
    }

    return MaintenanceHistoryItem(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '1') ?? 1,
      equipmentId: json['equipamentoId'] is int
          ? json['equipamentoId']
          : int.tryParse(json['equipamentoId']?.toString() ?? '1') ?? 1,
      equipmentName: eqName,
      maintenanceType: typeEnum,
      serviceDescription: json['servicoRealizado'] ?? json['servicoDescricao'] ?? json['descricao'] ?? 'Manutenção realizada',
      technicianName: techName,
      completedAt: json['dataConclusao'] != null || json['completedAt'] != null
          ? DateTime.tryParse((json['dataConclusao'] ?? json['completedAt']).toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

// ---------------------------------------------------------------------------
// DADOS SIMULADOS (apenas para demonstração do protótipo).
// Substituir pelos dados reais quando a API estiver disponível.
// ---------------------------------------------------------------------------
const demoHistoryEquipments = [
  HistoryEquipmentOption(id: 1, name: 'Prensa 02'),
  HistoryEquipmentOption(id: 2, name: 'Compressor 01'),
  HistoryEquipmentOption(id: 3, name: 'Torno CVN'),
  HistoryEquipmentOption(id: 4, name: 'Esteira 01'),
];

final demoMaintenanceHistory = [
  MaintenanceHistoryItem(
    id: 1,
    equipmentId: 1,
    equipmentName: 'Prensa 02',
    maintenanceType: MaintenanceHistoryType.preventive,
    serviceDescription: 'Lubrificação geral',
    technicianName: 'João Lima',
    completedAt: DateTime(2026, 9, 10),
  ),
  MaintenanceHistoryItem(
    id: 2,
    equipmentId: 2,
    equipmentName: 'Compressor 01',
    maintenanceType: MaintenanceHistoryType.corrective,
    serviceDescription: 'Troca de óleo',
    technicianName: 'Carlos Lima',
    completedAt: DateTime(2026, 9, 20),
  ),
  MaintenanceHistoryItem(
    id: 3,
    equipmentId: 3,
    equipmentName: 'Torno CVN',
    maintenanceType: MaintenanceHistoryType.preventive,
    serviceDescription: 'Limpeza',
    technicianName: 'João Lima',
    completedAt: DateTime(2026, 9, 25),
  ),
  MaintenanceHistoryItem(
    id: 4,
    equipmentId: 4,
    equipmentName: 'Esteira 01',
    maintenanceType: MaintenanceHistoryType.corrective,
    serviceDescription: 'Revisão geral',
    technicianName: 'João Lima',
    completedAt: DateTime(2026, 9, 30),
  ),
];