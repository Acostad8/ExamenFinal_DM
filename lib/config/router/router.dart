import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:examen_final/config/router/router_config.dart';
import 'package:examen_final/presentation/auth/login_screen.dart';
import 'package:examen_final/presentation/auth/register_screen.dart';
import 'package:examen_final/presentation/shared/layout.dart';

// Configuración central de navegación con go_router
final GoRouter router = GoRouter(
  initialLocation: '/',

  // Redirección automática según el estado de sesión
  redirect: (context, state) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    final isPublicRoute = state.matchedLocation == '/' ||
        state.matchedLocation == '/register';

    // Sin sesión intentando acceder a ruta protegida → login
    if (userId == null && !isPublicRoute) return '/';
    // Con sesión intentando ir al login → pantalla principal
    if (userId != null && state.matchedLocation == '/') return '/finanzas';

    return null; // Sin redirección, la navegación procede normalmente
  },

  routes: [
    // Ruta pública: Login
    GoRoute(
      path: '/',
      name: 'Login',
      builder: (context, state) => const LoginScreen(),
    ),
    // Ruta pública: Registro
    GoRoute(
      path: '/register',
      name: 'Register',
      builder: (context, state) => const RegisterScreen(),
    ),
    // ShellRoute: envuelve las rutas protegidas con el Layout compartido (AppBar + Drawer)
    ShellRoute(
      builder: (context, state, child) {
        final title = state.topRoute?.name ?? 'App';
        return Layout(title: title, child: child);
      },
      routes: [
        // Genera automáticamente las rutas definidas en router_config.dart
        ...routerConfig.map(
          (route) => GoRoute(
            path: route.path,
            name: route.name,
            builder: route.widget,
          ),
        ),
      ],
    ),
  ],

  // Si ocurre un error de navegación, redirige al login
  errorBuilder: (context, state) => const LoginScreen(),
);
