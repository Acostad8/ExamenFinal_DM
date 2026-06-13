import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:examen_final/l10n/app_localizations.dart';
import 'package:examen_final/providers/auth_provider.dart';
import 'package:examen_final/providers/language_provider.dart';
import 'package:examen_final/providers/movimiento_provider.dart';
import 'package:examen_final/providers/theme_provider.dart';

// Pantalla de inicio de sesión
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;         // Controla el estado del botón durante la petición
  bool _obscurePassword = true;  // Controla si la contraseña se muestra o se oculta

  @override
  void dispose() {
    // Libera los controladores al destruir el widget para evitar fugas de memoria
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Valida el formulario y llama al provider para autenticar al usuario
  void _login(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    final texts = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    final error = await ref
        .read(authProvider.notifier)
        .login(_emailController.text.trim(), _passwordController.text);

    if (!mounted) return;
    setState(() => _loading = false);

    if (error == null) {
      // Login exitoso: carga los movimientos y navega a finanzas
      final user = ref.read(authProvider);
      if (user != null) {
        ref.read(movimientoProvider.notifier).setUserId(user.id!);
      }
      messenger.showSnackBar(
        SnackBar(content: Text(texts.loginSuccess)),
      );
      router.go('/finanzas');
    } else {
      // Credenciales incorrectas: muestra mensaje de error
      messenger.showSnackBar(
        SnackBar(content: Text(texts.loginError)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = ref.watch(themeprovider);
    final language = ref.watch(languageProvider);
    final texts = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Sección superior con logo y título de la app
            Expanded(
              flex: 2,
              child: Container(
                width: double.infinity,
                decoration:
                    BoxDecoration(color: theme.colorScheme.primary),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: Colors.white24,
                      child: Icon(
                        Icons.account_balance_wallet_rounded,
                        size: 52,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      texts.appTitle,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      texts.signInToContinue,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onPrimary
                            .withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Sección inferior con el formulario de login
            Expanded(
              flex: 3,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      // Campo de email con validación de formato
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: texts.email,
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return texts.emailRequired;
                          }
                          if (!v.contains('@')) return texts.emailInvalid;
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Campo de contraseña con opción de mostrar/ocultar
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: texts.password,
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                            onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        validator: (v) => v == null || v.isEmpty
                            ? texts.passwordRequired
                            : null,
                      ),
                      const SizedBox(height: 24),
                      // Botón de login; muestra spinner mientras procesa
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: FilledButton.icon(
                          onPressed: _loading ? null : () => _login(context),
                          icon: _loading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.login),
                          label: Text(
                            _loading ? '...' : texts.loginButton,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Enlace para ir a la pantalla de registro
                      TextButton(
                        onPressed: () => context.go('/register'),
                        child: Text(texts.createAccount),
                      ),
                      const SizedBox(height: 24),
                      // Botones de acceso rápido a tema e idioma desde el login
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              Text(
                                isDark ? texts.darkMode : texts.lightMode,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 6),
                              IconButton.filled(
                                onPressed: () => ref
                                    .read(themeprovider.notifier)
                                    .toggleTheme(),
                                icon: Icon(
                                  isDark
                                      ? Icons.dark_mode
                                      : Icons.light_mode,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                language == 'es' ? 'Español' : 'English',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 6),
                              IconButton.filled(
                                onPressed: () => ref
                                    .read(languageProvider.notifier)
                                    .toggleLanguage(),
                                icon: const Icon(Icons.language),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
