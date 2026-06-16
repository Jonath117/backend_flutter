import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/repositories/auth_repository.dart';
import '../remote/auth_api_client.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthApiClient _apiClient;
  final FlutterSecureStorage _secureStorage;

  AuthRepositoryImpl(this._apiClient, this._secureStorage);

  @override
  Future<String> login(String email, String password) async {
    try {
      final response = await _apiClient.login({
        "email": email,
        "password": password,
      });

      await _secureStorage.write(key: "jwt_token", value: response.token);

      return response.token;
    } catch (e) {
      throw Exception('Error al iniciar sesión: $e');
    }
  }

  @override
  Future<String> register(
    String email,
    String name,
    String lastName,
    String password,
  ) async {
    try {
      final response = await _apiClient.register({
        "email": email,
        "name": name,
        "lastName": lastName,
        "password": password,
      });

      return response.id;
    } catch (e) {
      throw Exception('Error al registrar usuario: $e');
    }
  }
}
