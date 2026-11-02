import 'api_client.dart';
import '../screens/maintenance/maintenance_history_models.dart';
import '../screens/ordens_servico/perform_maintenance_screen.dart';

class ManutencaoService {
  static Future<void> concluirManutencao(int ordemServicoId, MaintenanceReportData data) async {
    final payload = {
      'ordemServicoId': ordemServicoId,
      'diagnostico': data.diagnosis,
      'servicoRealizado': data.serviceDone,
      'observacoes': data.observations,
      'dataInicio': data.startDate.toIso8601String(),
      'dataConclusao': data.endDate.toIso8601String(),
      'problemaResolvido': data.problemSolved,
    };

    try {
      await ApiClient.post('/ordens-servico/$ordemServicoId/concluir', payload);
    } catch (_) {
      // Tenta rota alternativa /manutencoes se o backend usar POST /api/manutencoes ou PUT /api/ordens-servico/{id}/manutencao
      try {
        await ApiClient.put('/ordens-servico/$ordemServicoId/manutencao', payload);
      } catch (_) {
        await ApiClient.post('/manutencoes', payload);
      }
    }
  }

  static Future<List<MaintenanceHistoryItem>> getHistorico() async {
    try {
      final response = await ApiClient.get('/manutencoes');
      if (response != null && response is List) {
        return response
            .map((item) => MaintenanceHistoryItem.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      try {
        final response = await ApiClient.get('/ordens-servico/historico');
        if (response != null && response is List) {
          return response
              .map((item) => MaintenanceHistoryItem.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      } catch (_) {}
    }
    return [];
  }
}
