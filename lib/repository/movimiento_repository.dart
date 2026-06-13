import 'package:examen_final/helper/database_helper.dart';
import 'package:examen_final/model/movimiento_model.dart';

// Repositorio que maneja todas las operaciones CRUD de movimientos en SQLite
class MovimientoRepository {
  final _db = DatabaseHelper();

  // Inserta un nuevo movimiento y devuelve el id generado por SQLite
  Future<int> insertMovimiento(MovimientoModel movimiento) async {
    final db = await _db.database;
    return await db.insert('movimientos', movimiento.toMap());
  }

  // Devuelve todos los movimientos de un usuario, ordenados del más reciente al más antiguo
  Future<List<MovimientoModel>> selectMovimientos(int userId) async {
    final db = await _db.database;
    final result = await db.query(
      'movimientos',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'fecha DESC',
    );
    return result.map((m) => MovimientoModel.fromJson(m)).toList();
  }

  // Actualiza los datos de un movimiento existente según su id
  Future<int> updateMovimiento(MovimientoModel movimiento) async {
    final db = await _db.database;
    return await db.update(
      'movimientos',
      movimiento.toMap(),
      where: 'id = ?',
      whereArgs: [movimiento.id],
    );
  }

  // Elimina un movimiento por su id
  Future<int> deleteMovimiento(int id) async {
    final db = await _db.database;
    return await db.delete(
      'movimientos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
