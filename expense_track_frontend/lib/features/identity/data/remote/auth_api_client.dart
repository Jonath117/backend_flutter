import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/auth_models.dart';

part 'auth_api_client.g.dart';

@RestApi()
abstract class AuthApiClient {
  factory AuthApiClient(Dio dio, {String baseUrl}) = _AuthApiClient;

  @POST("/api/auth/login")
  Future<LoginResponse> login(@Body() Map<String, dynamic> body);

  @POST("/api/auth/register")
  Future<RegisterResponse> register(@Body() Map<String, dynamic> body);
}
