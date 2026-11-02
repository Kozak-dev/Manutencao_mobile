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

/// Dados que o aplicativo envia à API ao registrar uma ocorrência.
class NewOccurrenceData {
  const NewOccurrenceData({
    required this.equipmentId,
    required this.description,
    required this.priority,
    this.imagePath,
  });

  final int equipmentId;
  final String description;
  final OccurrencePriority priority;
  final String? imagePath;
}
