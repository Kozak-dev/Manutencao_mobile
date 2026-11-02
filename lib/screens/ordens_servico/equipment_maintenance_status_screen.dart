import 'package:flutter/material.dart';
import '../../services/ordem_servico_service.dart';
import 'my_service_orders_models.dart';
import 'perform_maintenance_screen.dart';

/// Tela intermediária que exibe o status de "Equipamento em Manutenção"
/// após o técnico assumir a OS, com o botão para registrar o relatório e concluir.
class EquipmentMaintenanceStatusScreen extends StatefulWidget {
  const EquipmentMaintenanceStatusScreen({
    super.key,
    required this.serviceOrder,
  });

  final ServiceOrderListItem serviceOrder;

  @override
  State<EquipmentMaintenanceStatusScreen> createState() =>
      _EquipmentMaintenanceStatusScreenState();
}

class _EquipmentMaintenanceStatusScreenState
    extends State<EquipmentMaintenanceStatusScreen> {
  static const _navy = Color(0xFF122B4B);
  static const _yellow = Color(0xFFFFB927);
  static const _blue = Color(0xFF2979FF);

  bool _isLoading = false;

  Future<void> _iniciarEProsseguir() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      // Inicia a manutenção na API (OS -> Em Atendimento, Equipamento -> Em Manutenção)
      await OrdemServicoService.iniciarManutencao(widget.serviceOrder.id);
    } catch (_) {
      // Continua mesmo se offline/demo
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => PerformMaintenanceScreen(serviceOrder: widget.serviceOrder),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.serviceOrder;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: _navy,
        foregroundColor: Colors.white,
        titleSpacing: 0,
        centerTitle: false,
        leading: IconButton(
          tooltip: 'Voltar',
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Navigator.pushReplacementNamed(context, '/home');
            }
          },
        ),
        title: const Text(
          'Manutenção em Andamento',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusCard(),
                  const SizedBox(height: 20),
                  _buildDetailsCard(order),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton.icon(
                      onPressed: _isLoading ? null : _iniciarEProsseguir,
                      style: FilledButton.styleFrom(
                        backgroundColor: _blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      icon: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.check_circle_outline),
                      label: const Text('Equipamento terminou a manutenção? Preencher Relatório'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E8),
        border: Border.all(color: _yellow, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        children: [
          Icon(Icons.build_circle_outlined, size: 54, color: Color(0xFFD98E04)),
          SizedBox(height: 12),
          Text(
            'Equipamento em Manutenção',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFFB37402),
            ),
          ),
          SizedBox(height: 6),
          Text(
            'A ordem de serviço foi assumida e o equipamento encontra-se parado em intervenção técnica.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Color(0xFF616161)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(ServiceOrderListItem order) {
    const sectionTitle = TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF616161));
    const sectionValue = TextStyle(fontSize: 14, fontWeight: FontWeight.w600);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  order.code,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4DC),
                  border: Border.all(color: _yellow),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Em Atendimento',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFE08600),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          const Text('Equipamento', style: sectionTitle),
          const SizedBox(height: 2),
          Text(order.equipmentName, style: sectionValue),
          const SizedBox(height: 12),
          const Text('Tipo de Manutenção', style: sectionTitle),
          const SizedBox(height: 2),
          Text(order.maintenanceType.label, style: sectionValue),
          const SizedBox(height: 12),
          const Text('Técnico Responsável', style: sectionTitle),
          const SizedBox(height: 2),
          Text(order.technicianName ?? 'Técnico atual', style: sectionValue),
        ],
      ),
    );
  }
}
