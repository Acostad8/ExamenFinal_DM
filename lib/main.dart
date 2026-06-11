import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:examen_final/config/router/router.dart';
import 'package:examen_final/config/theme/app_theme.dart';
import 'package:examen_final/l10n/app_localizations.dart';
import 'package:examen_final/providers/color_provider.dart';
import 'package:examen_final/providers/language_provider.dart';
import 'package:examen_final/providers/theme_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = ref.watch(colorChange);
    final isDark = ref.watch(themeprovider);
    final language = ref.watch(languageProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Gestor Financiero',
      theme: AppTheme(selectColor: color).themeData(isDark ? 1 : 0),
      routerConfig: router,
      locale: Locale(language),
      supportedLocales: const [Locale('es'), Locale('en')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
