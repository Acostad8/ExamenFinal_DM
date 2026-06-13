// ─── IMPORTACIONES ────────────────────────────────────────────────────────────
// DatabaseHelper: singleton que provee la conexión a SQLite
// UserModel: modelo de datos que representa un usuario registrado
import 'package:examen_final/helper/database_helper.dart';
import 'package:examen_final/model/user_model.dart';

// ─── REPOSITORIO DE USUARIOS ──────────────────────────────────────────────────
// Repositorio que maneja todas las operaciones CRUD de usuarios en SQLite.
// Es la única clase que habla directamente con la base de datos para usuarios;
// el AuthNotifier llama a este repositorio y nunca toca SQLite directamente.
class UserRepository {

  // ─── CONEXIÓN A LA BASE DE DATOS ──────────────────────────────────────────
  // Instancia del singleton DatabaseHelper que gestiona la conexión a SQLite.
  // Al ser singleton, siempre usa la misma conexión en toda la app.
  final _db = DatabaseHelper();

  // ─── INSERTAR USUARIO ─────────────────────────────────────────────────────
  // Inserta un nuevo usuario en la tabla 'users' y devuelve el id
  // generado automáticamente por SQLite (AUTOINCREMENT).
  // Equivale a: INSERT INTO users (nombre, email, password) VALUES (?, ?, ?)
  Future<int> insertUser(UserModel user) async {
    // obtiene la instancia activa de la base de datos
    final db = await _db.database;
    // toMap() convierte el modelo a un Map<String, dynamic> que SQLite entiende
    // el id NO se incluye en el Map porque SQLite lo genera automáticamente
    return await db.insert('users', user.toMap());
  }

  // ─── BUSCAR USUARIO PARA LOGIN ────────────────────────────────────────────
  // Busca en SQLite un usuario que tenga exactamente ese email Y esa password.
  // Devuelve el UserModel si las credenciales son correctas, o null si no coinciden.
  // Equivale a: SELECT * FROM users
  //             WHERE email = ? AND password = ?
  //             LIMIT 1
  Future<UserModel?> loginUser(String email, String password) async {
    final db = await _db.database;
    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?', // compara ambos campos a la vez
      whereArgs: [email, password],         // valores seguros que reemplazan los '?'
      limit: 1,                             // solo necesita encontrar uno
    );
    // si la lista está vacía, las credenciales no coincidieron con ningún usuario
    if (result.isEmpty) return null;
    // convierte la primera (y única) fila del resultado en un UserModel
    return UserModel.fromJson(result.first);
  }

  // ─── VERIFICAR EMAIL EXISTENTE ────────────────────────────────────────────
  // Verifica si ya existe un usuario registrado con ese email.
  // Devuelve true si el email ya está en uso, false si está disponible.
  // Se usa en el registro para evitar duplicados.
  // Equivale a: SELECT * FROM users WHERE email = ? LIMIT 1
  Future<bool> emailExists(String email) async {
    final db = await _db.database;
    final result = await db.query(
      'users',
      where: 'email = ?',   // filtra por email
      whereArgs: [email],    // valor seguro que reemplaza el '?'
      limit: 1,              // con encontrar uno es suficiente para saber si existe
    );
    // isNotEmpty = true si encontró al menos un usuario con ese email
    return result.isNotEmpty;
  }

  // ─── OBTENER USUARIO POR ID ───────────────────────────────────────────────
  // Busca un usuario en SQLite por su id.
  // Devuelve el UserModel si lo encuentra, o null si no existe.
  // Se usa al reabrir la app para restaurar la sesión usando el id
  // guardado en SharedPreferences.
  // Equivale a: SELECT * FROM users WHERE id = ? LIMIT 1
  Future<UserModel?> getUserById(int id) async {
    final db = await _db.database;
    final result = await db.query(
      'users',
      where: 'id = ?',   // filtra por id del usuario
      whereArgs: [id],    // valor seguro que reemplaza el '?'
      limit: 1,           // solo puede existir un usuario con ese id
    );
    // si la lista está vacía, no existe ningún usuario con ese id
    if (result.isEmpty) return null;
    // convierte la primera fila del resultado en un UserModel
    return UserModel.fromJson(result.first);
  }
}
