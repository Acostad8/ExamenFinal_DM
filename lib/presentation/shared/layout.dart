import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:examen_final/l10n/app_localizations.dart';
import 'package:examen_final/presentation/drawer_custom.dart';
import 'package:examen_final/providers/language_provider.dart';
import 'package:examen_final/providers/theme_provider.dart';

// Layout compartido que envuelve todas las pantallas protegidas
// Provee AppBar con acciones rápidas y el Drawer lateral
class Layout extends ConsumerWidget {
  final Widget child; // Pantalla activa que se renderiza en el body
  final String title;
  const Layout({super.key, required this.child, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeprovider);
    ref.watch(languageProvider); // Escucha cambios de idioma para reconstruir
    final texts = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(texts.financialManagement),
        actions: [
          // Botón de alternancia de tema claro/oscuro
          IconButton(
            tooltip: isDark ? texts.darkMode : texts.lightMode,
            icon: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
            onPressed: () =>
                ref.read(themeprovider.notifier).toggleTheme(),
          ),
          // Botón de alternancia de idioma
          IconButton(
            tooltip: texts.language,
            icon: const Icon(Icons.language),
            onPressed: () =>
                ref.read(languageProvider.notifier).toggleLanguage(),
          ),
        ],
      ),
      drawer: const DrawerCustom(),
      // SafeArea evita que el contenido quede detrás de notch o barras del sistema
      body: SafeArea(
        child: child,
      ),
    );
  }
}
