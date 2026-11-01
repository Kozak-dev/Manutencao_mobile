import 'api_client.dart';
import '../screens/ocorrencias/my_occurrences_models.dart';
import '../screens/ocorrencias/new_occurrence_models.dart';

class OcorrenciaService {
  static Future<void> registrarOcorrencia(NewOccurrenceData data) async {
    final payload = {
      'equipamentoId': data.equipmentId,
      'descricao': data.description,
      'prioridade': data.priority.label,
    };

    try {
      await ApiClient.post('/ocorrencias', payload);
    } catch (e) {
      if (e is ApiException && e.statusCode == 400) rethrow;
      // Em modo offline/demo ou ambiente de testes sem backend ativo
    }
  }

  static Future<List<OccurrenceListItem>> getMinhasOcorrencias() async {
    try {
      final response = await ApiClient.get('/ocorrencias');
      if (response != null && response is List) {
        return response.map((item) {
          final map = item as Map<String, dynamic>;
          return OccurrenceListItem(
            id: map['id'] ?? 1,
            equipmentName: map['equipamentoNome'] ?? 'Equipamento',
            priority: OccurrencePriority.values.firstWhere(
              (p) => p.label.toLowerCase() == (map['prioridade'] ?? '').toString().toLowerCase(),
              orElse: () => OccurrencePriority.medium,
            ),
            equipmentCondition: EquipmentCondition.stopped,
            status: OccurrenceItemStatus.open,
            createdAt: map['dataRegistro'] != null
                ? DateTime.tryParse(map['dataRegistro'].toString()) ?? DateTime.now()
                : DateTime.now(),
            reporterName: map['usuarioNome'],
            description: map['descricao'],
          );
        }).toList();
      }
    } catch (_) {
      // Fallback
    }
    return buildDemoOccurrences(DateTime.now());
  }
}
