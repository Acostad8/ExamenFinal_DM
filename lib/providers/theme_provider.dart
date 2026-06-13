import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Provider global que expone si el modo oscuro está activo (true = oscuro)
final themeprovider = StateNotifierProvider<ThemeNotifier, bool>((ref) {
  return ThemeNotifier();
});

// Notifier que persiste la preferencia de tema en SharedPreferences
class ThemeNotifier extends StateNotifier<bool> {
  // Inicia en modo claro y luego carga el valor guardado
  ThemeNotifier() : super(false) {
    _loadTheme();
  }

  // Lee el tema guardado en SharedPreferences al iniciar la app
  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool('isDark') ?? false;
  }

  // Alterna entre modo claro y oscuro, y guarda la preferencia
  void toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    state = !state;
    await prefs.setBool('isDark', state);
  }
}
