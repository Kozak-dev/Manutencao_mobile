import 'api_client.dart';
import '../screens/ordens_servico/my_service_orders_models.dart';

class OrdemServicoService {
  static Future<List<ServiceOrderListItem>> getOrdensServico({bool apenasDisponiveis = false}) async {
    try {
      final endpoint = apenasDisponiveis ? '/ordens-servico?disponiveis=true' : '/ordens-servico';
      final response = await ApiClient.get(endpoint);
      if (response != null && response is List) {
        return response.map((item) {
          final map = item as Map<String, dynamic>;
          return ServiceOrderListItem(
            id: map['id'] is int ? map['id'] : int.parse(map['id'].toString()),
            equipmentName: map['equipamentoNome'] ?? 'Equipamento',
            maintenanceType: MaintenanceType.corrective,
            status: ServiceOrderStatus.open,
            createdAt: map['dataAbertura'] != null
                ? DateTime.tryParse(map['dataAbertura'].toString()) ?? DateTime.now()
                : DateTime.now(),
            technicianName: map['tecnicoNome'],
            occurrenceId: map['ocorrenciaId'],
          );
        }).toList();
      }
    } catch (_) {
      // Fallback
    }

    final demoList = demoServiceOrders;
    if (apenasDisponiveis) {
      return demoList
          .where((os) => os.status == ServiceOrderStatus.open && os.technicianName == null)
          .toList();
    }
    return demoList;
  }

  static Future<void> assumirOrdemServico(int ordemServicoId) async {
    try {
      await ApiClient.patch('/ordens-servico/$ordemServicoId/assumir');
    } catch (e) {
      if (e is ApiException) rethrow;
    }
  }

  static Future<void> iniciarManutencao(int ordemServicoId) async {
    try {
      await ApiClient.patch('/ordens-servico/$ordemServicoId/iniciar');
    } catch (e) {
      if (e is ApiException) rethrow;
    }
  }
}
