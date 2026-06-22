import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/budget_model.dart';
import '../models/goal_model.dart';

part 'reporting_api_client.g.dart';

@RestApi()
abstract class ReportingApiClient {
  factory ReportingApiClient(Dio dio, {String baseUrl}) = _ReportingApiClient;

  @GET("/api/budgets")
  Future<List<BudgetModel>> getBudgets();

  @POST("/api/budgets")
  Future<void> createBudget(@Body() Map<String, dynamic> body);

  @PUT("/api/budgets/{id}")
  Future<void> updateBudget(@Path("id") String id, @Body() Map<String, dynamic> body);

  @DELETE("/api/budgets/{id}")
  Future<void> deleteBudget(@Path("id") String id);

  @GET("/api/goals")
  Future<List<GoalModel>> getGoals();

  @POST("/api/goals")
  Future<void> createGoal(@Body() Map<String, dynamic> body);

  @PUT("/api/goals/{id}")
  Future<void> updateGoal(@Path("id") String id, @Body() Map<String, dynamic> body);

  @DELETE("/api/goals/{id}")
  Future<void> deleteGoal(@Path("id") String id);
}
