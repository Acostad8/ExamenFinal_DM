import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Provider global que expone el código del idioma activo ('es' o 'en')
final languageProvider = StateNotifierProvider<LanguageNotifier, String>((ref) {
  return LanguageNotifier();
});

// Notifier que persiste el idioma seleccionado en SharedPreferences
class LanguageNotifier extends StateNotifier<String> {
  // Inicia en español y luego carga el valor guardado
  LanguageNotifier() : super('es') {
    _loadLanguage();
  }

  // Lee el idioma guardado en SharedPreferences al iniciar la app
  void _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString('language') ?? 'es';
  }

  // Alterna entre español e inglés, y guarda la preferencia
  void toggleLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    state = state == 'es' ? 'en' : 'es';
    await prefs.setString('language', state);
  }
}
