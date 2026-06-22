import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/expense_model.dart';

part 'expenses_api_client.g.dart';

@RestApi()
abstract class ExpensesApiClient {
  factory ExpensesApiClient(Dio dio, {String baseUrl}) = _ExpensesApiClient;

  @GET("/api/expenses")
  Future<List<ExpenseModel>> getExpenses();

  @GET("/api/expenses/{id}")
  Future<ExpenseModel> getExpense(@Path("id") String id);

  @POST("/api/expenses")
  Future<void> createExpense(@Body() Map<String, dynamic> body);

  @PUT("/api/expenses/{id}")
  Future<void> updateExpense(@Path("id") String id, @Body() Map<String, dynamic> body);

  @DELETE("/api/expenses/{id}")
  Future<void> deleteExpense(@Path("id") String id);
}
