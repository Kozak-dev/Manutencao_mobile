class Equipamento {
  final int id;
  final String nome;
  final String patrimonio;
  final String fabricante;
  final String modelo;
  final String numeroSerie;
  final DateTime dataAquisicao;
  final String status;
  final int setorId;
  final bool ativo;

  Equipamento({
    required this.id,
    required this.nome,
    required this.patrimonio,
    required this.fabricante,
    required this.modelo,
    required this.numeroSerie,
    required this.dataAquisicao,
    required this.status,
    required this.setorId,
    required this.ativo,
  });

  factory Equipamento.fromJson(Map<String, dynamic> json) {
    return Equipamento(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      nome: json['nome'] ?? '',
      patrimonio: json['patrimonio'] ?? '',
      fabricante: json['fabricante'] ?? '',
      modelo: json['modelo'] ?? '',
      numeroSerie: json['numeroSerie'] ?? '',
      dataAquisicao: json['dataAquisicao'] != null
          ? DateTime.tryParse(json['dataAquisicao'].toString()) ?? DateTime.now()
          : DateTime.now(),
      status: json['status'] ?? 'Funcionando',
      setorId: json['setorId'] is int
          ? json['setorId']
          : int.tryParse(json['setorId']?.toString() ?? '1') ?? 1,
      ativo: json['ativo'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'patrimonio': patrimonio,
      'fabricante': fabricante,
      'modelo': modelo,
      'numeroSerie': numeroSerie,
      'dataAquisicao': dataAquisicao.toIso8601String(),
      'status': status,
      'setorId': setorId,
      'ativo': ativo,
    };
  }
}
