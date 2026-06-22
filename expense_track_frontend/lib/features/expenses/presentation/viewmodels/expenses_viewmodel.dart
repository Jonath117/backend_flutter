import 'dart:async';
import 'package:expense_track_frontend/features/expenses/data/models/expense_model.dart';
import 'package:expense_track_frontend/features/expenses/data/remote/expenses_api_client.dart';
import 'package:image_picker/image_picker.dart';
import 'package:expense_track_frontend/features/expenses/data/repositories/expense_repository_impl.dart';
import 'package:expense_track_frontend/features/expenses/domain/repositories/expense_repository.dart';
import 'package:expense_track_frontend/features/identity/presentation/viewmodels/auth_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  final apiClient = ExpensesApiClient(ref.watch(dioProvider));
  return ExpenseRepositoryImpl(apiClient);
});

class ExpensesViewModel extends AsyncNotifier<List<ExpenseModel>> {
  late ExpenseRepository _repository;

  @override
  FutureOr<List<ExpenseModel>> build() async {
    _repository = ref.watch(expenseRepositoryProvider);
    return _repository.getExpenses();
  }

  Future<void> loadExpenses() async {
    state = const AsyncValue.loading();
    try {
      final list = await _repository.getExpenses();
      state = AsyncValue.data(list);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> addExpense(
    double amount,
    String description,
    DateTime date,
    String categoryId,
    String? photoUrl,
  ) async {
    final previousState = state;
    state = const AsyncValue.loading();
    try {
      await _repository.createExpense(
        amount,
        description,
        date,
        categoryId,
        photoUrl,
      );
      final updatedList = await _repository.getExpenses();
      state = AsyncValue.data(updatedList);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      state = previousState;
      rethrow;
    }
  }

  Future<void> updateExpense(
    String id,
    double amount,
    String description,
    DateTime date,
    String categoryId,
    String? photoUrl,
  ) async {
    final previousState = state;
    state = const AsyncValue.loading();
    try {
      await _repository.updateExpense(
        id,
        amount,
        description,
        date,
        categoryId,
        photoUrl,
      );
      final updatedList = await _repository.getExpenses();
      state = AsyncValue.data(updatedList);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      state = previousState;
      rethrow;
    }
  }

  Future<void> deleteExpense(String id) async {
    final previousState = state;
    state = const AsyncValue.loading();
    try {
      await _repository.deleteExpense(id);
      final updatedList = await _repository.getExpenses();
      state = AsyncValue.data(updatedList);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      state = previousState;
      rethrow;
    }
  }

  Future<String> uploadPhoto(XFile file) async {
    return await _repository.uploadPhoto(file);
  }
}

final expensesViewModelProvider =
    AsyncNotifierProvider<ExpensesViewModel, List<ExpenseModel>>(() {
      return ExpensesViewModel();
    });

final expenseSearchQueryProvider = StateProvider<String>((ref) => '');
final expenseCategoryFilterProvider = StateProvider<String?>((ref) => null);

final filteredExpensesProvider = Provider<List<ExpenseModel>>((ref) {
  final expensesState = ref.watch(expensesViewModelProvider);
  final searchQuery = ref.watch(expenseSearchQueryProvider).toLowerCase();
  final categoryFilter = ref.watch(expenseCategoryFilterProvider);

  return expensesState.maybeWhen(
    data: (expenses) {
      return expenses.where((expense) {
        final matchesSearch = expense.title.toLowerCase().contains(
          searchQuery,
        );
        final matchesCategory =
            categoryFilter == null ||
            categoryFilter.isEmpty ||
            expense.categoryId == categoryFilter;
        return matchesSearch && matchesCategory;
      }).toList();
    },
    orElse: () => [],
  );
});
