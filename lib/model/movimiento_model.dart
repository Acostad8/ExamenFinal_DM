// Modelo que representa un movimiento financiero (ingreso o gasto)
class MovimientoModel {
  int? id;          // Clave primaria (null al crear, asignado por SQLite)
  int userId;       // ID del usuario dueño del movimiento (llave foránea)
  String tipo;      // 'ingreso' o 'gasto'
  String descripcion;
  double valor;
  String fecha;     // Formato ISO: 'YYYY-MM-DD'

  MovimientoModel({
    this.id,
    required this.userId,
    required this.tipo,
    required this.descripcion,
    required this.valor,
    required this.fecha,
  });

  // Convierte el modelo a un Map para insertarlo o actualizarlo en SQLite
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'user_id': userId,
      'tipo': tipo,
      'descripcion': descripcion,
      'valor': valor,
      'fecha': fecha,
    };
    // Solo incluye el id si ya existe (para UPDATE, no para INSERT)
    if (id != null) map['id'] = id;
    return map;
  }

  // Construye un MovimientoModel a partir de una fila devuelta por SQLite
  factory MovimientoModel.fromJson(Map<String, dynamic> json) {
    return MovimientoModel(
      id: json['id'],
      userId: json['user_id'],
      tipo: json['tipo'],
      descripcion: json['descripcion'],
      // Asegura que el valor sea double aunque SQLite lo devuelva como int
      valor: (json['valor'] as num).toDouble(),
      fecha: json['fecha'],
    );
  }
}
