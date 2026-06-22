import 'package:expense_track_frontend/features/reporting/domain/repositories/reporting_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../data/models/budget_model.dart';
import '../../data/models/goal_model.dart';
import '../../data/repositories/reporting_repository_impl.dart';

final budgetsViewModelProvider =
    StateNotifierProvider<BudgetsViewModel, AsyncValue<List<BudgetModel>>>((
      ref,
    ) {
      final repository = ref.watch(reportingRepositoryProvider);
      return BudgetsViewModel(repository);
    });

class BudgetsViewModel extends StateNotifier<AsyncValue<List<BudgetModel>>> {
  final ReportingRepository _repository;

  BudgetsViewModel(this._repository) : super(const AsyncValue.loading()) {
    fetchBudgets();
  }

  Future<void> fetchBudgets() async {
    try {
      state = const AsyncValue.loading();
      final budgets = await _repository.getBudgets();
      state = AsyncValue.data(budgets);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createBudget(
    String name,
    double monthlyLimit,
    DateTime startDate,
    DateTime? endDate,
  ) async {
    await _repository.createBudget(name, monthlyLimit, startDate, endDate);
    await fetchBudgets();
  }

  Future<void> updateBudget(
    String id,
    String name,
    double monthlyLimit,
    DateTime startDate,
    DateTime? endDate,
  ) async {
    await _repository.updateBudget(id, name, monthlyLimit, startDate, endDate);
    await fetchBudgets();
  }

  Future<void> deleteBudget(String id) async {
    await _repository.deleteBudget(id);
    await fetchBudgets();
  }
}

final goalsViewModelProvider =
    StateNotifierProvider<GoalsViewModel, AsyncValue<List<GoalModel>>>((ref) {
      final repository = ref.watch(reportingRepositoryProvider);
      return GoalsViewModel(repository);
    });

class GoalsViewModel extends StateNotifier<AsyncValue<List<GoalModel>>> {
  final ReportingRepository _repository;

  GoalsViewModel(this._repository) : super(const AsyncValue.loading()) {
    fetchGoals();
  }

  Future<void> fetchGoals() async {
    try {
      state = const AsyncValue.loading();
      final goals = await _repository.getGoals();
      state = AsyncValue.data(goals);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createGoal(
    String name,
    double targetAmount,
    DateTime? targetDate,
  ) async {
    await _repository.createGoal(name, targetAmount, targetDate);
    await fetchGoals();
  }

  Future<void> updateGoal(
    String id,
    String name,
    double targetAmount,
    DateTime? targetDate,
  ) async {
    await _repository.updateGoal(id, name, targetAmount, targetDate);
    await fetchGoals();
  }

  Future<void> deleteGoal(String id) async {
    await _repository.deleteGoal(id);
    await fetchGoals();
  }
}
