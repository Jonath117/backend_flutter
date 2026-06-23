import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../viewmodels/settings_viewmodel.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes'),
      ),
      body: settingsState.when(
        data: (settings) {
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
              _buildSectionTitle(context, 'Apariencia'),
              SwitchListTile(
                title: const Text('Modo Oscuro'),
                subtitle: const Text('Cambia el tema visual de la aplicación'),
                secondary: const Icon(Icons.dark_mode_outlined),
                value: settings.isDarkMode,
                onChanged: (val) {
                  ref.read(settingsViewModelProvider.notifier).toggleTheme(val);
                },
              ),
              const Divider(),
              _buildSectionTitle(context, 'Preferencias Regionales'),
              ListTile(
                title: const Text('Moneda Principal'),
                subtitle: Text(settings.currency),
                leading: const Icon(Icons.attach_money),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _showCurrencyPicker(context, ref, settings.currency),
              ),
              const Divider(),
              _buildSectionTitle(context, 'Notificaciones'),
              SwitchListTile(
                title: const Text('Recordatorios'),
                subtitle: const Text('Recibe alertas para registrar tus gastos'),
                secondary: const Icon(Icons.notifications_active_outlined),
                value: settings.notificationsEnabled,
                onChanged: (val) {
                  ref.read(settingsViewModelProvider.notifier).toggleNotifications(val);
                },
              ),
              const SizedBox(height: 24),
              const Center(
                child: Text(
                  'Versión 1.0.0',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error al cargar ajustes: $err')),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8, top: 16),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  void _showCurrencyPicker(BuildContext context, WidgetRef ref, String currentCurrency) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final options = ['Bs.', 'USD', 'EUR'];
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Selecciona la Moneda',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ...options.map((currency) {
                return ListTile(
                  title: Text(currency),
                  trailing: currency == currentCurrency
                      ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                      : null,
                  onTap: () {
                    ref.read(settingsViewModelProvider.notifier).setCurrency(currency);
                    Navigator.pop(ctx);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
