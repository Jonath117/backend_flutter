import '../../data/models/budget_model.dart';
import '../../data/models/goal_model.dart';

abstract class ReportingRepository {
  Future<List<BudgetModel>> getBudgets();
  Future<void> createBudget(String name, double monthlyLimit, DateTime startDate, DateTime? endDate, List<String> categoryIds);
  Future<void> updateBudget(String id, String name, double monthlyLimit, DateTime startDate, DateTime? endDate, List<String> categoryIds);
  Future<void> deleteBudget(String id);

  Future<List<GoalModel>> getGoals();
  Future<void> createGoal(String name, double targetAmount, DateTime? targetDate);
  Future<void> updateGoal(String id, String name, double targetAmount, DateTime? targetDate);
  Future<void> deleteGoal(String id);
  Future<void> addFundsToGoal(String id, double amount);
  Future<void> withdrawFundsFromGoal(String id, double amount);
}
