import 'package:flutter/material.dart';

import 'profile_models.dart';

/// Tela "Meu Perfil".
///
/// Os dados vêm por parâmetro; sem eles, usa dados simulados. "Alterar senha"
/// e "Configurações" ainda não têm destino. "Sair" chama [onLogout] quando
/// houver sessão real; sem ele, apenas exibe um aviso.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    this.profile = demoUserProfile,
    this.onLogout,
  });

  final UserProfile profile;
  final VoidCallback? onLogout;

  static const _navy = Color(0xFF122B4B);
  static const _blue = Color(0xFF2F6BFF);
  static const _red = Color(0xFFE53950);

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
          'Meu Perfil',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildProfileCard(),
                  const SizedBox(height: 20),
                  _buildActionsCard(context),
                  const SizedBox(height: 20),
                  _buildLogoutButton(context),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: _blue,
        unselectedItemColor: Colors.black87,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        onTap: (index) {
          if (index != 3) {
            const labels = ['Início', 'Ocorrência', 'OS', 'Mais'];
            _showUnavailable(context, labels[index]);
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Ocorrência',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            label: 'OS',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz),
            label: 'Mais',
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return _Card(
      color: const Color(0xFFF7F8FC),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 28,
                backgroundColor: Color(0xFFBDBDBD),
                child: Icon(Icons.person, size: 36, color: Color(0xFF424242)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tipo de usuário: ${profile.accessProfile.label}',
                      style: const TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _InfoField(label: 'E-mail', value: profile.email),
          _InfoField(
            label: 'Função',
            value: profile.role?.label ?? 'Não se aplica',
          ),
          _InfoField(
            label: 'Setor',
            value: profile.sector ?? 'Não informado',
          ),
          _InfoField(
            label: 'Telefone',
            value: profile.phone ?? 'Não informado',
          ),
        ],
      ),
    );
  }

  Widget _buildActionsCard(BuildContext context) {
    return _Card(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _ActionRow(
            icon: Icons.lock_outline,
            label: 'Alterar senha',
            onTap: () => _showUnavailable(context, 'Alterar senha'),
          ),
          const Divider(height: 1, color: Colors.black26),
          _ActionRow(
            icon: Icons.settings,
            label: 'Configurações',
            onTap: () => _showUnavailable(context, 'Configurações'),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Material(
      color: const Color(0xFFFFEBEE),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: _red),
      ),
      child: InkWell(
        onTap: onLogout ?? () => _showUnavailable(context, 'Sair'),
        child: Container(
          width: double.infinity,
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.centerLeft,
          child: const Row(
            children: [
              Icon(Icons.logout, color: _red),
              SizedBox(width: 12),
              Text(
                'Sair',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void _showUnavailable(BuildContext context, String destination) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('"$destination" ainda não está disponível.')),
      );
  }
}

/// Cartão com sombra suave.
class _Card extends StatelessWidget {
  const _Card({
    required this.child,
    required this.color,
    required this.padding,
  });

  final Widget child;
  final Color color;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Campo de informação (rótulo + valor) precedido por uma linha divisória.
class _InfoField extends StatelessWidget {
  const _InfoField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 1, color: Colors.black26),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 11)),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: Row(
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.black54),
          ],
        ),
      ),
    );
  }
}