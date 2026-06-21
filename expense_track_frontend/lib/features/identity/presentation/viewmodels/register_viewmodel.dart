import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_viewmodel.dart';

class RegisterViewModel extends AsyncNotifier<void> {
  late AuthRepository _repository;

  @override
  FutureOr<void> build() {
    _repository = ref.watch(authRepositoryProvider);
  }

  Future<void> register(
    String email,
    String name,
    String lastName,
    String password,
  ) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      await _repository.register(email, name, lastName, password);
    });
  }
}

final registerViewModelProvider =
    AsyncNotifierProvider<RegisterViewModel, void>(() {
      return RegisterViewModel();
    });
