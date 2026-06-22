import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../expenses/presentation/viewmodels/expenses_viewmodel.dart';
import '../viewmodels/reporting_viewmodel.dart';

class ReportingDashboardView extends ConsumerWidget {
  const ReportingDashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetsState = ref.watch(budgetsViewModelProvider);
    final goalsState = ref.watch(goalsViewModelProvider);
    final expensesState = ref.watch(expensesViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Reportes y Presupuestos')),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Mis Presupuestos',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle),
                    color: Theme.of(context).colorScheme.primary,
                    onPressed: () => context.push('/reports/budgets/create'),
                  ),
                ],
              ),
            ),
          ),
          budgetsState.when(
            data: (budgets) {
              if (budgets.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('No tienes presupuestos.'),
                    ),
                  ),
                );
              }
              final expenses = expensesState.maybeWhen(
                data: (expenses) => expenses,
                orElse: () => [],
              );

              return SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final budget = budgets[index];

                  // Lógica para descontar gastos del presupuesto
                  final spentAmount = expenses
                      // TODO: Si categoryIds se guarda/compara. Como aún no lo llenamos, podríamos calcular por total o por categoría
                      // temporalmente sumamos todos los gastos si no hay filtro de categoría en budget.
                      .where(
                        (e) =>
                            budget.categoryIds.isEmpty ||
                            budget.categoryIds.contains(e.categoryId),
                      )
                      .fold(0.0, (sum, e) => sum + e.amount);

                  final remaining = budget.monthlyLimit - spentAmount;
                  final isNegative = remaining < 0;

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                budget.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => ref
                                    .read(budgetsViewModelProvider.notifier)
                                    .deleteBudget(budget.id),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Límite Mensual: \$${budget.monthlyLimit.toStringAsFixed(2)}',
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Gastado: \$${spentAmount.toStringAsFixed(2)}',
                            style: const TextStyle(color: Colors.orange),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Text(
                                'Restante: ',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '\$${remaining.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isNegative ? Colors.red : Colors.green,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }, childCount: budgets.length),
              );
            },
            loading: () => const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) =>
                SliverToBoxAdapter(child: Center(child: Text('Error: $e'))),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Mis Metas de Ahorro',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle),
                    color: Theme.of(context).colorScheme.primary,
                    onPressed: () => context.push('/reports/goals/create'),
                  ),
                ],
              ),
            ),
          ),
          goalsState.when(
            data: (goals) {
              if (goals.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('No tienes metas definidas.'),
                    ),
                  ),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final goal = goals[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ListTile(
                      title: Text(
                        goal.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Objetivo: \$${goal.targetAmount.toStringAsFixed(2)}\n'
                        'Actual: \$${goal.currentAmount.toStringAsFixed(2)}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => ref
                            .read(goalsViewModelProvider.notifier)
                            .deleteGoal(goal.id),
                      ),
                    ),
                  );
                }, childCount: goals.length),
              );
            },
            loading: () => const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) =>
                SliverToBoxAdapter(child: Center(child: Text('Error: $e'))),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}
