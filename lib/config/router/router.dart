import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:examen_final/config/router/router_config.dart';
import 'package:examen_final/presentation/auth/login_screen.dart';
import 'package:examen_final/presentation/auth/register_screen.dart';
import 'package:examen_final/presentation/shared/layout.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',

  redirect: (context, state) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    final isPublicRoute = state.matchedLocation == '/' ||
        state.matchedLocation == '/register';

    if (userId == null && !isPublicRoute) return '/';
    if (userId != null && state.matchedLocation == '/') return '/finanzas';

    return null;
  },

  routes: [
    GoRoute(
      path: '/',
      name: 'Login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      name: 'Register',
      builder: (context, state) => const RegisterScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) {
        final title = state.topRoute?.name ?? 'App';
        return Layout(title: title, child: child);
      },
      routes: [
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

  errorBuilder: (context, state) => const LoginScreen(),
);
