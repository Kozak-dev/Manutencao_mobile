enum OccurrencePriority {
  low('Baixa'),
  medium('Média'),
  high('Alta');

  const OccurrencePriority(this.label);

  final String label;
}

/// Equipamento exibido no dropdown.
class EquipmentOption {
  const EquipmentOption({required this.id, required this.name});

  final int id;
  final String name;
}

/// Dados que o aplicativo envia à API ao registrar uma ocorrência
/// (conforme o PIM: equipamentoId, descricao e prioridade).
class NewOccurrenceData {
  const NewOccurrenceData({
    required this.equipmentId,
    required this.description,
    required this.priority,
  });

  final int equipmentId;
  final String description;
  final OccurrencePriority priority;
}

// ---------------------------------------------------------------------------
// DADOS SIMULADOS (apenas para demonstração do protótipo).
// Substituir pela lista real de equipamentos quando a API estiver disponível.
// ---------------------------------------------------------------------------
const demoEquipments = [
  EquipmentOption(id: 1, name: 'Prensa 01'),
  EquipmentOption(id: 2, name: 'Prensa 02'),
  EquipmentOption(id: 3, name: 'Compressor 01'),
];