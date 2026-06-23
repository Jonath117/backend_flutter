import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:expense_track_frontend/features/reporting/data/models/budget_model.dart';
import 'package:expense_track_frontend/features/expenses/presentation/viewmodels/expenses_viewmodel.dart';
import 'package:expense_track_frontend/features/settings/presentation/viewmodels/settings_viewmodel.dart';
import 'package:finance_design_system/finance_design_system.dart';

class BudgetDetailView extends ConsumerWidget {
  final BudgetModel budget;

  const BudgetDetailView({super.key, required this.budget});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesState = ref.watch(expensesViewModelProvider);
    final currency = ref.watch(settingsViewModelProvider).maybeWhen(
      data: (s) => s.currency,
      orElse: () => 'Bs.',
    );

    final dateFormat = DateFormat.yMMMd('es');

    return Scaffold(
      appBar: AppBar(
        title: Text('Detalle: ${budget.name}'),
      ),
      body: expensesState.when(
        data: (allExpenses) {
          // Filter expenses based on budget rules
          final budgetExpenses = allExpenses.where((e) {
            if (budget.categoryIds.isNotEmpty && !budget.categoryIds.contains(e.categoryId)) {
              return false;
            }
            final eDate = e.expenseDate;
            if (eDate.isBefore(budget.startDate)) return false;
            if (budget.endDate != null && eDate.isAfter(budget.endDate!)) {
              return false;
            }
            return true;
          }).toList();

          // Sort by date descending
          budgetExpenses.sort((a, b) => b.expenseDate.compareTo(a.expenseDate));

          final spentAmount = budgetExpenses.fold(0.0, (sum, e) => sum + e.amount);
          final remaining = budget.monthlyLimit - spentAmount;
          final isNegative = remaining < 0;

          return Column(
            children: [
              // Header Summary
              Container(
                width: double.infinity,
                color: Theme.of(context).colorScheme.surface,
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Text(
                      'Límite del Presupuesto',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$currency ${budget.monthlyLimit.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Gastado', style: TextStyle(color: Colors.grey)),
                            Text(
                              '$currency ${spentAmount.toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('Restante', style: TextStyle(color: Colors.grey)),
                            Text(
                              '$currency ${remaining.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: isNegative ? Colors.red : Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    FinanceProgressBar(
                      current: spentAmount,
                      target: budget.monthlyLimit,
                      reverseColors: true,
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              
              // Expenses List
              Expanded(
                child: budgetExpenses.isEmpty
                    ? const Center(child: Text('Aún no tienes gastos para este presupuesto.'))
                    : ListView.builder(
                        itemCount: budgetExpenses.length,
                        itemBuilder: (context, index) {
                          final expense = budgetExpenses[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                              child: Icon(Icons.receipt, color: Theme.of(context).colorScheme.primary),
                            ),
                            title: Text(expense.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(dateFormat.format(expense.expenseDate)),
                            trailing: Text(
                              '- $currency ${expense.amount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                color: Colors.red,
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
