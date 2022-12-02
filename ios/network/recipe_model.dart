import 'package:json_annotation/json_annotation.dart';
part 'recipe_model.g.dart';

@JsonSerializable()
class APIRecipeQuery {
  // TODO: Add APIRecipeQuery.fromJson
  factory APIRecipeQuery.fromJson(Map<String, dynamic> json) =>
      _$APIRecipeQueryFromJson(json);
  Map<String, dynamic> toJson() => $APIRecipeQueryToJson(this);
  @JsonKey(name: 'q')
  String query;
  int from;
  int to;
  bool more;
  int count;
  List<APIHits> hits;
  // TODO: Add APIRecipeQuery constructor
}

// TODO: Add @JsonSerializable() class APIHits
// TODO: Add @JsonSerializable() class APIRecipe
// TODO: Add @JsonSerializable() class APIIngredients

