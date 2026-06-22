import 'package:json_annotation/json_annotation.dart';

part 'expense_model.g.dart';

@JsonSerializable()
class ExpenseModel {
  final String id;
  final double amount;
  final String title;
  final String? description;
  final DateTime expenseDate;
  final String categoryId;
  final List<String> images;

  ExpenseModel({
    required this.id,
    required this.amount,
    required this.title,
    this.description,
    required this.expenseDate,
    required this.categoryId,
    this.images = const [],
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) =>
      _$ExpenseModelFromJson(json);
  Map<String, dynamic> toJson() => _$ExpenseModelToJson(this);
}
