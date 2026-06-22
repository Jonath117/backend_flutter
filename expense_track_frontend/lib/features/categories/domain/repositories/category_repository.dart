import '../../data/models/category_model.dart';

abstract class CategoryRepository {
  Future<List<CategoryModel>> getCategories();
  Future<void> createCategory(String name, String? icon, String? color);
}
