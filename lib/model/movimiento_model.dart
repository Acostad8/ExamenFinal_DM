class MovimientoModel {
  int? id;
  int userId;
  String tipo;
  String descripcion;
  double valor;
  String fecha;

  MovimientoModel({
    this.id,
    required this.userId,
    required this.tipo,
    required this.descripcion,
    required this.valor,
    required this.fecha,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'user_id': userId,
      'tipo': tipo,
      'descripcion': descripcion,
      'valor': valor,
      'fecha': fecha,
    };
    if (id != null) map['id'] = id;
    return map;
  }

  factory MovimientoModel.fromJson(Map<String, dynamic> json) {
    return MovimientoModel(
      id: json['id'],
      userId: json['user_id'],
      tipo: json['tipo'],
      descripcion: json['descripcion'],
      valor: (json['valor'] as num).toDouble(),
      fecha: json['fecha'],
    );
  }
}
