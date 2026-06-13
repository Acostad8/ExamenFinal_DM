import 'package:examen_final/config/router/router_model.dart';
import 'package:examen_final/presentation/screen/finanzas/finanzas_screen.dart';

// Lista de rutas protegidas (requieren sesión activa)
// Cada entrada genera automáticamente un GoRoute y un item en el Drawer
List<RouterModel> routerConfig = [
  RouterModel(
    name: 'Finanzas',
    title: 'Gestión Financiera',
    description: 'Gestiona tus ingresos y gastos',
    path: '/finanzas',
    widget: (context, state) => const FinanzasScreen(),
  ),
];
