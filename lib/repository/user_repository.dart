import 'package:examen_final/helper/database_helper.dart';
import 'package:examen_final/model/user_model.dart';

class UserRepository {
  final _db = DatabaseHelper();

  Future<int> insertUser(UserModel user) async {
    final db = await _db.database;
    return await db.insert('users', user.toMap());
  }

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
