import 'package:expense_track_frontend/features/categories/presentation/viewmodels/categories_viewmodel.dart';
import 'package:expense_track_frontend/features/expenses/presentation/viewmodels/expenses_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class ExpensesListView extends ConsumerWidget {
  const ExpensesListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesState = ref.watch(expensesViewModelProvider);
    final filteredExpenses = ref.watch(filteredExpensesProvider);
    final categoriesState = ref.watch(categoriesViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Gastos')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Buscar',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      ref.read(expenseSearchQueryProvider.notifier).state =
                          value;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                categoriesState.maybeWhen(
                  data: (categories) {
                    final selectedCategory = ref.watch(
                      expenseCategoryFilterProvider,
                    );
                    return DropdownButton<String>(
                      value: selectedCategory,
                      hint: const Text('Todas las Categorías'),
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('Todas'),
                        ),
                        ...categories.map(
                          (c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(c.name),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        ref.read(expenseCategoryFilterProvider.notifier).state =
                            value;
                      },
                    );
                  },
                  orElse: () => const CircularProgressIndicator(),
                ),
              ],
            ),
          ),
          Expanded(
            child: expensesState.when(
              data: (_) {
                if (filteredExpenses.isEmpty) {
                  return const Center(child: Text('No se encontraron gastos.'));
                }
                return ListView.builder(
                  itemCount: filteredExpenses.length,
                  itemBuilder: (context, index) {
                    final expense = filteredExpenses[index];
                    return ListTile(
                      title: Text(expense.title),
                      subtitle: Text(
                        DateFormat.yMMMd('es').format(expense.expenseDate),
                      ),
                      trailing: Text(
                        'Bs${expense.amount.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onTap: () {
                        context.push('/expenses/detail', extra: expense);
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/expenses/create');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
