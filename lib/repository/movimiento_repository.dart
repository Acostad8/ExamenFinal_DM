import 'dart:convert';

import 'package:examen_final/model/movimiento_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MovimientoRepository {
  static const _key = 'ef_movimientos';

  Future<List<MovimientoModel>> _getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    final List list = jsonDecode(raw);
    return list
        .map((m) => MovimientoModel.fromJson(Map<String, dynamic>.from(m)))
        .toList();
  }

  Future<void> _saveAll(List<MovimientoModel> movimientos) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _key, jsonEncode(movimientos.map((m) => m.toMap()).toList()));
  }

  Future<int> insertMovimiento(MovimientoModel movimiento) async {
    final all = await _getAll();
    final id = all.isEmpty
        ? 1
        : all.map((m) => m.id!).reduce((a, b) => a > b ? a : b) + 1;
    all.add(MovimientoModel(
      id: id,
      userId: movimiento.userId,
      tipo: movimiento.tipo,
      descripcion: movimiento.descripcion,
      valor: movimiento.valor,
      fecha: movimiento.fecha,
    ));
    await _saveAll(all);
    return id;
  }

  Future<List<MovimientoModel>> selectMovimientos(int userId) async {
    final all = await _getAll();
    final filtered =
        all.where((m) => m.userId == userId).toList();
    filtered.sort((a, b) => b.fecha.compareTo(a.fecha));
    return filtered;
  }

  Future<int> deleteMovimiento(int id) async {
    final all = await _getAll();
    all.removeWhere((m) => m.id == id);
    await _saveAll(all);
    return 1;
  }

  Future<int> updateMovimiento(MovimientoModel movimiento) async {
    final all = await _getAll();
    final index = all.indexWhere((m) => m.id == movimiento.id);
    if (index == -1) return 0;
    all[index] = movimiento;
    await _saveAll(all);
    return 1;
  }
}
