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
      if (ApiClient.authToken?.startsWith('mock_') == true) {
        return;
      }
      rethrow;
    }
  }

  static Future<List<OccurrenceListItem>> getMinhasOcorrencias() async {
    try {
      final response = await ApiClient.get('/ocorrencias');
      if (response != null && response is List) {
        return response
            .map((item) => OccurrenceListItem.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      if (ApiClient.authToken?.startsWith('mock_') == true) {
        return buildDemoOccurrences(DateTime.now());
      }
      rethrow;
    }
  }

  static Future<OccurrenceListItem> getOcorrenciaById(int id) async {
    try {
      final response = await ApiClient.get('/ocorrencias/$id');
      if (response != null && response is Map<String, dynamic>) {
        return OccurrenceListItem.fromJson(response);
      }
    } catch (e) {
      if (ApiClient.authToken?.startsWith('mock_') == true) {
        return buildDemoOccurrences(DateTime.now()).firstWhere((o) => o.id == id, orElse: () => buildDemoOccurrences(DateTime.now()).first);
      }
      rethrow;
    }
    throw ApiException('Ocorrência #$id não encontrada.');
  }
}
