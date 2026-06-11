import 'dart:convert';

import 'package:examen_final/model/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserRepository {
  static const _key = 'ef_users';

  Future<List<UserModel>> _getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    final List list = jsonDecode(raw);
    return list
        .map((m) => UserModel.fromJson(Map<String, dynamic>.from(m)))
        .toList();
  }

  Future<void> _saveAll(List<UserModel> users) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _key, jsonEncode(users.map((u) => u.toMap()).toList()));
  }

  Future<int> insertUser(UserModel user) async {
    final users = await _getAll();
    final id = users.isEmpty
        ? 1
        : users.map((u) => u.id!).reduce((a, b) => a > b ? a : b) + 1;
    users.add(UserModel(
        id: id,
        nombre: user.nombre,
        email: user.email,
        password: user.password));
    await _saveAll(users);
    return id;
  }

  Future<UserModel?> loginUser(String email, String password) async {
    final users = await _getAll();
    try {
      return users
          .firstWhere((u) => u.email == email && u.password == password);
    } catch (_) {
      return null;
    }
  }

  Future<bool> emailExists(String email) async {
    final users = await _getAll();
    return users.any((u) => u.email == email);
  }

  Future<UserModel?> getUserById(int id) async {
    final users = await _getAll();
    try {
      return users.firstWhere((u) => u.id == id);
    } catch (_) {
      return null;
    }
  }
}
