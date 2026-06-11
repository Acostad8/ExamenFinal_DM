import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:examen_final/l10n/app_localizations.dart';
import 'package:examen_final/presentation/drawer_custom.dart';
import 'package:examen_final/providers/language_provider.dart';
import 'package:examen_final/providers/theme_provider.dart';

class Layout extends ConsumerWidget {
  final Widget child;
  final String title;
  const Layout({super.key, required this.child, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeprovider);
    ref.watch(languageProvider);
    final texts = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(texts.financialManagement),
        actions: [
          IconButton(
            tooltip: isDark ? texts.darkMode : texts.lightMode,
            icon: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
            onPressed: () =>
                ref.read(themeprovider.notifier).toggleTheme(),
          ),
          IconButton(
            tooltip: texts.language,
            icon: const Icon(Icons.language),
            onPressed: () =>
                ref.read(languageProvider.notifier).toggleLanguage(),
          ),
        ],
      ),
      drawer: const DrawerCustom(),
      body: SafeArea(
        child: child,
      ),
    );
  }
}
