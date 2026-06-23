import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../expenses/presentation/viewmodels/expenses_viewmodel.dart';
import '../viewmodels/reporting_viewmodel.dart';
import 'package:expense_track_frontend/core/utils/error_handler.dart';
import 'package:finance_design_system/finance_design_system.dart';
import 'package:expense_track_frontend/features/settings/presentation/viewmodels/settings_viewmodel.dart';

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
    final currency = ref.watch(settingsViewModelProvider).maybeWhen(
      data: (s) => s.currency,
      orElse: () => 'Bs.',
    );

    final dateFormat = DateFormat.yMMMd('es');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes y Presupuestos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.pie_chart),
            tooltip: 'Gráficos Avanzados',
            onPressed: () => context.push('/reports/charts'),
          ),
        ],
      ),
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
                                'Gastado: $currency ${spentAmount.toStringAsFixed(2)}',
                              ),
                              Text(
                                'Límite: $currency ${budget.monthlyLimit.toStringAsFixed(2)}',
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          FinanceProgressBar(
                            current: spentAmount,
                            target: budget.monthlyLimit,
                            reverseColors: true,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Text(
                                'Restante: ',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '$currency ${remaining.toStringAsFixed(2)}',
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
            error: (e, _) => SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    getFriendlyErrorMessage(e),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ),
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
                            'Progreso: $currency ${goal.currentAmount.toStringAsFixed(2)} de $currency ${goal.targetAmount.toStringAsFixed(2)}',
                          ),
                          const SizedBox(height: 8),
                          FinanceProgressBar(
                            current: goal.currentAmount,
                            target: goal.targetAmount,
                            reverseColors: false,
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
            error: (e, _) => SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    getFriendlyErrorMessage(e),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}
