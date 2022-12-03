import 'package:json_annotation/json_annotation.dart';
part 'recipe_model.g.dart';

@JsonSerializable()
class APIRecipeQuery {
  // TODO: Add APIRecipeQuery.fromJson
  factory APIRecipeQuery.fromJson(Map<String, dynamic> json) =>
      _$APIRecipeQueryFromJson(json);
  Map<String, dynamic> toJson() => $APIRecipeQueryToJson(this);

  // Adds a field here
  @JsonKey(name: 'q')
  String query;
  int from;
  int to;
  bool more;
  int count;
  List<APIHits> hits;

  // Adds APIRecipeQuery constructor
  APIRecipeQuery({
    required this.query,
    required this.from,
    required this.to,
    required this.more,
    required this.count,
    required this.hits,
  });
}

// TODO: Add @JsonSerializable() class APIHits
// TODO: Add @JsonSerializable() class APIRecipe
// TODO: Add @JsonSerializable() class APIIngredients

