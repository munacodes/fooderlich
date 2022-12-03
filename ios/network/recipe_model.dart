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

// Adds @JsonSerializable() class APIHits
@JsonSerializable()
class APIHits {
  APIRecipe recipe;

  APIHits({
    required this.recipe,
  });

  factory APIHits.fromJson(Map<String, dynamic> json) =>
      _$APIHitsFromJson(json);
  Map<String, dynamic> toJson() => _$APIHitsToJson(this);
}

// Adds @JsonSerializable() class APIRecipe
@JsonSerializable()
class APIRecipe {
  String label;
  String image;
  String url;

  List<APIIngredients> ingredients;
  double calories;
  double totalWeight;
  double totalTime;
  APIRecipe({
    required this.label,
    required this.image,
    required this.url,
    required this.ingredients,
    required this.calories,
    required this.totalWeight,
    required this.totalTime,
  });

  factory APIRecipe.fromJson(Map<String, dynamic> json) =>
      _$APIRecipeFromJson(json);
  Map<String, dynamic> toJson() => _$APIRecipeToJson(this);
}
// TODO: Add global Helper Functions

// TODO: Add @JsonSerializable() class APIIngredients

