// ─── IMPORTACIONES ────────────────────────────────────────────────────────────
// legacy: versión anterior de Riverpod que usa StateNotifier
import 'package:flutter_riverpod/legacy.dart';

import 'package:examen_final/model/movimiento_model.dart';
import 'package:examen_final/repository/movimiento_repository.dart';

// ─── PROVIDER GLOBAL ──────────────────────────────────────────────────────────
// Provider global que expone la lista de movimientos del usuario activo.
// Cualquier widget que haga ref.watch(movimientoProvider) se reconstruye
// automáticamente cada vez que la lista cambia.
final movimientoProvider =
    StateNotifierProvider<MovimientoNotifier, List<MovimientoModel>>((ref) {
  return MovimientoNotifier();
});

// ─── NOTIFIER ─────────────────────────────────────────────────────────────────
// Notifier que gestiona el CRUD de movimientos y notifica a la UI de cada cambio.
// StateNotifier<List<MovimientoModel>> significa que el estado que maneja
// es una lista de movimientos.
class MovimientoNotifier extends StateNotifier<List<MovimientoModel>> {

  // ─── DEPENDENCIAS ───────────────────────────────────────────────────────────
  // Instancia del repositorio que se comunica directamente con SQLite
  final _repository = MovimientoRepository();

  // ID del usuario activo; null significa que aún no se ha asignado un usuario
  int? _userId;

  // ─── CONSTRUCTOR ────────────────────────────────────────────────────────────
  // Estado inicial: lista vacía hasta que se establezca el userId
  // super([]) le pasa la lista vacía como estado inicial al StateNotifier
  MovimientoNotifier() : super([]);

  // ─── ASIGNAque R USUARIO ────────────────────────────────────────────────────────
  // Asigna el usuario activo y carga sus movimientos desde SQLite.
  // Se llama desde la pantalla de finanzas al detectar el usuario logueado.
  void setUserId(int userId) {
    if (_userId == userId) return; // Evita recargas innecesarias si el usuario no cambió
    _userId = userId;
    loadMovimientos(); // carga los movimientos del nuevo usuario
  }

  // ─── CARGAR MOVIMIENTOS ──────────────────────────────────────────────────────
  // Consulta SQLite y actualiza el estado con los movimientos del usuario.
  // Al cambiar 'state', Riverpod notifica a todos los widgets que escuchan
  // este provider para que se reconstruyan con la nueva lista.
  Future<void> loadMovimientos() async {
    if (_userId == null) return; // no hace nada si no hay usuario asignado
    final movimientos = await _repository.selectMovimientos(_userId!);
    state = movimientos; // actualiza el estado → UI se reconstruye automáticamente
  }

  // ─── AGREGAR MOVIMIENTO ───────────────────────────────────────────────────────
  // Inserta un movimiento en SQLite y recarga la lista para reflejar el cambio en la UI.
  // Se llama cuando el usuario guarda un nuevo movimiento desde el modal.
  Future<void> addMovimiento(MovimientoModel movimiento) async {
    await _repository.insertMovimiento(movimiento); // INSERT en SQLite
    await loadMovimientos(); // recarga la lista actualizada
  }

  // ─── ACTUALIZAR MOVIMIENTO ────────────────────────────────────────────────────
  // Actualiza un movimiento existente en SQLite y recarga la lista.
  // Se llama cuando el usuario edita un movimiento desde el modal.
  Future<void> updateMovimiento(MovimientoModel movimiento) async {
    await _repository.updateMovimiento(movimiento); // UPDATE en SQLite
    await loadMovimientos(); // recarga la lista actualizada
  }

  // ─── ELIMINAR MOVIMIENTO ──────────────────────────────────────────────────────
  // Elimina un movimiento de SQLite por su id y recarga la lista.
  // Se llama cuando el usuario confirma la eliminación desde el diálogo de confirmación.
  Future<void> deleteMovimiento(int id) async {
    await _repository.deleteMovimiento(id); // DELETE en SQLite
    await loadMovimientos(); // recarga la lista actualizada
  }

  // ─── LIMPIAR ESTADO ───────────────────────────────────────────────────────────
  // Limpia el estado al cerrar sesión para que no queden datos del usuario anterior.
  // Resetea el userId a null y vacía la lista de movimientos.
  void clear() {
    _userId = null; // ya no hay usuario activo
    state = [];     // vacía la lista → la UI muestra el estado vacío
  }
}
