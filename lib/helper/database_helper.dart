// ─── IMPORTACIONES ────────────────────────────────────────────────────────────
// path: utilidad para construir rutas de archivos de forma segura
// sqflite: paquete que permite usar SQLite en Flutter
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// ─── CLASE DATABASEHELPER ─────────────────────────────────────────────────────
// Clase singleton que gestiona la conexión a la base de datos SQLite.
// Al ser singleton, garantiza que solo exista UNA conexión activa en toda la app,
// evitando conflictos si varios lugares intentan acceder a la BD al mismo tiempo.
class DatabaseHelper {

  // ─── PATRÓN SINGLETON ─────────────────────────────────────────────────────
  // Instancia única creada una sola vez cuando se carga la clase.
  // static significa que pertenece a la clase, no a un objeto específico.
  static final DatabaseHelper _instance = DatabaseHelper._init();

  // Referencia a la base de datos activa; null si aún no se ha inicializado
  static Database? _database;

  // Constructor privado: impide crear instancias con DatabaseHelper()
  // Solo se puede usar internamente para crear la instancia única
  DatabaseHelper._init();

  // ─── ACCESO A LA INSTANCIA ────────────────────────────────────────────────
  // factory constructor: cada vez que alguien escribe DatabaseHelper()
  // no crea un objeto nuevo sino que devuelve siempre la misma instancia (_instance)
  factory DatabaseHelper() => _instance;

  // ─── CREACIÓN DE TABLAS ───────────────────────────────────────────────────
  // Crea las tablas cuando la base de datos se inicializa por primera vez.
  // onCreate es un callback: sqflite lo llama automáticamente solo cuando
  // el archivo .db no existe todavía (primera apertura de la app).
  // Después de eso, nunca más se vuelve a ejecutar.
  Future<void> _createDatabase(Database db, int version) async {

    // ─── TABLA USERS ──────────────────────────────────────────────────────
    // Almacena los usuarios registrados en la app
    // INTEGER PRIMARY KEY AUTOINCREMENT: id único generado automáticamente por SQLite
    // NOT NULL: el campo es obligatorio, no puede quedar vacío
    // UNIQUE: no pueden existir dos usuarios con el mismo email
    await db.execute('''
      CREATE TABLE users (
        id       INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre   TEXT    NOT NULL,
        email    TEXT    NOT NULL UNIQUE,
        password TEXT    NOT NULL
      )
    ''');

    // ─── TABLA MOVIMIENTOS ─────────────────────────────────────────────────
    // Almacena los movimientos financieros (ingresos y gastos) de cada usuario
    // REAL: tipo de dato para números decimales (ej: 500.50)
    // FOREIGN KEY: relaciona cada movimiento con su usuario dueño en la tabla users
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

  // ─── INICIALIZAR BASE DE DATOS ────────────────────────────────────────────
  // Construye la ruta completa del archivo .db y lo abre.
  // getDatabasesPath(): devuelve la carpeta donde SQLite guarda sus archivos en el SO
  // join(): une la carpeta con el nombre del archivo de forma segura
  // openDatabase(): abre el archivo si existe, o lo crea si no existe
  //   - version: número de versión de la BD (útil para migraciones futuras)
  //   - onCreate: función que se ejecuta solo la primera vez que se crea el archivo
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath(); // carpeta del sistema para bases de datos
    final path = join(dbPath, filePath);     // ruta completa: carpeta + nombre del archivo
    return openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase, // solo se llama si el archivo .db no existía
    );
  }

  // ─── GETTER DE LA BASE DE DATOS ───────────────────────────────────────────
  // Punto de acceso principal a la BD desde los repositorios.
  // Si _database ya tiene valor, lo devuelve directamente (ya fue inicializada).
  // Si _database es null, la inicializa por primera vez y la guarda para reusar.
  // Esto garantiza que la inicialización solo ocurra una vez en todo el ciclo de vida.
  Future<Database> get database async {
    if (_database != null) return _database!; // ya inicializada → la devuelve directo
    _database = await _initDB('examen_final.db'); // primera vez → la inicializa
    return _database!;
  }

  // ─── CERRAR CONEXIÓN ──────────────────────────────────────────────────────
  // Cierra la conexión activa con SQLite y limpia la referencia.
  // Se llama cuando la app ya no necesita acceder a la BD,
  // liberando los recursos del sistema operativo.
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();  // cierra la conexión con el archivo .db
      _database = null;  // limpia la referencia para que pueda reiniciarse si es necesario
    }
  }
}
