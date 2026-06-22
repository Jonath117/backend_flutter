import 'package:expense_track_frontend/features/identity/presentation/viewmodels/auth_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/budget_model.dart';
import '../../data/models/goal_model.dart';
import '../../data/remote/reporting_api_client.dart';
import '../../domain/repositories/reporting_repository.dart';

final reportingRepositoryProvider = Provider<ReportingRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final apiClient = ReportingApiClient(dio);
  return ReportingRepositoryImpl(apiClient);
});

class ReportingRepositoryImpl implements ReportingRepository {
  final ReportingApiClient _apiClient;

  ReportingRepositoryImpl(this._apiClient);

  @override
  Future<List<BudgetModel>> getBudgets() async {
    return await _apiClient.getBudgets();
  }

  @override
  Future<void> createBudget(
    String name,
    double monthlyLimit,
    DateTime startDate,
    DateTime? endDate,
  ) async {
    final body = {
      "name": name,
      "monthlyLimit": monthlyLimit,
      "startDate": startDate.toIso8601String().split('T')[0],
      "endDate": endDate?.toIso8601String().split('T')[0],
    };
    await _apiClient.createBudget(body);
  }

  @override
  Future<void> updateBudget(
    String id,
    String name,
    double monthlyLimit,
    DateTime startDate,
    DateTime? endDate,
  ) async {
    final body = {
      "name": name,
      "monthlyLimit": monthlyLimit,
      "startDate": startDate.toIso8601String().split('T')[0],
      "endDate": endDate?.toIso8601String().split('T')[0],
    };
    await _apiClient.updateBudget(id, body);
  }

  @override
  Future<void> deleteBudget(String id) async {
    await _apiClient.deleteBudget(id);
  }

  @override
  Future<List<GoalModel>> getGoals() async {
    return await _apiClient.getGoals();
  }

  @override
  Future<void> createGoal(
    String name,
    double targetAmount,
    DateTime? targetDate,
  ) async {
    final body = {
      "name": name,
      "targetAmount": targetAmount,
      "targetDate": targetDate?.toIso8601String().split('T')[0],
    };
    await _apiClient.createGoal(body);
  }

  @override
  Future<void> updateGoal(
    String id,
    String name,
    double targetAmount,
    DateTime? targetDate,
  ) async {
    final body = {
      "name": name,
      "targetAmount": targetAmount,
      "targetDate": targetDate?.toIso8601String().split('T')[0],
    };
    await _apiClient.updateGoal(id, body);
  }

  @override
  Future<void> deleteGoal(String id) async {
    await _apiClient.deleteGoal(id);
  }
}
