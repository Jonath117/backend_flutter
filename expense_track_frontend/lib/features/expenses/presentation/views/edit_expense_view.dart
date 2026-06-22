import 'package:expense_track_frontend/features/categories/presentation/viewmodels/categories_viewmodel.dart';
import 'package:expense_track_frontend/features/expenses/data/models/expense_model.dart';
import 'package:expense_track_frontend/features/expenses/presentation/viewmodels/expenses_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:expense_track_frontend/core/utils/error_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';

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
  late DateTime _selectedDate;
  late String _selectedCategoryId;
  XFile? _selectedImage;
  String? _existingPhotoUrl;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.expense.amount.toString(),
    );
    _descriptionController = TextEditingController(
      text: widget.expense.title,
    );
    _existingPhotoUrl = widget.expense.images.isNotEmpty ? widget.expense.images.first : null;
    _selectedDate = widget.expense.expenseDate;
    _selectedCategoryId = widget.expense.categoryId;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = pickedFile;
        _existingPhotoUrl = null;
      });
    }
  }

  void _showFullImage(BuildContext context, String? networkUrl, File? file) {
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
              child: networkUrl != null 
                  ? Image.network(networkUrl, fit: BoxFit.contain)
                  : Image.file(file!, fit: BoxFit.contain),
            ),
            Positioned(
              right: 0,
              top: 0,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30, shadows: [Shadow(color: Colors.black, blurRadius: 10)]),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final amount = double.parse(_amountController.text);
      final description = _descriptionController.text;

      setState(() => _isUploading = true);

      try {
        String? newPhotoUrl;
        if (_selectedImage != null) {
          newPhotoUrl = await ref.read(expensesViewModelProvider.notifier).uploadPhoto(_selectedImage!);
        }

        await ref
            .read(expensesViewModelProvider.notifier)
            .updateExpense(
              widget.expense.id,
              amount,
              description,
              _selectedDate,
              _selectedCategoryId,
              newPhotoUrl,
            );
        if (mounted) {
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(getFriendlyErrorMessage(e)), backgroundColor: Colors.red));
        }
      } finally {
        if (mounted) {
          setState(() => _isUploading = false);
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
              Row(
                children: [
                  Expanded(
                    child: Text(_selectedImage == null && _existingPhotoUrl == null
                        ? 'Sin foto adjunta' 
                        : _existingPhotoUrl != null 
                            ? 'Foto existente adjunta' 
                            : 'Foto seleccionada: ${_selectedImage!.name}'),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.image),
                    label: const Text('Subir Foto'),
                    onPressed: _pickImage,
                  )
                ],
              ),
              if (_selectedImage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: GestureDetector(
                    onTap: () => _showFullImage(context, kIsWeb ? _selectedImage!.path : null, kIsWeb ? null : File(_selectedImage!.path)),
                    child: kIsWeb 
                        ? Image.network(_selectedImage!.path, height: 150, fit: BoxFit.cover)
                        : Image.file(File(_selectedImage!.path), height: 150, fit: BoxFit.cover),
                  ),
                )
              else if (_existingPhotoUrl != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: GestureDetector(
                    onTap: () => _showFullImage(context, _existingPhotoUrl, null),
                    child: Image.network(_existingPhotoUrl!, height: 150, fit: BoxFit.cover),
                  ),
                ),
              const SizedBox(height: 32),
              _isUploading 
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
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
