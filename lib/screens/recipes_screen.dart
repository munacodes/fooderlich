import 'package:flutter/material.dart';
import 'package:fooderlinch/models/models.dart';
import '../api/mock_fooderlich_service.dart';
import '../components/components.dart';

class RecipesScreen extends StatelessWidget {
  final exploreService = MockFooderlichService();
  RecipesScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: exploreService.getRecipes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // TODO: Add RecipesGridView Here

            return RecipeGridView(recipe: snapshot.data as List<SimpleRecipe>);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });
  }
}
