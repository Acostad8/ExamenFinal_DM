import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:examen_final/model/user_model.dart';
import 'package:examen_final/repository/user_repository.dart';

final authProvider = StateNotifierProvider<AuthNotifier, UserModel?>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<UserModel?> {
  final _userRepository = UserRepository();

  AuthNotifier() : super(null) {
    _loadUser();
  }

  void _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    if (userId != null) {
      final user = await _userRepository.getUserById(userId);
      if (mounted) state = user;
    }
  }

  Future<String?> login(String email, String password) async {
    final user = await _userRepository.loginUser(email, password);
    if (user == null) return 'invalid_credentials';
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userId', user.id!);
    state = user;
    return null;
  }

  Future<String?> register(
      String nombre, String email, String password) async {
    final exists = await _userRepository.emailExists(email);
    if (exists) return 'email_exists';
    final userModel =
        UserModel(nombre: nombre, email: email, password: password);
    final id = await _userRepository.insertUser(userModel);
    final savedUser =
        UserModel(id: id, nombre: nombre, email: email, password: password);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userId', id);
    state = savedUser;
    return null;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    state = null;
  }
}
