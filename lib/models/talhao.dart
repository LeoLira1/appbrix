class Talhao {
  final String id;
  final String usuarioId;
  final String? produtorId;
  final String nome;
  final double latitude;
  final double longitude;
  final String dataHora;
  final String? observacoes;
  final String? amostraId;
  final bool sincronizado;

  Talhao({
    required this.id,
    required this.usuarioId,
    this.produtorId,
    required this.nome,
    required this.latitude,
    required this.longitude,
    required this.dataHora,
    this.observacoes,
    this.amostraId,
    this.sincronizado = false,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'usuario_id': usuarioId,
        'produtor_id': produtorId,
        'nome': nome,
        'latitude': latitude,
        'longitude': longitude,
        'data_hora': dataHora,
        'observacoes': observacoes,
        'amostra_id': amostraId,
        'sincronizado': sincronizado ? 1 : 0,
      };

  factory Talhao.fromMap(Map<String, dynamic> map) => Talhao(
        id: map['id'] as String,
        usuarioId: map['usuario_id'] as String,
        produtorId: map['produtor_id'] as String?,
        nome: map['nome'] as String,
        latitude: (map['latitude'] as num).toDouble(),
        longitude: (map['longitude'] as num).toDouble(),
        dataHora: map['data_hora'] as String,
        observacoes: map['observacoes'] as String?,
        amostraId: map['amostra_id'] as String?,
        sincronizado: (map['sincronizado'] as int) == 1,
      );
}
