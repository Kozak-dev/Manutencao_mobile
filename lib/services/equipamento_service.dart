import 'api_client.dart';
import '../models/equipamento/equipamento.dart';
import 'mock_data.dart';

class EquipamentoService {
  static Future<List<Equipamento>> getEquipamentos() async {
    try {
      final response = await ApiClient.get('/equipamentos');
      if (response != null && response is List) {
        return response
            .map((item) => Equipamento.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      // Fallback em caso de API indisponível
    }
    return equipamentosMock;
  }

  static Future<Equipamento?> getEquipamentoById(int id) async {
    try {
      final response = await ApiClient.get('/equipamentos/$id');
      if (response != null && response is Map<String, dynamic>) {
        return Equipamento.fromJson(response);
      }
    } catch (_) {
      // Fallback
    }
    return equipamentosMock.firstWhere(
      (eq) => eq.id == id,
      orElse: () => equipamentoMock,
    );
  }
}
