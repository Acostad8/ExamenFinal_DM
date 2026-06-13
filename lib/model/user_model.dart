// Modelo que representa a un usuario de la aplicación
class UserModel {
  int? id;       // Clave primaria (null al crear, asignado por SQLite)
  String nombre;
  String email;
  String password;

  UserModel({
    this.id,
    required this.nombre,
    required this.email,
    required this.password,
  });

  // Convierte el modelo a un Map para insertarlo o actualizarlo en SQLite
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'nombre': nombre,
      'email': email,
      'password': password,
    };
    // Solo incluye el id si ya existe (para UPDATE, no para INSERT)
    if (id != null) map['id'] = id;
    return map;
  }

  // Construye un UserModel a partir de una fila devuelta por SQLite
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      nombre: json['nombre'],
      email: json['email'],
      password: json['password'],
    );
  }
}
