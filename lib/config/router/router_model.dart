import 'package:go_router/go_router.dart';

// Modelo de datos que define una ruta de la aplicación
class RouterModel {
  String name;        // Nombre identificador de la ruta
  String title;       // Título mostrado en la AppBar
  String description; // Descripción corta (usada en el Drawer)
  String path;        // Ruta URL (ej: '/finanzas')
  GoRouterWidgetBuilder widget; // Función que construye la pantalla

  RouterModel({
    required this.name,
    required this.title,
    required this.description,
    required this.path,
    required this.widget,
  });
}
