// ─── IMPORTACIONES ────────────────────────────────────────────────────────────
// DatabaseHelper: singleton que provee la conexión a SQLite
// MovimientoModel: modelo de datos que representa un movimiento financiero
import 'package:examen_final/helper/database_helper.dart';
import 'package:examen_final/model/movimiento_model.dart';

// ─── REPOSITORIO DE MOVIMIENTOS ───────────────────────────────────────────────
// Repositorio que maneja todas las operaciones CRUD de movimientos en SQLite.
// Es la única clase que habla directamente con la base de datos para movimientos;
// el provider llama a este repositorio y nunca toca SQLite directamente.
class MovimientoRepository {

  // ─── CONEXIÓN A LA BASE DE DATOS ──────────────────────────────────────────
  // Instancia del singleton DatabaseHelper que gestiona la conexión a SQLite.
  // Al ser singleton, siempre usa la misma conexión en toda la app.
  final _db = DatabaseHelper();

  // ─── INSERTAR MOVIMIENTO ───────────────────────────────────────────────────
  // Inserta un nuevo movimiento en la tabla 'movimientos' y devuelve el id
  // generado automáticamente por SQLite (AUTOINCREMENT).
  // Equivale a: INSERT INTO movimientos (user_id, tipo, descripcion, valor, fecha)
  //             VALUES (?, ?, ?, ?, ?)
  Future<int> insertMovimiento(MovimientoModel movimiento) async {
    // obtiene la instancia activa de la base de datos
    final db = await _db.database;
    // toMap() convierte el modelo a un Map<String, dynamic> que SQLite entiende
    return await db.insert('movimientos', movimiento.toMap());
  }

  // ─── CONSULTAR MOVIMIENTOS ─────────────────────────────────────────────────
  // Devuelve todos los movimientos de un usuario específico, ordenados del
  // más reciente al más antiguo (fecha DESC = descendente).
  // Equivale a: SELECT * FROM movimientos
  //             WHERE user_id = ?
  //             ORDER BY fecha DESC
  Future<List<MovimientoModel>> selectMovimientos(int userId) async {
    final db = await _db.database;
    final result = await db.query(
      'movimientos',
      where: 'user_id = ?',       // filtra solo los movimientos del usuario activo
      whereArgs: [userId],         // valor seguro que reemplaza el '?' (evita SQL injection)
      orderBy: 'fecha DESC',       // el más reciente aparece primero en la lista
    );
    // convierte cada fila del resultado (Map) en un MovimientoModel
    // result es una List<Map<String,dynamic>>, se mapea a List<MovimientoModel>
    return result.map((m) => MovimientoModel.fromJson(m)).toList();
  }

  // ─── ACTUALIZAR MOVIMIENTO ─────────────────────────────────────────────────
  // Actualiza los datos de un movimiento existente buscándolo por su id.
  // Devuelve el número de filas afectadas (1 si tuvo éxito, 0 si no encontró el id).
  // Equivale a: UPDATE movimientos
  //             SET tipo=?, descripcion=?, valor=?, fecha=?
  //             WHERE id = ?
  Future<int> updateMovimiento(MovimientoModel movimiento) async {
    final db = await _db.database;
    return await db.update(
      'movimientos',
      movimiento.toMap(),          // nuevos valores a guardar
      where: 'id = ?',             // condición: solo actualiza el movimiento con ese id
      whereArgs: [movimiento.id],  // id del movimiento a actualizar
    );
  }

  // ─── ELIMINAR MOVIMIENTO ───────────────────────────────────────────────────
  // Elimina un movimiento de la tabla buscándolo por su id.
  // Devuelve el número de filas eliminadas (1 si tuvo éxito, 0 si no encontró el id).
  // Equivale a: DELETE FROM movimientos WHERE id = ?
  Future<int> deleteMovimiento(int id) async {
    final db = await _db.database;
    return await db.delete(
      'movimientos',
      where: 'id = ?',   // condición: solo elimina el movimiento con ese id
      whereArgs: [id],   // valor seguro que reemplaza el '?'
    );
  }
}
