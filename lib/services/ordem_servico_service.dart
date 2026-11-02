import 'api_client.dart';
import '../screens/ordens_servico/my_service_orders_models.dart';

class OrdemServicoService {
  static Future<List<ServiceOrderListItem>> getOrdensServico({bool apenasDisponiveis = false}) async {
    try {
      final endpoint = apenasDisponiveis ? '/ordens-servico?disponiveis=true' : '/ordens-servico';
      final response = await ApiClient.get(endpoint);
      if (response != null && response is List) {
        return response
            .map((item) => ServiceOrderListItem.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      if (ApiClient.authToken?.startsWith('mock_') == true) {
        final demoList = demoServiceOrders;
        if (apenasDisponiveis) {
          return demoList
              .where((os) => os.status == ServiceOrderStatus.open && os.technicianName == null)
              .toList();
        }
        return demoList;
      }
      rethrow;
    }
  }

  static Future<ServiceOrderListItem> getOrdemServicoById(int id) async {
    try {
      final response = await ApiClient.get('/ordens-servico/$id');
      if (response != null && response is Map<String, dynamic>) {
        return ServiceOrderListItem.fromJson(response);
      }
    } catch (e) {
      if (ApiClient.authToken?.startsWith('mock_') == true) {
        return demoServiceOrders.firstWhere((os) => os.id == id, orElse: () => demoServiceOrders.first);
      }
      rethrow;
    }
    throw ApiException('Ordem de serviço #$id não encontrada.');
  }

  static Future<void> criarOrdemServico(int ocorrenciaId, String tipoManutencao) async {
    final payload = {
      'ocorrenciaId': ocorrenciaId,
      'tipoManutencao': tipoManutencao,
    };
    try {
      await ApiClient.post('/ordens-servico', payload);
    } catch (e) {
      if (ApiClient.authToken?.startsWith('mock_') == true) return;
      rethrow;
    }
  }

  static Future<void> assumirOrdemServico(int ordemServicoId) async {
    try {
      await ApiClient.patch('/ordens-servico/$ordemServicoId/assumir');
    } catch (e) {
      if (ApiClient.authToken?.startsWith('mock_') == true) return;
      rethrow;
    }
  }

  static Future<void> iniciarManutencao(int ordemServicoId) async {
    try {
      await ApiClient.patch('/ordens-servico/$ordemServicoId/iniciar');
    } catch (e) {
      if (ApiClient.authToken?.startsWith('mock_') == true) return;
      rethrow;
    }
  }
}
