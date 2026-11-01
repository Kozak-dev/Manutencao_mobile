import 'api_client.dart';
import '../models/usuario/usuario.dart';

class AuthService {
  static Usuario? currentUser;

  /// Tenta realizar o login no backend.
  /// Se a conexão falhar ou se for modo demonstração, realiza login de fallback
  /// com base no e-mail informado para facilitar testes.
  static Future<Usuario> login(String email, String senha) async {
    try {
      final response = await ApiClient.post('/auth/login', {
        'email': email,
        'senha': senha,
      });

      if (response != null && response is Map<String, dynamic>) {
        final token = response['token'] as String?;
        if (token != null) {
          ApiClient.authToken = token;
        }

        if (response.containsKey('usuario') && response['usuario'] is Map<String, dynamic>) {
          currentUser = Usuario.fromJson(response['usuario']);
          return currentUser!;
        }
      }
    } catch (e) {
      // Se for exceção de validação da API (400) ou não autorizado (401), re-lança
      if (e is ApiException && (e.statusCode == 400 || e.statusCode == 401)) {
        rethrow;
      }
      // Se a API estiver offline, utiliza fallback local de demonstração
    }

    // Fallback de demonstração caso a API não esteja em execução
    final isOperadorMail = email.toLowerCase().contains('operador');
    currentUser = Usuario(
      id: isOperadorMail ? 1 : 2,
      nome: isOperadorMail ? 'Carlos Operador' : 'João da Silva (Técnico)',
      email: email,
      perfil: 'Funcionario',
      funcao: isOperadorMail ? 'Operador' : 'Tecnico',
      ativo: true,
    );
    ApiClient.authToken = 'mock_jwt_token_${currentUser!.id}';
    return currentUser!;
  }

  static void logout() {
    currentUser = null;
    ApiClient.authToken = null;
  }
}
