import 'dart:async';
import 'package:expense_track_frontend/features/categories/data/remote/categories_api_client.dart';
import 'package:expense_track_frontend/features/categories/data/repositories/category_repository_impl.dart';
import 'package:expense_track_frontend/features/identity/presentation/viewmodels/auth_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/category_model.dart';
import '../../domain/repositories/category_repository.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final apiClient = CategoriesApiClient(ref.watch(dioProvider));
  return CategoryRepositoryImpl(apiClient);
});

class CategoriesViewModel extends AsyncNotifier<List<CategoryModel>> {
  late CategoryRepository _repository;

  @override
  FutureOr<List<CategoryModel>> build() async {
    _repository = ref.watch(categoryRepositoryProvider);
    return _repository.getCategories();
  }

  Future<void> addCategory(String name, String? icon, String? color) async {
    final previousState = state;

    state = const AsyncValue.loading();

    try {
      await _repository.createCategory(name, icon, color);

      final updatedList = await _repository.getCategories();
      state = AsyncValue.data(updatedList);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      state = previousState;
    }
  }
}

final categoriesViewModelProvider =
    AsyncNotifierProvider<CategoriesViewModel, List<CategoryModel>>(() {
      return CategoriesViewModel();
    });
