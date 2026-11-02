import 'api_client.dart';
import '../models/equipamento/equipamento.dart';

class EquipmentStatusSummaryData {
  final int running;
  final int underMaintenance;
  final int stopped;

  EquipmentStatusSummaryData({
    required this.running,
    required this.underMaintenance,
    required this.stopped,
  });
}

class EquipamentoService {
  static Future<List<Equipamento>> getEquipamentos() async {
    try {
      final response = await ApiClient.get('/equipamentos');
      if (response != null && response is List) {
        return response
            .map((item) => Equipamento.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      if (ApiClient.authToken?.startsWith('mock_') == true) {
        return [
          Equipamento(
            id: 1,
            nome: 'Prensa Hidráulica',
            patrimonio: 'PAT-001',
            fabricante: 'Fabricante Teste',
            modelo: 'PH-100',
            numeroSerie: 'SN-001',
            dataAquisicao: DateTime(2024, 1, 15),
            status: 'Funcionando',
            setorId: 1,
            ativo: true,
          ),
        ];
      }
      rethrow;
    }
  }

  static Future<Equipamento> getEquipamentoById(int id) async {
    try {
      final response = await ApiClient.get('/equipamentos/$id');
      if (response != null && response is Map<String, dynamic>) {
        return Equipamento.fromJson(response);
      }
    } catch (e) {
      if (ApiClient.authToken?.startsWith('mock_') == true) {
        return Equipamento(
          id: id,
          nome: 'Prensa Hidráulica',
          patrimonio: 'PAT-001',
          fabricante: 'Fabricante Teste',
          modelo: 'PH-100',
          numeroSerie: 'SN-001',
          dataAquisicao: DateTime(2024, 1, 15),
          status: 'Funcionando',
          setorId: 1,
          ativo: true,
        );
      }
      rethrow;
    }
    throw ApiException('Equipamento #$id não encontrado.');
  }

  static Future<EquipmentStatusSummaryData> getStatusSummary() async {
    try {
      final response = await ApiClient.get('/equipamentos/resumo');
      if (response != null && response is Map<String, dynamic>) {
        return EquipmentStatusSummaryData(
          running: response['running'] ?? response['funcionando'] ?? 0,
          underMaintenance: response['underMaintenance'] ?? response['emManutencao'] ?? 0,
          stopped: response['stopped'] ?? response['parado'] ?? 0,
        );
      }
    } catch (_) {}

    try {
      final list = await getEquipamentos();
      int running = 0;
      int underMaintenance = 0;
      int stopped = 0;

      for (final eq in list) {
        final st = eq.status.toLowerCase();
        if (st.contains('funcio') || st.contains('opera')) {
          running++;
        } else if (st.contains('manuten')) {
          underMaintenance++;
        } else if (st.contains('parad')) {
          stopped++;
        } else {
          running++;
        }
      }

      return EquipmentStatusSummaryData(
        running: running,
        underMaintenance: underMaintenance,
        stopped: stopped,
      );
    } catch (e) {
      if (ApiClient.authToken?.startsWith('mock_') == true) {
        return EquipmentStatusSummaryData(running: 12, underMaintenance: 3, stopped: 2);
      }
      rethrow;
    }
  }
}
