import 'package:flutter/material.dart';
import '../../services/equipamento_service.dart';
import '../../services/ocorrencia_service.dart';
import 'new_occurrence_models.dart';

/// Tela de registro de uma nova ocorrência integrada com a API C#.
class NewOccurrenceScreen extends StatefulWidget {
  const NewOccurrenceScreen({
    super.key,
    this.equipments,
    this.onSubmit,
  });

  final List<EquipmentOption>? equipments;

  /// Se lançar exceção, a tela mostra erro de conexão.
  final Future<void> Function(NewOccurrenceData data)? onSubmit;

  @override
  State<NewOccurrenceScreen> createState() => _NewOccurrenceScreenState();
}

class _NewOccurrenceScreenState extends State<NewOccurrenceScreen> {
  static const _navy = Color(0xFF122B4B);
  static const _primary = Color(0xFF2979FF);
  static const _borderColor = Color(0xFFBDBDBD);
  static const _errorColor = Color(0xFFD32F2F);

  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();

  List<EquipmentOption> _equipmentOptions = [];
  bool _isLoadingEquipments = true;
  int? _equipmentId;
  OccurrencePriority? _priority;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadEquipments();
  }

  Future<void> _loadEquipments() async {
    if (widget.equipments != null) {
      setState(() {
        _equipmentOptions = widget.equipments!;
        _isLoadingEquipments = false;
      });
      return;
    }

    try {
      final list = await EquipamentoService.getEquipamentos();
      final options = list.map((eq) => EquipmentOption(id: eq.id, name: eq.nome)).toList();
      if (mounted) {
        setState(() {
          _equipmentOptions = options;
          _isLoadingEquipments = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _equipmentOptions = [];
          _isLoadingEquipments = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isLoading) return; // evita múltiplos envios
    if (!(_formKey.currentState?.validate() ?? false)) return;

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      final data = NewOccurrenceData(
        equipmentId: _equipmentId!,
        description: _descriptionController.text.trim(),
        priority: _priority!,
      );
      final onSubmit = widget.onSubmit;
      if (onSubmit == null) {
        await OcorrenciaService.registrarOcorrencia(data);
        if (!mounted) return;
        _showMessage('Ocorrência registrada com sucesso.');
        Navigator.of(context).pop();
      } else {
        await onSubmit(data);
      }
    } catch (e) {
      if (!mounted) return;
      _showMessage(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  OutlineInputBorder _outline(Color color, [double width = 1]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  InputDecoration _fieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF757575), fontSize: 13),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      enabledBorder: _outline(_borderColor),
      disabledBorder: _outline(_borderColor),
      focusedBorder: _outline(_navy, 2),
      errorBorder: _outline(_errorColor),
      focusedErrorBorder: _outline(_errorColor, 2),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Nova Ocorrência',
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
                    const _FieldLabel('Equipamento'),
                    _buildEquipmentDropdown(),
                    const SizedBox(height: 24),
                    const _FieldLabel('Descrição do problema'),
                    _buildDescriptionField(),
                    const SizedBox(height: 24),
                    const _FieldLabel('Prioridade'),
                    _buildPrioritySelector(),
                    const SizedBox(height: 24),
                    const _FieldLabel('Anectar foto', suffix: ' (Opcional)'),
                    _PhotoPlaceholder(
                      onTap: () => _showMessage(
                        'Anexar foto ainda não está disponível.',
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEquipmentDropdown() {
    if (_isLoadingEquipments) {
      return const LinearProgressIndicator();
    }

    if (_equipmentOptions.isEmpty) {
      return DropdownButtonFormField<int>(
        isExpanded: true,
        borderRadius: BorderRadius.circular(10),
        decoration: _fieldDecoration('Nenhum equipamento cadastrado'),
        items: const [],
        onChanged: null,
        validator: (_) => 'Nenhum equipamento cadastrado no sistema.',
      );
    }

    return DropdownButtonFormField<int>(
      isExpanded: true,
      borderRadius: BorderRadius.circular(10),
      icon: const Icon(Icons.arrow_drop_down),
      iconEnabledColor: Colors.black,
      decoration: _fieldDecoration('Selecione o equipamento'),
      initialValue: _equipmentId,
      items: [
        for (final equipment in _equipmentOptions)
          DropdownMenuItem<int>(
            value: equipment.id,
            child: Text(equipment.name),
          ),
      ],
      onChanged: _isLoading ? null : (id) => setState(() => _equipmentId = id),
      validator: (value) =>
          value == null ? 'Selecione o equipamento.' : null,
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      enabled: !_isLoading,
      minLines: 5,
      maxLines: 8,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      textCapitalization: TextCapitalization.sentences,
      decoration: _fieldDecoration('Descreva o que está acontecendo...'),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Descreva o problema.';
        }
        return null;
      },
    );
  }

  Widget _buildPrioritySelector() {
    return FormField<OccurrencePriority>(
      validator: (value) => value == null ? 'Selecione a prioridade.' : null,
      builder: (field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                for (final priority in OccurrencePriority.values) ...[
                  if (priority != OccurrencePriority.values.first)
                    const SizedBox(width: 12),
                  Expanded(
                    child: _PriorityButton(
                      priority: priority,
                      selected: field.value == priority,
                      onTap: _isLoading
                          ? null
                          : () {
                              field.didChange(priority);
                              setState(() => _priority = priority);
                            },
                    ),
                  ),
                ],
              ],
            ),
            if (field.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 4),
                child: Text(
                  field.errorText!,
                  style: const TextStyle(color: _errorColor, fontSize: 12),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: FilledButton(
        onPressed: _isLoading ? null : _submit,
        style: FilledButton.styleFrom(
          backgroundColor: _primary,
          disabledBackgroundColor: _primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
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
            : const Text('Registrar ocorrência'),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text, {this.suffix});

  final String text;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text.rich(
        TextSpan(
          text: text,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          children: [
            if (suffix != null)
              TextSpan(
                text: suffix,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF616161),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PriorityButton extends StatelessWidget {
  const _PriorityButton({
    required this.priority,
    required this.selected,
    required this.onTap,
  });

  final OccurrencePriority priority;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final (Color border, Color background, Color text) = switch (priority) {
      OccurrencePriority.low => (
          const Color(0xFF2EB872),
          const Color(0xFFE5F8EE),
          const Color(0xFF1E9A5A),
        ),
      OccurrencePriority.medium => (
          const Color(0xFFF2B544),
          const Color(0xFFFFF6E0),
          const Color(0xFFD98E04),
        ),
      OccurrencePriority.high => (
          const Color(0xFFF5748A),
          const Color(0xFFFFEBEE),
          const Color(0xFFE53950),
        ),
    };

    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? border : background,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Container(
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(color: border),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              priority.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: selected ? Colors.white : text,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  const _PhotoPlaceholder({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 124),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFBDBDBD)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_camera_outlined, size: 36),
            SizedBox(height: 12),
            Text(
              'Toque para adicionar uma imagem',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
