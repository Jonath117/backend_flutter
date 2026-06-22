import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../../domain/entities/user_entity.dart';
import 'auth_viewmodel.dart'; // To get secureStorageProvider

class ProfileViewModel extends AsyncNotifier<UserEntity?> {
  @override
  FutureOr<UserEntity?> build() async {
    final secureStorage = ref.watch(secureStorageProvider);
    final token = await secureStorage.read(key: 'jwt_token');

    if (token == null || token.isEmpty) {
      return null;
    }

    try {
      final payload = JwtDecoder.decode(token);
      return UserEntity.fromJwtPayload(payload);
    } catch (e) {
      return null;
    }
  }

  Future<void> logout() async {
    final secureStorage = ref.read(secureStorageProvider);
    await secureStorage.delete(key: 'jwt_token');
    state = const AsyncData(null);
  }
}

final profileViewModelProvider =
    AsyncNotifierProvider<ProfileViewModel, UserEntity?>(() {
  return ProfileViewModel();
});
