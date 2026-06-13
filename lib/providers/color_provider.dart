import 'package:riverpod/riverpod.dart';

// Notifier que gestiona el índice del color primario de la app
// 0 = verde, 1 = azul (según la lista en AppTheme)
class ColorProvider extends Notifier<int> {
  @override
  int build() => 0; // Color por defecto: verde

  // Cambia el color primario al índice recibido
  void changeValue(int value) {
    state = value;
  }
}

// Provider global que expone el índice de color seleccionado
final colorChange = NotifierProvider<ColorProvider, int>(() {
  return ColorProvider();
});
