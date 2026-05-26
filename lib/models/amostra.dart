class Amostra {
  final String id;
  final String usuarioId;
  final String? produtorId;
  final int numero;
  final double brix;
  final double brixPonta;
  final double brixBase;
  final String dataHora;
  final bool sincronizado;

  Amostra({
    required this.id,
    required this.usuarioId,
    this.produtorId,
    required this.numero,
    required this.brix,
    required this.brixPonta,
    required this.brixBase,
    required this.dataHora,
    this.sincronizado = false,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'usuario_id': usuarioId,
        'produtor_id': produtorId,
        'numero': numero,
        'brix': brix,
        'brix_ponta': brixPonta,
        'brix_base': brixBase,
        'data_hora': dataHora,
        'sincronizado': sincronizado ? 1 : 0,
      };

  factory Amostra.fromMap(Map<String, dynamic> map) => Amostra(
        id: map['id'] as String,
        usuarioId: map['usuario_id'] as String,
        produtorId: map['produtor_id'] as String?,
        numero: map['numero'] as int,
        brix: (map['brix'] as num).toDouble(),
        brixPonta: (map['brix_ponta'] as num).toDouble(),
        brixBase: (map['brix_base'] as num).toDouble(),
        dataHora: map['data_hora'] as String,
        sincronizado: (map['sincronizado'] as int) == 1,
      );

  Amostra copyWith({
    String? id,
    String? usuarioId,
    String? produtorId,
    int? numero,
    double? brix,
    double? brixPonta,
    double? brixBase,
    String? dataHora,
    bool? sincronizado,
  }) =>
      Amostra(
        id: id ?? this.id,
        usuarioId: usuarioId ?? this.usuarioId,
        produtorId: produtorId ?? this.produtorId,
        numero: numero ?? this.numero,
        brix: brix ?? this.brix,
        brixPonta: brixPonta ?? this.brixPonta,
        brixBase: brixBase ?? this.brixBase,
        dataHora: dataHora ?? this.dataHora,
        sincronizado: sincronizado ?? this.sincronizado,
      );
}
