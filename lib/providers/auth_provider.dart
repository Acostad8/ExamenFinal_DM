// ─── IMPORTACIONES ────────────────────────────────────────────────────────────
// legacy: versión anterior de Riverpod que usa StateNotifier
import 'package:flutter_riverpod/legacy.dart';
// SharedPreferences: almacenamiento clave-valor para guardar la sesión activa
import 'package:shared_preferences/shared_preferences.dart';

import 'package:examen_final/model/user_model.dart';
import 'package:examen_final/repository/user_repository.dart';

// ─── PROVIDER GLOBAL ──────────────────────────────────────────────────────────
// Provider global que expone el usuario activo (UserModel) o null si no hay sesión.
// Cualquier widget que haga ref.watch(authProvider) se reconstruye automáticamente
// cuando el usuario inicia o cierra sesión.
final authProvider = StateNotifierProvider<AuthNotifier, UserModel?>((ref) {
  return AuthNotifier();
});

// ─── NOTIFIER ─────────────────────────────────────────────────────────────────
// Notifier que gestiona el estado de autenticación.
// StateNotifier<UserModel?> significa que el estado es un usuario o null.
class AuthNotifier extends StateNotifier<UserModel?> {

  // ─── DEPENDENCIAS ───────────────────────────────────────────────────────────
  // Instancia del repositorio que se comunica con SQLite para operaciones de usuario
  final _userRepository = UserRepository();

  // ─── CONSTRUCTOR ────────────────────────────────────────────────────────────
  // Inicia con null (sin sesión) y de inmediato intenta restaurar la sesión guardada.
  // super(null) establece el estado inicial como "sin usuario logueado"
  AuthNotifier() : super(null) {
    _loadUser();
  }

  // ─── RESTAURAR SESIÓN ────────────────────────────────────────────────────────
  // Al abrir la app, busca si hay un userId guardado en SharedPreferences.
  // Si existe, consulta SQLite para obtener los datos completos del usuario
  // y los carga en el estado, evitando que el usuario tenga que loguearse de nuevo.
  void _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId'); // lee el id guardado al iniciar sesión
    if (userId != null) {
      // busca el usuario en SQLite por su id
      final user = await _userRepository.getUserById(userId);
      // mounted verifica que el widget siga activo antes de actualizar el estado
      if (mounted) state = user;
    }
  }

  // ─── INICIAR SESIÓN ───────────────────────────────────────────────────────────
  // Valida las credenciales contra SQLite.
  // Si son correctas: guarda el userId en SharedPreferences y actualiza el estado.
  // Devuelve null si todo salió bien, o un código de error si falló.
  Future<String?> login(String email, String password) async {
    // busca en SQLite un usuario con ese email y password
    final user = await _userRepository.loginUser(email, password);

    // si no encontró ningún usuario, retorna el código de error
    if (user == null) return 'invalid_credentials';

    // guarda el userId en SharedPreferences para restaurar la sesión al reabrir la app
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userId', user.id!);

    // actualiza el estado con el usuario logueado → UI se reconstruye
    state = user;
    return null; // null indica que no hubo error
  }

  // ─── REGISTRAR USUARIO ────────────────────────────────────────────────────────
  // Crea un nuevo usuario en SQLite y lo deja logueado automáticamente.
  // Primero verifica que el email no esté ya registrado.
  // Devuelve null si todo salió bien, o un código de error si falló.
  Future<String?> register(
      String nombre, String email, String password) async {

    // verifica en SQLite si ya existe un usuario con ese email
    final exists = await _userRepository.emailExists(email);
    if (exists) return 'email_exists'; // retorna error si el email ya está registrado

    // crea el modelo sin id (SQLite lo asigna automáticamente con AUTOINCREMENT)
    final userModel =
        UserModel(nombre: nombre, email: email, password: password);

    // inserta el usuario en SQLite y obtiene el id generado
    final id = await _userRepository.insertUser(userModel);

    // reconstruye el modelo completo con el id asignado por SQLite
    final savedUser =
        UserModel(id: id, nombre: nombre, email: email, password: password);

    // guarda el userId en SharedPreferences para restaurar la sesión al reabrir la app
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userId', id);

    // actualiza el estado con el nuevo usuario → UI se reconstruye
    state = savedUser;
    return null; // null indica que no hubo error
  }

  // ─── CERRAR SESIÓN ────────────────────────────────────────────────────────────
  // Elimina el userId de SharedPreferences y limpia el estado.
  // Al poner state = null, el router detecta que no hay sesión y redirige al login.
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId'); // borra la sesión guardada
    state = null; // limpia el usuario del estado → UI se reconstruye sin sesión
  }
}
