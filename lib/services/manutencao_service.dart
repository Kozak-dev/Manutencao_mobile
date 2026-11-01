import 'api_client.dart';
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
    } catch (e) {
      if (e is ApiException) rethrow;
    }
  }
}
