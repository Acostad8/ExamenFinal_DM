import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// Clase singleton que gestiona la conexión a la base de datos SQLite
class DatabaseHelper {
  // Instancia única compartida en toda la app (patrón Singleton)
  static final DatabaseHelper _instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // Devuelve siempre la misma instancia
  factory DatabaseHelper() => _instance;

  // Crea las tablas cuando la base de datos se inicializa por primera vez
  Future<void> _createDatabase(Database db, int version) async {
    // Tabla de usuarios registrados
    await db.execute('''
      CREATE TABLE users (
        id       INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre   TEXT    NOT NULL,
        email    TEXT    NOT NULL UNIQUE,
        password TEXT    NOT NULL
      )
    ''');

    // Tabla de movimientos financieros vinculados a un usuario
    await db.execute('''
      CREATE TABLE movimientos (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id     INTEGER NOT NULL,
        tipo        TEXT    NOT NULL,
        descripcion TEXT    NOT NULL,
        valor       REAL    NOT NULL,
        fecha       TEXT    NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');
  }

  // Abre (o crea) el archivo de base de datos en el almacenamiento del dispositivo
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return openDatabase(path, version: 1, onCreate: _createDatabase);
  }

  // Getter que devuelve la instancia de la BD, inicializándola solo la primera vez
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('examen_final.db');
    return _database!;
  }

  // Cierra la conexión y limpia la referencia
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
