import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:expense_track_frontend/features/expenses/presentation/viewmodels/expenses_viewmodel.dart';
import 'package:expense_track_frontend/features/categories/presentation/viewmodels/categories_viewmodel.dart';
import 'package:expense_track_frontend/features/settings/presentation/viewmodels/settings_viewmodel.dart';
import 'dart:math';

class AdvancedChartsView extends ConsumerStatefulWidget {
  const AdvancedChartsView({super.key});

  @override
  ConsumerState<AdvancedChartsView> createState() => _AdvancedChartsViewState();
}

class _AdvancedChartsViewState extends ConsumerState<AdvancedChartsView> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final expensesState = ref.watch(expensesViewModelProvider);
    final categoriesState = ref.watch(categoriesViewModelProvider);
    final currency = ref.watch(settingsViewModelProvider).maybeWhen(
      data: (s) => s.currency,
      orElse: () => 'Bs.',
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gráfico de Gastos'),
      ),
      body: expensesState.when(
        data: (expenses) {
          if (expenses.isEmpty) {
            return const Center(child: Text('No hay gastos para mostrar.'));
          }

          return categoriesState.when(
            data: (categories) {
              // Group expenses by category ID
              final Map<String, double> categoryTotals = {};
              double totalExpenses = 0.0;

              for (var expense in expenses) {
                categoryTotals[expense.categoryId] = (categoryTotals[expense.categoryId] ?? 0.0) + expense.amount;
                totalExpenses += expense.amount;
              }

              if (totalExpenses == 0) {
                return const Center(child: Text('Tus gastos suman 0.'));
              }

              // Map category ID to Color and Name
              final Map<String, Color> categoryColors = {};
              final random = Random(42); // Fixed seed for consistent colors

              for (var category in categories) {
                // Generate a random but pleasing color
                categoryColors[category.id] = Color.fromARGB(
                  255,
                  100 + random.nextInt(155),
                  100 + random.nextInt(155),
                  100 + random.nextInt(155),
                );
              }

              final entries = categoryTotals.entries.toList();
              // Sort by amount descending
              entries.sort((a, b) => b.value.compareTo(a.value));

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Distribución de Gastos',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Total: $currency ${totalExpenses.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey),
                    ),
                    const SizedBox(height: 32),
                    Expanded(
                      flex: 2,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          PieChart(
                            PieChartData(
                              pieTouchData: PieTouchData(
                                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                                  setState(() {
                                    if (!event.isInterestedForInteractions ||
                                        pieTouchResponse == null ||
                                        pieTouchResponse.touchedSection == null) {
                                      touchedIndex = -1;
                                      return;
                                    }
                                    touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                                  });
                                },
                              ),
                              borderData: FlBorderData(show: false),
                              sectionsSpace: 2,
                              centerSpaceRadius: 50,
                              sections: List.generate(entries.length, (i) {
                                final isTouched = i == touchedIndex;
                                final entry = entries[i];
                                final category = categories.firstWhere((c) => c.id == entry.key);
                                final color = categoryColors[category.id] ?? Colors.grey;
                                final double percentage = (entry.value / totalExpenses) * 100;
                                
                                final radius = isTouched ? 70.0 : 60.0;
                                final fontSize = isTouched ? 18.0 : 14.0;

                                return PieChartSectionData(
                                  color: color,
                                  value: entry.value,
                                  title: '${percentage.toStringAsFixed(1)}%',
                                  radius: radius,
                                  titleStyle: TextStyle(
                                    fontSize: fontSize,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    shadows: const [Shadow(color: Colors.black45, blurRadius: 2)],
                                  ),
                                );
                              }),
                            ),
                          ),
                          if (touchedIndex == -1)
                             Icon(Icons.pie_chart, size: 40, color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Expanded(
                      flex: 3,
                      child: ListView.builder(
                        itemCount: entries.length,
                        itemBuilder: (context, index) {
                          final entry = entries[index];
                          final category = categories.firstWhere((c) => c.id == entry.key);
                          final color = categoryColors[category.id] ?? Colors.grey;
                          final double percentage = (entry.value / totalExpenses) * 100;

                          return ListTile(
                            leading: Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: color,
                              ),
                            ),
                            title: Text(category.name),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '$currency ${entry.value.toStringAsFixed(2)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '${percentage.toStringAsFixed(1)}%',
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Error: $err')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
