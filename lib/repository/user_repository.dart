import 'package:examen_final/helper/database_helper.dart';
import 'package:examen_final/model/user_model.dart';

// Repositorio que maneja todas las operaciones CRUD de usuarios en SQLite
class UserRepository {
  final _db = DatabaseHelper();

  // Inserta un nuevo usuario y devuelve el id generado por SQLite
  Future<int> insertUser(UserModel user) async {
    final db = await _db.database;
    return await db.insert('users', user.toMap());
  }

  // Busca un usuario por email y password; devuelve null si no coincide
  Future<UserModel?> loginUser(String email, String password) async {
    final db = await _db.database;
    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return UserModel.fromJson(result.first);
  }

  // Verifica si ya existe un usuario registrado con ese email
  Future<bool> emailExists(String email) async {
    final db = await _db.database;
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  // Obtiene un usuario por su id; usado para restaurar la sesión al reabrir la app
  Future<UserModel?> getUserById(int id) async {
    final db = await _db.database;
    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return UserModel.fromJson(result.first);
  }
}
