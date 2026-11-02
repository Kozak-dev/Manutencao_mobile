import 'package:flutter/material.dart';
import '../../services/manutencao_service.dart';
import '../home/home_screen.dart';
import 'my_service_orders_models.dart';

/// Dados do relatório de manutenção preenchidos pelo técnico conforme o PIM.
class MaintenanceReportData {
  const MaintenanceReportData({
    required this.diagnosis,
    required this.serviceDone,
    required this.observations,
    required this.startDate,
    required this.endDate,
    required this.problemSolved,
  });

  final String diagnosis;
  final String serviceDone;
  final String observations;
  final DateTime startDate;
  final DateTime endDate;
  final bool problemSolved;
}

/// Tela "Realizar Manutenção", aberta ao assumir uma OS.
class PerformMaintenanceScreen extends StatefulWidget {
  const PerformMaintenanceScreen({
    super.key,
    required this.serviceOrder,
    this.onSave,
  });

  final ServiceOrderListItem serviceOrder;

  /// Se lançar exceção, a tela mostra erro de conexão e permanece aberta.
  final Future<void> Function(MaintenanceReportData data)? onSave;

  @override
  State<PerformMaintenanceScreen> createState() =>
      _PerformMaintenanceScreenState();
}

class _PerformMaintenanceScreenState extends State<PerformMaintenanceScreen> {
  static const _navy = Color(0xFF122B4B);
  static const _blue = Color(0xFF2979FF);

  final _formKey = GlobalKey<FormState>();
  final _diagnosisController = TextEditingController();
  final _serviceController = TextEditingController();
  final _observationsController = TextEditingController();

  DateTime _startDate = DateTime.now().subtract(const Duration(hours: 1));
  DateTime _endDate = DateTime.now();
  bool? _problemSolved;
  bool _isLoading = false;

  @override
  void dispose() {
    _diagnosisController.dispose();
    _serviceController.dispose();
    _observationsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isLoading) return; // evita múltiplos envios
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_problemSolved == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe se o problema foi resolvido.')),
      );
      return;
    }

    FocusScope.of(context).unfocus();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _isLoading = true);

    try {
      final data = MaintenanceReportData(
        diagnosis: _diagnosisController.text.trim(),
        serviceDone: _serviceController.text.trim(),
        observations: _observationsController.text.trim(),
        startDate: _startDate,
        endDate: _endDate,
        problemSolved: _problemSolved!,
      );

      final onSave = widget.onSave;
      if (onSave == null) {
        await ManutencaoService.concluirManutencao(widget.serviceOrder.id, data);
      } else {
        await onSave(data);
      }

      if (!mounted) return;
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Manutenção concluída com sucesso')),
        );
      navigator.pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
          ),
        );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickDateTime(bool isStart) async {
    final initial = isStart ? _startDate : _endDate;
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );

    if (time == null || !mounted) return;

    final selected = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    setState(() {
      if (isStart) {
        _startDate = selected;
      } else {
        _endDate = selected;
      }
    });
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
          'Realizar Manutenção',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.code,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      order.equipmentName,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const _StepIndicator(currentIndex: 3),
                    const SizedBox(height: 20),
                    _ReportField(
                      label: 'Diagnóstico',
                      hint: 'Descrever o que foi identificado...',
                      controller: _diagnosisController,
                      errorMessage: 'Informe o diagnóstico.',
                      enabled: !_isLoading,
                    ),
                    const SizedBox(height: 20),
                    _ReportField(
                      label: 'Serviço realizado',
                      hint: 'Descrever o serviço executado...',
                      controller: _serviceController,
                      errorMessage: 'Informe o serviço realizado.',
                      enabled: !_isLoading,
                    ),
                    const SizedBox(height: 20),
                    _ReportField(
                      label: 'Observações',
                      hint: 'Observações adicionais...',
                      controller: _observationsController,
                      errorMessage: 'Informe as observações.',
                      enabled: !_isLoading,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _DateTimeTile(
                            label: 'Data/Hora Início',
                            dateTime: _startDate,
                            onTap: () => _pickDateTime(true),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _DateTimeTile(
                            label: 'Data/Hora Conclusão',
                            dateTime: _endDate,
                            onTap: () => _pickDateTime(false),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'O problema foi resolvido?',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text('SIM (Resolvido)')),
                            selected: _problemSolved == true,
                            selectedColor: const Color(0xFF2EB872),
                            labelStyle: TextStyle(
                              color: _problemSolved == true ? Colors.white : Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                            onSelected: (selected) {
                              if (selected) setState(() => _problemSolved = true);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text('NÃO (Continua Parado)')),
                            selected: _problemSolved == false,
                            selectedColor: const Color(0xFFF5304F),
                            labelStyle: TextStyle(
                              color: _problemSolved == false ? Colors.white : Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                            onSelected: (selected) {
                              if (selected) setState(() => _problemSolved = false);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton(
                        onPressed: _isLoading ? null : _submit,
                        style: FilledButton.styleFrom(
                          backgroundColor: _blue,
                          disabledBackgroundColor: _blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Concluir Manutenção'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DateTimeTile extends StatelessWidget {
  const _DateTimeTile({
    required this.label,
    required this.dateTime,
    required this.onTap,
  });

  final String label;
  final DateTime dateTime;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = '${dateTime.day.toString().padLeft(2, '0')}/'
        '${dateTime.month.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFBDBDBD)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Color(0xFF616161)),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16),
                const SizedBox(width: 6),
                Text(
                  text,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Indicador das 4 etapas.
class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.currentIndex});

  final int currentIndex;

  static const _labels = ['Iniciar', 'Diagnosticar', 'Serviço', 'Concluir'];

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < _labels.length; i++) ...[
          if (i > 0)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 17),
                child: Container(height: 2, color: const Color(0xFFBDBDBD)),
              ),
            ),
          _Step(
            number: i + 1,
            label: _labels[i],
            active: i == currentIndex,
          ),
        ],
      ],
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({
    required this.number,
    required this.label,
    required this.active,
  });

  final int number;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF2979FF);

    return Semantics(
      label: 'Etapa $number de 4: $label',
      excludeSemantics: true,
      child: SizedBox(
        width: 64,
        child: Column(
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: active ? blue : const Color(0xFFE0E0E0),
                shape: BoxShape.circle,
              ),
              child: Text(
                '$number',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: active ? Colors.white : Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: active ? blue : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Campo de texto multilinha obrigatório.
class _ReportField extends StatelessWidget {
  const _ReportField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.errorMessage,
    required this.enabled,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final String errorMessage;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: color, width: width),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        FormField<String>(
          initialValue: '',
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (_) =>
              controller.text.trim().isEmpty ? errorMessage : null,
          builder: (state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33000000),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: controller,
                    enabled: enabled,
                    minLines: 3,
                    maxLines: 6,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    textCapitalization: TextCapitalization.sentences,
                    onChanged: state.didChange,
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: const TextStyle(
                        color: Color(0xFF757575),
                        fontSize: 12,
                      ),
                      contentPadding: const EdgeInsets.all(14),
                      enabledBorder: border(const Color(0xFFE6E6E6)),
                      disabledBorder: border(const Color(0xFFE6E6E6)),
                      focusedBorder: border(const Color(0xFF122B4B), 1.5),
                    ),
                  ),
                ),
                if (state.hasError)
                  Padding(
                    padding: const EdgeInsets.only(top: 6, left: 4),
                    child: Text(
                      state.errorText!,
                      style: const TextStyle(
                        color: Color(0xFFD32F2F),
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
