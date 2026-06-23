import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/routing/app_router.dart';
import 'package:finance_design_system/finance_design_system.dart';
import 'features/settings/presentation/viewmodels/settings_viewmodel.dart';

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final settingsState = ref.watch(settingsViewModelProvider);

    final isDarkMode = settingsState.maybeWhen(
      data: (settings) => settings.isDarkMode,
      orElse: () => false,
    );

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Expense Tracker',
      theme: FinanceTheme.lightTheme,
      darkTheme: FinanceTheme.darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      routerConfig: router,
    );
  }
}
