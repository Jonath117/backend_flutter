import 'package:expense_track_frontend/features/categories/presentation/viewmodels/categories_viewmodel.dart';
import 'package:expense_track_frontend/features/expenses/data/models/expense_model.dart';
import 'package:expense_track_frontend/features/expenses/presentation/viewmodels/expenses_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class EditExpenseView extends ConsumerStatefulWidget {
  final ExpenseModel expense;

  const EditExpenseView({super.key, required this.expense});

  @override
  ConsumerState<EditExpenseView> createState() => _EditExpenseViewState();
}

class _EditExpenseViewState extends ConsumerState<EditExpenseView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  late TextEditingController _photoUrlController;
  late DateTime _selectedDate;
  late String _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.expense.amount.toString(),
    );
    _descriptionController = TextEditingController(
      text: widget.expense.title,
    );
    _photoUrlController = TextEditingController(
      text: widget.expense.images.isNotEmpty ? widget.expense.images.first : '',
    );
    _selectedDate = widget.expense.expenseDate;
    _selectedCategoryId = widget.expense.categoryId;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _photoUrlController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final amount = double.parse(_amountController.text);
      final description = _descriptionController.text;
      final photoUrl = _photoUrlController.text.isEmpty
          ? null
          : _photoUrlController.text;

      try {
        await ref
            .read(expensesViewModelProvider.notifier)
            .updateExpense(
              widget.expense.id,
              amount,
              description,
              _selectedDate,
              _selectedCategoryId,
              photoUrl,
            );
        if (mounted) {
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesState = ref.watch(categoriesViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Editar Gasto')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Cantidad'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingresa una cantidad';
                  }
                  final parsed = double.tryParse(value);
                  if (parsed == null) {
                    return 'Por favor, ingresa un número válido';
                  }
                  if (parsed <= 0 || parsed > 9999999) {
                    return 'La cantidad debe ser mayor a 0 y menor a 9,999,999';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
                maxLength: 100,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, ingresa una descripción';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Fecha: ${DateFormat.yMMMd('es').format(_selectedDate)}',
                    ),
                  ),
                  TextButton(
                    onPressed: () => _selectDate(context),
                    child: const Text('Seleccionar Fecha'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              categoriesState.maybeWhen(
                data: (categories) {
                  return DropdownButtonFormField<String>(
                    initialValue: _selectedCategoryId,
                    decoration: const InputDecoration(labelText: 'Categoría'),
                    items: categories.map((c) {
                      return DropdownMenuItem(value: c.id, child: Text(c.name));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        if (value != null) {
                          _selectedCategoryId = value;
                        }
                      });
                    },
                    validator: (value) => value == null ? 'Requerido' : null,
                  );
                },
                orElse: () => const CircularProgressIndicator(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _photoUrlController,
                decoration: const InputDecoration(
                  labelText: 'URL de Foto (opcional)',
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Guardar Cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
