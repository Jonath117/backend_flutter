import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../data/remote/auth_api_client.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';

final dioProvider = Provider(
  (ref) => Dio(BaseOptions(baseUrl: 'http://localhost:5024')),
);

final secureStorageProvider = Provider((ref) => const FlutterSecureStorage());

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiClient = AuthApiClient(ref.watch(dioProvider));
  return AuthRepositoryImpl(apiClient, ref.watch(secureStorageProvider));
});

class AuthViewModel extends AsyncNotifier<void> {
  late AuthRepository _repository;

  @override
  FutureOr<void> build() {
    _repository = ref.watch(authRepositoryProvider);
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      await _repository.login(email, password);
    });
  }
}

final authViewModelProvider = AsyncNotifierProvider<AuthViewModel, void>(() {
  return AuthViewModel();
});
