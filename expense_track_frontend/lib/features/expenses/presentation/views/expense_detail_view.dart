import 'package:expense_track_frontend/features/categories/presentation/viewmodels/categories_viewmodel.dart';
import 'package:expense_track_frontend/features/expenses/data/models/expense_model.dart';
import 'package:expense_track_frontend/features/expenses/presentation/viewmodels/expenses_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:expense_track_frontend/core/utils/error_handler.dart';

class ExpenseDetailView extends ConsumerWidget {
  final ExpenseModel expense;

  const ExpenseDetailView({super.key, required this.expense});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesState = ref.watch(categoriesViewModelProvider);

    String categoryName = 'Loading...';
    categoriesState.whenData((categories) {
      final category = categories
          .where((c) => c.id == expense.categoryId)
          .firstOrNull;
      categoryName = category?.name ?? 'Unknown Category';
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles del Gasto'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              context.push('/expenses/edit', extra: expense);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Eliminar Gasto'),
                  content: const Text(
                    '¿Estás seguro de que deseas eliminar este gasto?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        'Eliminar',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                try {
                  await ref
                      .read(expensesViewModelProvider.notifier)
                      .deleteExpense(expense.id);
                  if (context.mounted) {
                    context.pop();
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(getFriendlyErrorMessage(e)), backgroundColor: Colors.red),
                    );
                  }
                }
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            if (expense.images.isNotEmpty)
              Center(
                child: GestureDetector(
                  onTap: () => _showFullImage(context, expense.images.first),
                  child: Image.network(
                    expense.images.first,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.broken_image, size: 100),
                  ),
                ),
              ),
            const SizedBox(height: 24),
            Text(
              'Bs ${expense.amount.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _buildDetailRow(context, 'Descripción', expense.title),
            const Divider(),
            _buildDetailRow(
              context,
              'Fecha',
              DateFormat.yMMMd('es').format(expense.expenseDate),
            ),
            const Divider(),
            _buildDetailRow(context, 'Categoría', categoryName),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  void _showFullImage(BuildContext context, String networkUrl) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(10),
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4,
              child: Image.network(networkUrl, fit: BoxFit.contain),
            ),
            Positioned(
              right: 0,
              top: 0,
              child: IconButton(
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 30,
                  shadows: [Shadow(color: Colors.black, blurRadius: 10)],
                ),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
