import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../expenses/presentation/viewmodels/expenses_viewmodel.dart';
import '../viewmodels/reporting_viewmodel.dart';

class ReportingDashboardView extends ConsumerWidget {
  const ReportingDashboardView({super.key});

  void _showFundsDialog(
    BuildContext context,
    WidgetRef ref,
    String goalId,
    bool isAdd,
  ) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isAdd ? 'Añadir Fondos' : 'Retirar Fondos'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Monto'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(controller.text) ?? 0;
              if (amount > 0) {
                if (isAdd) {
                  ref
                      .read(goalsViewModelProvider.notifier)
                      .addFundsToGoal(goalId, amount);
                } else {
                  ref
                      .read(goalsViewModelProvider.notifier)
                      .withdrawFundsFromGoal(goalId, amount);
                }
              }
              Navigator.pop(ctx);
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetsState = ref.watch(budgetsViewModelProvider);
    final goalsState = ref.watch(goalsViewModelProvider);
    final expensesState = ref.watch(expensesViewModelProvider);

    final dateFormat = DateFormat.yMMMd('es');

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
                data: (e) => e,
                orElse: () => [],
              );

              return SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final budget = budgets[index];

                  final spentAmount = expenses
                      .where((e) {
                        if (budget.categoryIds.isNotEmpty &&
                            !budget.categoryIds.contains(e.categoryId)) {
                          return false;
                        }
                        final eDate = e.expenseDate;
                        if (eDate.isBefore(budget.startDate)) return false;
                        if (budget.endDate != null &&
                            eDate.isAfter(budget.endDate!)) {
                          return false;
                        }
                        return true;
                      })
                      .fold(0.0, (sum, e) => sum + e.amount);

                  final remaining = budget.monthlyLimit - spentAmount;
                  final isNegative = remaining < 0;

                  final percentage = (spentAmount / budget.monthlyLimit).clamp(
                    0.0,
                    1.0,
                  );
                  Color progressColor = Colors.green;
                  if (percentage >= 0.9) {
                    progressColor = Colors.red;
                    // ignore: curly_braces_in_flow_control_structures
                  } else if (percentage >= 0.7)
                    // ignore: curly_braces_in_flow_control_structures
                    progressColor = Colors.orange;

                  final dateRangeStr = budget.endDate != null
                      ? '${dateFormat.format(budget.startDate)} - ${dateFormat.format(budget.endDate!)}'
                      : 'Desde ${dateFormat.format(budget.startDate)}';

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
                              Expanded(
                                child: Text(
                                  budget.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
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
                          Text(
                            dateRangeStr,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 12),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Gastado: \$${spentAmount.toStringAsFixed(2)}',
                              ),
                              Text(
                                'Límite: \$${budget.monthlyLimit.toStringAsFixed(2)}',
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: percentage,
                            color: progressColor,
                            backgroundColor: Colors.grey.shade300,
                            minHeight: 8,
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
                  final p = (goal.currentAmount / goal.targetAmount).clamp(
                    0.0,
                    1.0,
                  );

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
                                goal.name,
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
                                    .read(goalsViewModelProvider.notifier)
                                    .deleteGoal(goal.id),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Progreso: \$${goal.currentAmount.toStringAsFixed(2)} de \$${goal.targetAmount.toStringAsFixed(2)}',
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: p,
                            minHeight: 8,
                            color: Colors.blue,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              OutlinedButton.icon(
                                icon: const Icon(
                                  Icons.remove,
                                  color: Colors.red,
                                ),
                                label: const Text('Retirar'),
                                onPressed: () => _showFundsDialog(
                                  context,
                                  ref,
                                  goal.id,
                                  false,
                                ),
                              ),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.add),
                                label: const Text('Añadir'),
                                onPressed: () => _showFundsDialog(
                                  context,
                                  ref,
                                  goal.id,
                                  true,
                                ),
                              ),
                            ],
                          ),
                        ],
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
