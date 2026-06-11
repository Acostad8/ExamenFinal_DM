import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:examen_final/config/router/router_config.dart';
import 'package:examen_final/l10n/app_localizations.dart';
import 'package:examen_final/providers/auth_provider.dart';
import 'package:examen_final/providers/language_provider.dart';
import 'package:examen_final/providers/movimiento_provider.dart';
import 'package:examen_final/providers/theme_provider.dart';

class DrawerCustom extends ConsumerWidget {
  const DrawerCustom({super.key});

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    ref.read(movimientoProvider.notifier).clear();
    await ref.read(authProvider.notifier).logout();
    if (!context.mounted) return;
    context.go('/');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final isDark = ref.watch(themeprovider);
    final language = ref.watch(languageProvider);
    final texts = AppLocalizations.of(context)!;

    return Drawer(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                Container(
                  height: 170,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: Colors.white24,
                        child: Icon(
                          Icons.person,
                          size: 36,
                          color: Theme.of(context).colorScheme.surface,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.nombre ?? '',
                              style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.surface,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user?.email ?? '',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                ...routerConfig.map((route) {
                  return ListTile(
                    iconColor: Theme.of(context).colorScheme.primary,
                    leading: const Icon(Icons.account_balance_wallet),
                    title: Text(texts.finances),
                    subtitle: Text(route.description),
                    trailing: const Icon(Icons.arrow_forward_ios_outlined),
                    onTap: () {
                      Navigator.pop(context);
                      context.go(route.path);
                    },
                  );
                }),
                const Divider(),
                ListTile(
                  iconColor: Theme.of(context).colorScheme.primary,
                  leading: Icon(
                      isDark ? Icons.dark_mode : Icons.light_mode),
                  title: Text(isDark ? texts.darkMode : texts.lightMode),
                  trailing: Switch(
                    value: isDark,
                    onChanged: (_) =>
                        ref.read(themeprovider.notifier).toggleTheme(),
                  ),
                ),
                ListTile(
                  iconColor: Theme.of(context).colorScheme.primary,
                  leading: const Icon(Icons.language),
                  title: Text(texts.language),
                  subtitle: Text(language == 'es' ? 'Español' : 'English'),
                  trailing: TextButton(
                    onPressed: () =>
                        ref.read(languageProvider.notifier).toggleLanguage(),
                    child: Text(language == 'es' ? 'EN' : 'ES'),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(
              Icons.logout,
              color: Theme.of(context).colorScheme.error,
            ),
            title: Text(
              texts.logout,
              style:
                  TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            onTap: () => _logout(context, ref),
          ),
        ],
      ),
    );
  }
}
