import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/category_model.dart';

part 'categories_api_client.g.dart';

@RestApi()
abstract class CategoriesApiClient {
  factory CategoriesApiClient(Dio dio, {String baseUrl}) = _CategoriesApiClient;

  @GET("/api/categories")
  Future<List<CategoryModel>> getCategories();

  @POST("/api/categories")
  Future<dynamic> createCategory(@Body() Map<String, dynamic> body);
}
