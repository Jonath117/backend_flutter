import '../../data/models/expense_model.dart';

abstract class ExpenseRepository {
  Future<List<ExpenseModel>> getExpenses();
  Future<ExpenseModel> getExpense(String id);
  Future<void> createExpense(double amount, String description, DateTime date, String categoryId, String? photoUrl);
  Future<void> updateExpense(String id, double amount, String description, DateTime date, String categoryId, String? photoUrl);
  Future<void> deleteExpense(String id);
}
