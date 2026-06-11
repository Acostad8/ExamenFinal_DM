import 'package:flutter_riverpod/legacy.dart';

import 'package:examen_final/model/movimiento_model.dart';
import 'package:examen_final/repository/movimiento_repository.dart';

final movimientoProvider =
    StateNotifierProvider<MovimientoNotifier, List<MovimientoModel>>((ref) {
  return MovimientoNotifier();
});

class MovimientoNotifier extends StateNotifier<List<MovimientoModel>> {
  final _repository = MovimientoRepository();
  int? _userId;

  MovimientoNotifier() : super([]);

  void setUserId(int userId) {
    if (_userId == userId) return;
    _userId = userId;
    loadMovimientos();
  }

  Future<void> loadMovimientos() async {
    if (_userId == null) return;
    final movimientos = await _repository.selectMovimientos(_userId!);
    state = movimientos;
  }

  Future<void> addMovimiento(MovimientoModel movimiento) async {
    await _repository.insertMovimiento(movimiento);
    await loadMovimientos();
  }

  Future<void> updateMovimiento(MovimientoModel movimiento) async {
    await _repository.updateMovimiento(movimiento);
    await loadMovimientos();
  }

  Future<void> deleteMovimiento(int id) async {
    await _repository.deleteMovimiento(id);
    await loadMovimientos();
  }

  void clear() {
    _userId = null;
    state = [];
  }
}
