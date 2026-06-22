import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../viewmodels/register_viewmodel.dart';
import '../widgets/custom_text_field.dart';
import 'package:expense_track_frontend/core/utils/error_handler.dart';

class RegisterView extends ConsumerStatefulWidget {
  const RegisterView({super.key});

  @override
  ConsumerState<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends ConsumerState<RegisterView> {
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final registerState = ref.watch(registerViewModelProvider);

    ref.listen<AsyncValue>(registerViewModelProvider, (_, state) {
      state.whenOrNull(
        error: (error, stackTrace) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(getFriendlyErrorMessage(error)),
              backgroundColor: Colors.red,
            ),
          );
        },
        data: (_) {
          if (state.isLoading == false && state.hasError == false) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Usuario creado correctamente'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          }
        },
      );
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Crear Cuenta')),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            CustomTextField(label: 'Nombre', controller: _nameController),
            CustomTextField(label: 'Apellido', controller: _lastNameController),
            CustomTextField(
              label: 'Correo Electrónico',
              controller: _emailController,
            ),
            CustomTextField(
              label: 'Contraseña',
              controller: _passwordController,
              obscureText: true,
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: registerState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: () {
                        ref
                            .read(registerViewModelProvider.notifier)
                            .register(
                              _emailController.text,
                              _nameController.text,
                              _lastNameController.text,
                              _passwordController.text,
                            );
                      },
                      child: const Text(
                        'Registrarse',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
