import 'package:expense_track_frontend/features/identity/presentation/views/register_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../viewmodels/auth_viewmodel.dart';
import '../widgets/custom_text_field.dart';

class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);

    ref.listen<AsyncValue>(authViewModelProvider, (_, state) {
      state.whenOrNull(
        error: (error, stackTrace) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(error.toString())));
        },
        data: (_) {
          if (state.isLoading == false && state.hasError == false) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Login exitoso'),
                backgroundColor: Colors.green,
              ),
            );
            context.go('/expenses');
          }
        },
      );
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Expense Tracker')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.account_balance_wallet,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 32),

            CustomTextField(
              label: 'Correo Electrónico',
              controller: _emailController,
            ),
            CustomTextField(
              label: 'Contraseña',
              controller: _passwordController,
              obscureText: true,
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: authState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: () {
                        ref
                            .read(authViewModelProvider.notifier)
                            .login(
                              _emailController.text,
                              _passwordController.text,
                            );
                      },
                      child: const Text(
                        'Iniciar Sesión',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
            ),

            SizedBox(height: 20.0),

            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegisterView()),
                );
              },
              child: const Text('¿No tienes cuenta? Registrate aqui'),
            ),
          ],
        ),
      ),
    );
  }
}
