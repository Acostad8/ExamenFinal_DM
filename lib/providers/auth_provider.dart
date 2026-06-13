import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:examen_final/model/user_model.dart';
import 'package:examen_final/repository/user_repository.dart';

// Provider global que expone el usuario activo (null = no hay sesión)
final authProvider = StateNotifierProvider<AuthNotifier, UserModel?>((ref) {
  return AuthNotifier();
});

// Notifier que gestiona el estado de autenticación
class AuthNotifier extends StateNotifier<UserModel?> {
  final _userRepository = UserRepository();

  // Inicia con null y trata de restaurar la sesión guardada
  AuthNotifier() : super(null) {
    _loadUser();
  }

  // Restaura la sesión al reabrir la app usando el userId guardado en SharedPreferences
  void _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    if (userId != null) {
      final user = await _userRepository.getUserById(userId);
      if (mounted) state = user;
    }
  }

  // Valida credenciales contra SQLite; guarda userId en SharedPreferences si es correcto
  Future<String?> login(String email, String password) async {
    final user = await _userRepository.loginUser(email, password);
    if (user == null) return 'invalid_credentials';
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userId', user.id!);
    state = user;
    return null; // null indica que no hubo error
  }

  // Registra un nuevo usuario en SQLite y lo deja logueado automáticamente
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

  // Elimina el userId de SharedPreferences y limpia el estado (cierra sesión)
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    state = null;
  }
}
