import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'main_layout.dart';
import '../../features/identity/presentation/views/login_view.dart';
import '../../features/categories/presentation/views/categories_view.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _sectionANavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'sectionANav',
);
final _sectionBNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'sectionBNav',
);
final _sectionCNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'sectionCNav',
);

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginView()),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainLayout(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _sectionANavigatorKey,
            routes: [
              GoRoute(
                path: '/expenses',
                builder: (context, state) => Scaffold(
                  appBar: AppBar(title: const Text('Mis Gastos')),
                  body: const Center(child: Text('Pantalla de Gastos')),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _sectionBNavigatorKey,
            routes: [
              GoRoute(
                path: '/categories',
                builder: (context, state) => Scaffold(
                  appBar: AppBar(title: const Text('Categorías')),
                  body: const CategoriesView(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _sectionCNavigatorKey,
            routes: [
              GoRoute(
                path: '/reports',
                builder: (context, state) => Scaffold(
                  appBar: AppBar(title: const Text('Dashboard')),
                  body: const Center(child: Text('Pantalla de Reportes')),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
