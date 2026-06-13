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
  //Inicializa el motor de Flutter antes de usar código que necesite acceso al framework 
  // (como SharedPreferences en el router). Esto asegura que todo esté listo antes de ejecutar la aplicación.
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MyApp()));
}

//consumer porque necesita escuchar los providers de riverpod para el cambio de tema, color y lenguaje.
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = ref.watch(colorChange);
    final isDark = ref.watch(themeprovider);
    final language = ref.watch(languageProvider);


    //MaterialApp.router es una variante de MaterialApp que se utiliza cuando se desea configurar 
    //la navegación utilizando un enrutador personalizado, como GoRouter.
    return MaterialApp.router(
      //Elimina el banner de depuración que aparece en la esquina de la aplicación cuando se ejecuta en modo debug.
      debugShowCheckedModeBanner: false,
      title: 'Gestor Financiero',
      //crea la instancia de ThemeData utilizando el método themeData de AppTheme, pasando el color seleccionado y el modo oscuro como parámetros.  
      theme: AppTheme(selectColor: color).themeData(isDark ? 1 : 0),
      routerConfig: router,
      
      //Establece el idioma de la aplicación utilizando el valor del provider languageProvider.
      locale: Locale(language),
      //Define los idiomas que la aplicación soporta.
      supportedLocales: const [Locale('es'), Locale('en')],
      //Agrega delegados de localización para manejar la traducción de la interfaz de usuario en diferentes idiomas. 
      //Esto incluye el delegado personalizado AppLocalizations y los delegados globales para Material, Widgets y Cupertino.
      localizationsDelegates: const [
        //AppLocalizations.delegate es el delegado personalizado que se encarga de cargar las traducciones específicas de la aplicación.
        AppLocalizations.delegate,
        //Los siguientes delegados son proporcionados por Flutter para manejar la localización de los widgets y componentes de la interfaz de usuario.
        GlobalMaterialLocalizations.delegate,
        //GlobalWidgetsLocalizations.delegate se encarga de la localización de los widgets básicos de Flutter, como textos, fechas, etc.
        GlobalWidgetsLocalizations.delegate,
        //GlobalCupertinoLocalizations.delegate se encarga de la localización de los widgets de estilo Cupertino, que son específicos para iOS.
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
