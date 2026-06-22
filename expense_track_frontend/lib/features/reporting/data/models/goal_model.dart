import 'package:json_annotation/json_annotation.dart';

part 'goal_model.g.dart';

@JsonSerializable()
class GoalModel {
  final String id;
  final String userId;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime? targetDate;

  GoalModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    this.targetDate,
  });

  factory GoalModel.fromJson(Map<String, dynamic> json) => _$GoalModelFromJson(json);
  Map<String, dynamic> toJson() => _$GoalModelToJson(this);
}
