import 'package:json_annotation/json_annotation.dart';

part 'budget_model.g.dart';

@JsonSerializable()
class BudgetModel {
  final String id;
  final String userId;
  final String name;
  final double monthlyLimit;
  final DateTime startDate;
  final DateTime? endDate;
  final List<String> categoryIds;

  BudgetModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.monthlyLimit,
    required this.startDate,
    this.endDate,
    required this.categoryIds,
  });

  factory BudgetModel.fromJson(Map<String, dynamic> json) => _$BudgetModelFromJson(json);
  Map<String, dynamic> toJson() => _$BudgetModelToJson(this);
}
