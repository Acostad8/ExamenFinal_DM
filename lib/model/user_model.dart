class UserModel {
  int? id;
  String nombre;
  String email;
  String password;

  UserModel({
    this.id,
    required this.nombre,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'nombre': nombre,
      'email': email,
      'password': password,
    };
    if (id != null) map['id'] = id;
    return map;
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      nombre: json['nombre'],
      email: json['email'],
      password: json['password'],
    );
  }
}
