import 'package:json_annotation/json_annotation.dart';

part 'category_model.g.dart';

@JsonSerializable()
class CategoryModel {
  final String id;
  final String name;
  final String? icon;
  final String? color;

  CategoryModel({required this.id, required this.name, this.icon, this.color});

  factory CategoryModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryModelFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryModelToJson(this);
}
