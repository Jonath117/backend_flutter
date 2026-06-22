// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExpenseModel _$ExpenseModelFromJson(Map<String, dynamic> json) => ExpenseModel(
  id: json['id'] as String,
  amount: (json['amount'] as num).toDouble(),
  title: json['title'] as String,
  description: json['description'] as String?,
  expenseDate: DateTime.parse(json['expenseDate'] as String),
  categoryId: json['categoryId'] as String,
  images:
      (json['images'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
);

Map<String, dynamic> _$ExpenseModelToJson(ExpenseModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'amount': instance.amount,
      'title': instance.title,
      'description': instance.description,
      'expenseDate': instance.expenseDate.toIso8601String(),
      'categoryId': instance.categoryId,
      'images': instance.images,
    };
