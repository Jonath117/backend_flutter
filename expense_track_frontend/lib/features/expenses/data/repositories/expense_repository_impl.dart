import 'package:expense_track_frontend/features/expenses/data/models/expense_model.dart';
import 'package:expense_track_frontend/features/expenses/data/remote/expenses_api_client.dart';
import 'package:expense_track_frontend/features/expenses/domain/repositories/expense_repository.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpensesApiClient _apiClient;

  ExpenseRepositoryImpl(this._apiClient);

  @override
  Future<List<ExpenseModel>> getExpenses() async {
    return await _apiClient.getExpenses();
  }

  @override
  Future<ExpenseModel> getExpense(String id) async {
    return await _apiClient.getExpense(id);
  }

  @override
  Future<void> createExpense(double amount, String description, DateTime date, String categoryId, String? photoUrl) async {
    final body = {
      "amount": amount,
      "title": description, // mapping UI description to backend title
      "description": "",
      "expenseDate": date.toIso8601String().split('T')[0], // DateOnly format
      "categoryId": categoryId,
      "images": photoUrl != null && photoUrl.isNotEmpty ? [photoUrl] : [],
    };
    await _apiClient.createExpense(body);
  }

  @override
  Future<void> updateExpense(String id, double amount, String description, DateTime date, String categoryId, String? photoUrl) async {
    final body = {
      "id": id,
      "amount": amount,
      "title": description,
      "description": "",
      "expenseDate": date.toIso8601String().split('T')[0],
      "categoryId": categoryId,
      "imagesToAdd": photoUrl != null && photoUrl.isNotEmpty ? [photoUrl] : [],
      "imagesToRemove": [],
    };
    await _apiClient.updateExpense(id, body);
  }

  @override
  Future<void> deleteExpense(String id) async {
    await _apiClient.deleteExpense(id);
  }

  @override
  Future<String> uploadPhoto(dynamic file) async {
    final response = await _apiClient.uploadPhoto(file);
    return response.url;
  }
}
