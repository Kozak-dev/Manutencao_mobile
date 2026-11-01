class Usuario {
  final int id;
  final String nome;
  final String email;
  final String perfil;
  final String funcao;
  final bool ativo;

  Usuario({
    required this.id,
    required this.nome,
    required this.email,
    required this.perfil,
    required this.funcao,
    required this.ativo,
  });

  bool get isOperador => funcao.toLowerCase() == 'operador';
  bool get isTecnico => funcao.toLowerCase() == 'tecnico' || funcao.toLowerCase() == 'técnico';
  bool get isAdmin => perfil.toLowerCase() == 'administrador' || funcao.toLowerCase() == 'administrador';

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      nome: json['nome'] ?? '',
      email: json['email'] ?? '',
      perfil: json['perfil'] ?? 'Funcionario',
      funcao: json['funcao'] ?? 'Operador',
      ativo: json['ativo'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'perfil': perfil,
      'funcao': funcao,
      'ativo': ativo,
    };
  }
}
