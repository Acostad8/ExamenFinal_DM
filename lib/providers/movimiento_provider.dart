import 'package:flutter_riverpod/legacy.dart';

import 'package:examen_final/model/movimiento_model.dart';
import 'package:examen_final/repository/movimiento_repository.dart';

// Provider global que expone la lista de movimientos del usuario activo
final movimientoProvider =
    StateNotifierProvider<MovimientoNotifier, List<MovimientoModel>>((ref) {
  return MovimientoNotifier();
});

// Notifier que gestiona el CRUD de movimientos y notifica a la UI de cada cambio
class MovimientoNotifier extends StateNotifier<List<MovimientoModel>> {
  final _repository = MovimientoRepository();
  int? _userId;

  // Estado inicial: lista vacía hasta que se establezca el userId
  MovimientoNotifier() : super([]);

  // Asigna el usuario activo y carga sus movimientos desde SQLite
  void setUserId(int userId) {
    if (_userId == userId) return; // Evita recargas innecesarias
    _userId = userId;
    loadMovimientos();
  }

  // Consulta SQLite y actualiza el estado con los movimientos del usuario
  Future<void> loadMovimientos() async {
    if (_userId == null) return;
    final movimientos = await _repository.selectMovimientos(_userId!);
    state = movimientos;
  }

  // Inserta un movimiento en SQLite y recarga la lista
  Future<void> addMovimiento(MovimientoModel movimiento) async {
    await _repository.insertMovimiento(movimiento);
    await loadMovimientos();
  }

  // Actualiza un movimiento en SQLite y recarga la lista
  Future<void> updateMovimiento(MovimientoModel movimiento) async {
    await _repository.updateMovimiento(movimiento);
    await loadMovimientos();
  }

  // Elimina un movimiento de SQLite y recarga la lista
  Future<void> deleteMovimiento(int id) async {
    await _repository.deleteMovimiento(id);
    await loadMovimientos();
  }

  // Limpia el estado al cerrar sesión para que no queden datos del usuario anterior
  void clear() {
    _userId = null;
    state = [];
  }
}
