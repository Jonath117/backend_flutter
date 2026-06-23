import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'main_layout.dart';
import '../../features/identity/presentation/views/login_view.dart';
import '../../features/categories/presentation/views/categories_view.dart';
import '../../features/expenses/presentation/views/expenses_list_view.dart';
import '../../features/expenses/presentation/views/create_expense_view.dart';
import '../../features/expenses/presentation/views/edit_expense_view.dart';
import '../../features/expenses/presentation/views/expense_detail_view.dart';
import '../../features/expenses/data/models/expense_model.dart';
import '../../features/reporting/presentation/views/reporting_dashboard_view.dart';
import '../../features/reporting/presentation/views/create_budget_view.dart';
import '../../features/reporting/presentation/views/create_goal_view.dart';
import '../../features/reporting/presentation/views/budget_detail_view.dart';
import '../../features/reporting/data/models/budget_model.dart';
import '../../features/reporting/presentation/views/advanced_charts_view.dart';
import '../../features/identity/presentation/views/profile_view.dart';
import '../../features/settings/presentation/views/settings_view.dart';

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
final _sectionDNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'sectionDNav',
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
                builder: (context, state) => const ExpensesListView(),
                routes: [
                  GoRoute(
                    path: 'create',
                    builder: (context, state) => const CreateExpenseView(),
                  ),
                  GoRoute(
                    path: 'edit',
                    builder: (context, state) {
                      final extra = state.extra;
                      final expense = extra is ExpenseModel
                          ? extra
                          : ExpenseModel.fromJson(
                              Map<String, dynamic>.from(extra as Map),
                            );
                      return EditExpenseView(expense: expense);
                    },
                  ),
                  GoRoute(
                    path: 'detail',
                    builder: (context, state) {
                      final extra = state.extra;
                      final expense = extra is ExpenseModel
                          ? extra
                          : ExpenseModel.fromJson(
                              Map<String, dynamic>.from(extra as Map),
                            );
                      return ExpenseDetailView(expense: expense);
                    },
                  ),
                ],
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
                builder: (context, state) => const ReportingDashboardView(),
                routes: [
                  GoRoute(
                    path: 'budgets/create',
                    builder: (context, state) => const CreateBudgetView(),
                  ),
                  GoRoute(
                    path: 'budgets/detail',
                    builder: (context, state) {
                      final extra = state.extra;
                      final budget = extra is BudgetModel
                          ? extra
                          : BudgetModel.fromJson(
                              Map<String, dynamic>.from(extra as Map),
                            );
                      return BudgetDetailView(budget: budget);
                    },
                  ),
                  GoRoute(
                    path: 'goals/create',
                    builder: (context, state) => const CreateGoalView(),
                  ),
                  GoRoute(
                    path: 'charts',
                    builder: (context, state) => const AdvancedChartsView(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _sectionDNavigatorKey,
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileView(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsView(),
      ),
      GoRoute(
        path: '/nuevo',
        redirect: (context, state) => '/expenses/create',
      ),
    ],
  );
});
