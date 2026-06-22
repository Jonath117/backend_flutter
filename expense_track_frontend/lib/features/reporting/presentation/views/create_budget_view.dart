import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../viewmodels/reporting_viewmodel.dart';
import '../../../categories/presentation/viewmodels/categories_viewmodel.dart';
import 'package:expense_track_frontend/core/utils/error_handler.dart';

class CreateBudgetView extends ConsumerStatefulWidget {
  const CreateBudgetView({super.key});

  @override
  ConsumerState<CreateBudgetView> createState() => _CreateBudgetViewState();
}

class _CreateBudgetViewState extends ConsumerState<CreateBudgetView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _limitController = TextEditingController();
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  final List<String> _selectedCategories = [];

  @override
  void dispose() {
    _nameController.dispose();
    _limitController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : (_endDate ?? DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      try {
        final amount = double.parse(_limitController.text);
        await ref
            .read(budgetsViewModelProvider.notifier)
            .createBudget(
              _nameController.text,
              amount,
              _startDate,
              _endDate,
              _selectedCategories,
            );
        if (mounted) context.pop();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(getFriendlyErrorMessage(e)), backgroundColor: Colors.red));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesState = ref.watch(categoriesViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo Presupuesto')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Presupuesto',
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _limitController,
                decoration: const InputDecoration(labelText: 'Límite Mensual'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Requerido';
                  if (double.tryParse(value) == null) return 'Número inválido';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Inicio: ${DateFormat.yMMMd('es').format(_startDate)}',
                    ),
                  ),
                  TextButton(
                    onPressed: () => _selectDate(context, true),
                    child: const Text('Cambiar'),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Fin: ${_endDate != null ? DateFormat.yMMMd('es').format(_endDate!) : 'Sin fecha límite'}',
                    ),
                  ),
                  TextButton(
                    onPressed: () => _selectDate(context, false),
                    child: const Text('Establecer'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Categorías Aplicables:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              categoriesState.when(
                data: (categories) {
                  return Wrap(
                    spacing: 8.0,
                    children: categories.map((cat) {
                      final isSelected = _selectedCategories.contains(cat.id);
                      return FilterChip(
                        label: Text(cat.name),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedCategories.add(cat.id);
                            } else {
                              _selectedCategories.remove(cat.id);
                            }
                          });
                        },
                      );
                    }).toList(),
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (e, _) => Text(getFriendlyErrorMessage(e), style: const TextStyle(color: Colors.red)),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Crear Presupuesto'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
