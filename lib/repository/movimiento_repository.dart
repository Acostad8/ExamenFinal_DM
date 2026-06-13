import 'package:examen_final/helper/database_helper.dart';
import 'package:examen_final/model/movimiento_model.dart';

class MovimientoRepository {
  final _db = DatabaseHelper();

  Future<int> insertMovimiento(MovimientoModel movimiento) async {
    final db = await _db.database;
    return await db.insert('movimientos', movimiento.toMap());
  }

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

  Future<int> updateMovimiento(MovimientoModel movimiento) async {
    final db = await _db.database;
    return await db.update(
      'movimientos',
      movimiento.toMap(),
      where: 'id = ?',
      whereArgs: [movimiento.id],
    );
  }

  Future<int> deleteMovimiento(int id) async {
    final db = await _db.database;
    return await db.delete(
      'movimientos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
