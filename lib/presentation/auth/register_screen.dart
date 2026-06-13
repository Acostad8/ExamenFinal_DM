import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:examen_final/l10n/app_localizations.dart';
import 'package:examen_final/providers/auth_provider.dart';
import 'package:examen_final/providers/movimiento_provider.dart';

// Pantalla de registro de nuevo usuario
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController(); // Confirmación de contraseña
  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    // Libera todos los controladores al destruir el widget
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  // Valida el formulario y llama al provider para registrar al usuario
  void _register(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    final texts = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    final error = await ref.read(authProvider.notifier).register(
          _nameController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text,
        );

    if (!mounted) return;
    setState(() => _loading = false);

    if (error == null) {
      // Registro exitoso: carga movimientos del nuevo usuario y navega a finanzas
      final user = ref.read(authProvider);
      if (user != null) {
        ref.read(movimientoProvider.notifier).setUserId(user.id!);
      }
      messenger.showSnackBar(
        SnackBar(content: Text(texts.registeredSuccess)),
      );
      router.go('/finanzas');
    } else if (error == 'email_exists') {
      // El email ya está registrado
      messenger.showSnackBar(
        SnackBar(content: Text(texts.emailExists)),
      );
    } else {
      messenger.showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final texts = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Sección superior con ícono y título
            Expanded(
              flex: 1,
              child: Container(
                width: double.infinity,
                decoration:
                    BoxDecoration(color: theme.colorScheme.primary),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: Colors.white24,
                      child: Icon(
                        Icons.person_add_alt_1_rounded,
                        size: 40,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      texts.createAccount,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Sección con el formulario de registro
            Expanded(
              flex: 3,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      // Campo de nombre completo
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: texts.name,
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (v) => v == null || v.isEmpty
                            ? texts.nameRequired
                            : null,
                      ),
                      const SizedBox(height: 16),
                      // Campo de email con validación de formato
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: texts.email,
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
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
                      const SizedBox(height: 16),
                      // Campo de confirmación: valida que coincida con la contraseña
                      TextFormField(
                        controller: _confirmController,
                        obscureText: _obscureConfirm,
                        decoration: InputDecoration(
                          labelText: texts.confirmPassword,
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirm
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                            onPressed: () => setState(
                                () => _obscureConfirm = !_obscureConfirm),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return texts.passwordRequired;
                          }
                          // Verifica que ambas contraseñas sean iguales
                          if (v != _passwordController.text) {
                            return texts.passwordMustMatch;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 28),
                      // Botón de registro; muestra spinner mientras procesa
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: FilledButton.icon(
                          onPressed:
                              _loading ? null : () => _register(context),
                          icon: _loading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.person_add),
                          label: Text(
                            _loading ? '...' : texts.registerButton,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Enlace para volver al login si ya tiene cuenta
                      TextButton(
                        onPressed: () => context.go('/'),
                        child: Text(texts.alreadyHaveAccount),
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
