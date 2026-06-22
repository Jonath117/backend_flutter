import 'package:expense_track_frontend/features/categories/data/models/category_model.dart';
import 'package:expense_track_frontend/features/categories/data/remote/categories_api_client.dart';
import 'package:expense_track_frontend/features/categories/domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoriesApiClient _apiClient;

  CategoryRepositoryImpl(this._apiClient);

  @override
  Future<List<CategoryModel>> getCategories() async {
    return await _apiClient.getCategories();
  }

  @override
  Future<void> createCategory(String name, String? icon, String? color) async {
    await _apiClient.createCategory({
      "name": name,
      "icon": icon,
      "color": color,
    });
  }
}
