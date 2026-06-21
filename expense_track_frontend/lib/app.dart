import 'package:expense_track_frontend/features/identity/presentation/views/login_view.dart';
import 'package:flutter/material.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: Scaffold(body: LoginView()));
  }
}
