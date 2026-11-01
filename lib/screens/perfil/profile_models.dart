/// Perfil de acesso definido no PIM (PerfilUsuario).
enum UserAccessProfile {
  administrator('Administrador'),
  employee('Funcionário');

  const UserAccessProfile(this.label);

  final String label;
}

/// Função do funcionário definida no PIM (FuncaoFuncionario).
enum EmployeeRole {
  operator('Operador'),
  technician('Técnico');

  const EmployeeRole(this.label);

  final String label;
}

/// Dados públicos do usuário exibidos no perfil.
///
/// Não contém senha nem SenhaHash. [sector] e [phone] aparecem no protótipo,
/// mas não existem na tabela Usuario do PIM, por isso são opcionais.
class UserProfile {
  const UserProfile({
    required this.name,
    required this.email,
    required this.accessProfile,
    this.role,
    this.sector,
    this.phone,
  });

  final String name;
  final String email;
  final UserAccessProfile accessProfile;

  /// Administrador pode não ter função de funcionário.
  final EmployeeRole? role;
  final String? sector;
  final String? phone;
}

// ---------------------------------------------------------------------------
// DADOS SIMULADOS (apenas para demonstração do protótipo).
// Substituir pelos dados do usuário logado quando a API estiver disponível.
// ---------------------------------------------------------------------------
const demoUserProfile = UserProfile(
  name: 'Nome do Usuário',
  email: 'user@empresa.com',
  accessProfile: UserAccessProfile.employee,
  role: EmployeeRole.operator,
  sector: '01',
  phone: '1111-1111',
);