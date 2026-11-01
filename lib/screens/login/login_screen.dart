import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

/// Tela de login do aplicativo de manutenção industrial.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.onSubmit});

  /// Chamado com o identificador (e-mail ou usuário) e a senha digitados.
  final Future<void> Function(String identificador, String senha)? onSubmit;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const _background = Color(0xFF122B4B);
  static const _primary = Color(0xFF2979FF);
  static const _borderColor = Color(0xFFD5DCE8);
  static const _hintColor = Color(0xFFB4BFD0);
  static const _mutedText = Color(0xFFA9B6CC);
  static const _errorColor = Color(0xFFFF8A80);

  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocus = FocusNode();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isLoading) return; // evita múltiplos envios
    if (!(_formKey.currentState?.validate() ?? false)) return;

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      final email = _identifierController.text.trim();
      final password = _passwordController.text;

      final onSubmit = widget.onSubmit;
      if (onSubmit == null) {
        await AuthService.login(email, password);
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        await onSubmit(email, password);
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

  InputDecoration _fieldDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: color, width: width),
        );

    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: _hintColor,
        fontWeight: FontWeight.w600,
        fontSize: 15,
      ),
      prefixIcon: Icon(icon, color: Colors.white),
      suffixIcon: suffix,
      errorStyle: const TextStyle(color: _errorColor),
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
      enabledBorder: border(_borderColor),
      focusedBorder: border(Colors.white, 2),
      errorBorder: border(_errorColor),
      focusedErrorBorder: border(_errorColor, 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior:
              ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Align(
                  alignment: const Alignment(0, -0.55),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: _buildContent(),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const _Logo(),
        const SizedBox(height: 20),
        const Text(
          'Sistema de\nManutenção',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w800,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Mais controle, menos paradas.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 13),
        ),
        const SizedBox(height: 40),
        Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _identifierController,
                enabled: !_isLoading,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.username],
                autocorrect: false,
                style: const TextStyle(color: Colors.white),
                cursorColor: Colors.white,
                decoration: _fieldDecoration(
                  hint: 'E-mail ou Usuário',
                  icon: Icons.person_outline,
                ),
                onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe seu e-mail ou usuário.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                focusNode: _passwordFocus,
                enabled: !_isLoading,
                obscureText: _obscurePassword,
                keyboardType: TextInputType.visiblePassword,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                enableSuggestions: false,
                autocorrect: false,
                style: const TextStyle(color: Colors.white),
                cursorColor: Colors.white,
                decoration: _fieldDecoration(
                  hint: 'Senha',
                  icon: Icons.lock_open_outlined,
                  suffix: IconButton(
                    tooltip:
                    _obscurePassword ? 'Mostrar senha' : 'Ocultar senha',
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: _hintColor,
                    ),
                    onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                    ),
                  ),
                ),
                onFieldSubmitted: (_) => _submit(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe sua senha.';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
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
              textStyle: const TextStyle(
                fontSize: 16,
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
                : const Text('Entrar'),
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: _isLoading
              ? null
              : () => _showMessage(
            'Recuperação de senha ainda não disponível.',
          ),
          style: TextButton.styleFrom(
            foregroundColor: _mutedText,
            minimumSize: const Size(48, 48),
          ),
          child: const Text(
            'Esqueci minha senha',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

/// Símbolo do app: engrenagem com chevron, aproximado com ícones nativos.
/// Pode ser substituído pelo logotipo original exportado do protótipo.
class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return const ExcludeSemantics(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.settings_outlined, size: 96, color: Colors.white),
          Icon(Icons.chevron_right, size: 36, color: Colors.white),
        ],
      ),
    );
  }
}