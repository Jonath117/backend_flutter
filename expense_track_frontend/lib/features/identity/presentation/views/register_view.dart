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

      // 1. Centro el contenido y limito el ancho máximo del formulario para que sea responsivo
      body: Center(
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 500,
          ), // Ancho máximo ideal para inputs en pantallas grandes
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(
              24.0,
            ), // Un padding un poco más amplio se ve mejor
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(label: 'Nombre', controller: _nameController),
                const SizedBox(height: 12), // Espaciado controlado entre inputs
                CustomTextField(
                  label: 'Apellido',
                  controller: _lastNameController,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  label: 'Correo Electrónico',
                  controller: _emailController,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  label: 'Contraseña',
                  controller: _passwordController,
                  obscureText: true,
                ),
              ],
            ),
          ),
        ),
      ),

      // 2. Coloco el botón abajo del todo de forma fija y responsiva
      bottomNavigationBar: SafeArea(
        // Evita problemas con la barra de navegación en iOS/Android modernos
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 500,
          ), // Mismo ancho máximo que los inputs
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment
                .center, // Centra el botón si la pantalla es muy ancha
            children: [
              Expanded(
                child: SizedBox(
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
