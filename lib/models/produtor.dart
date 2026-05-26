class Produtor {
  final String id;
  final String usuarioId;
  final String nome;
  final String? fazenda;
  final String? municipio;
  final String? telefone;
  final String dataCriacao;
  final bool sincronizado;

  Produtor({
    required this.id,
    required this.usuarioId,
    required this.nome,
    this.fazenda,
    this.municipio,
    this.telefone,
    required this.dataCriacao,
    this.sincronizado = false,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'usuario_id': usuarioId,
        'nome': nome,
        'fazenda': fazenda,
        'municipio': municipio,
        'telefone': telefone,
        'data_criacao': dataCriacao,
        'sincronizado': sincronizado ? 1 : 0,
      };

  factory Produtor.fromMap(Map<String, dynamic> map) => Produtor(
        id: map['id'] as String,
        usuarioId: map['usuario_id'] as String,
        nome: map['nome'] as String,
        fazenda: map['fazenda'] as String?,
        municipio: map['municipio'] as String?,
        telefone: map['telefone'] as String?,
        dataCriacao: map['data_criacao'] as String,
        sincronizado: (map['sincronizado'] as int) == 1,
      );

  Produtor copyWith({
    String? id,
    String? usuarioId,
    String? nome,
    String? fazenda,
    String? municipio,
    String? telefone,
    String? dataCriacao,
    bool? sincronizado,
  }) =>
      Produtor(
        id: id ?? this.id,
        usuarioId: usuarioId ?? this.usuarioId,
        nome: nome ?? this.nome,
        fazenda: fazenda ?? this.fazenda,
        municipio: municipio ?? this.municipio,
        telefone: telefone ?? this.telefone,
        dataCriacao: dataCriacao ?? this.dataCriacao,
        sincronizado: sincronizado ?? this.sincronizado,
      );
}
