import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/custom_dropdown.dart';
import '../colors.dart';

import 'dart:convert';
import '../../network/recipe_model.dart';
import 'package:flutter/services.dart';
import '../recipe_card.dart';
import 'recipe_details.dart';

class RecipeList extends StatefulWidget {
  const RecipeList({Key? key}) : super(key: key);

  @override
  State createState() => _RecipeListState();
}

class _RecipeListState extends State<RecipeList> {
  static const String prefSearchKey = 'previousSearches';
  late TextEditingController searchTextController;
  final ScrollController _scrollController = ScrollController();
  List currentSearchList = [];
  int currentCount = 0;
  int currentStartPosition = 0;
  int currentEndPosition = 20;
  int pageCount = 20;
  bool hasMore = false;
  bool loading = false;
  bool inErrorState = false;

  // searches array.
  // This clears the way for you to save the user’s previous searches and keep track of the current search
  List<String> previousSearches = <String>[];

  // Adds _currentRecipes1
  APIRecipeQuery? _currentRecipes1;

  @override
  void initState() {
    super.initState();

    // Calls loadRecipes()
    loadRecipes();

// Call getPreviousSearches
    getPreviousSearches();
// This loads any previous searches when the user restarts the app.

    searchTextController = TextEditingController(text: '');
    _scrollController.addListener(() {
      final triggerFetchMoreSize =
          0.7 * _scrollController.position.maxScrollExtent;

      if (_scrollController.position.pixels > triggerFetchMoreSize) {
        if (hasMore &&
            currentEndPosition < currentCount &&
            !loading &&
            !inErrorState) {
          setState(() {
            loading = true;
            currentStartPosition = currentEndPosition;
            currentEndPosition =
                min(currentStartPosition + pageCount, currentCount);
          });
        }
      }
    });
  }

  // Adds loadRecipes
  Future loadRecipes() async {
    final jsonString = await rootBundle.loadString('assets/recipes1.json');
    setState(() {
      _currentRecipes1 = APIRecipeQuery.fromJson(jsonDecode(jsonString));
    });
  }

  @override
  void dispose() {
    searchTextController.dispose();
    super.dispose();
  }

  // savePreviousSearches
  void savePreviousSearches() async {
    final prefs = await SharedPreferences.getInstance();

    prefs.setStringList(prefSearchKey, previousSearches);
  }
// Here, you use the async keyword to indicate that this method will run
// asynchronously. It also:
// 1. Uses the await keyword to wait for an instance of SharedPreferences.
// 2. Saves the list of previous searches using the prefSearchKey key.

// TODO: Add getPreviousSearches
  void getPreviousSearches() async {
    final prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey(prefSearchKey)) {
      final searches = prefs.getStringList(prefSearchKey);

      if (searches != null) {
        previousSearches = searches;
      } else {
        previousSearches = <String>[];
      }
    }
  }
// This method is also asynchronous. Here, you:
// 1. Use the await keyword to wait for an instance of SharedPreferences.
// 2. Check if a preference for your saved list already exists.
// 3. Get the list of previous searches.
// 4. If the list is not null, set the previous searches, otherwise initialize an empty list.

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            _buildSearchCard(),
            _buildRecipeLoader(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchCard() {
    return Card(
      elevation: 4,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0))),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                startSearch(searchTextController.text);

                final currentFocus = FocusScope.of(context);
                if (!currentFocus.hasPrimaryFocus) {
                  currentFocus.unfocus();
                }
              },
              // This replaces the icon with an IconButton that the user can tap to perform a search.
              // 1. Add onPressed to handle the tap event.
              // 2. Use the current search text to start a search.
              // 3. Hide the keyboard by using the FocusScope class
            ),
            const SizedBox(
              width: 6.0,
            ),
            Expanded(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                          border: InputBorder.none, hintText: 'Search'),
                      autofocus: false,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (value) {
                        startSearch(searchTextController.text);
                      },
                      controller: searchTextController,
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: lightGrey,
                    ),
                    onSelected: (String value) {
                      searchTextController.text = value;
                      startSearch(searchTextController.text);
                    },
                    itemBuilder: (BuildContext context) {
                      return previousSearches
                          .map<CustomDropdownMenuItem<String>>((String value) {
                        return CustomDropdownMenuItem<String>(
                          text: value,
                          value: value,
                          callback: () {
                            setState(() {
                              previousSearches.remove(value);
                              savePreviousSearches();
                              Navigator.pop(context);
                            });
                          },
                        );
                      }).toList();
                    },
                  ),
                ],
              ),
              // In this code, you:
              // 1. Add a TextField to enter your search queries.
              // 2. Set the keyboard action to TextInputAction.done. This closes the keyboard when the user presses the Done button.
              // 3. Start the search when the user finishes entering text.
              // 4. Create a PopupMenuButton to show previous searches.
              // 5. When the user selects an item from previous searches, start a new search.
              // 6. Build a list of custom drop-down menus (see widgets/custom_dropdown.dart) to display previous searches.
              // 7. If the X icon is pressed, remove the search from the previous searches and close the pop-up menu.
            ),
          ],
        ),
      ),
    );
  }

  // StartSearch
  void startSearch(String value) {
    setState(() {
      currentSearchList.clear();
      currentCount = 0;
      currentEndPosition = pageCount;
      currentStartPosition = 0;
      hasMore = true;
      value = value.trim();

      if (!previousSearches.contains(value)) {
        previousSearches.add(value);

        savePreviousSearches();
      }
    });
  }
// In this method, you:
// 1. Tell the system to redraw the widgets by calling setState().
// 2. Clear the current search list and reset the count, start and end positions.
// 3. Check to make sure the search text hasn’t already been added to the previous search list.
// 4. Add the search item to the previous search list.
// 5. Save the new list of previous searches.

  // TODO: Replace method
  Widget _buildRecipeLoader(BuildContext context) {
    if (_currentRecipes1 == null || _currentRecipes1?.hits == null) {
      return Container();
    }
    // Show a loading indicator while waiting for the recipes

    return Flexible(
      child: ListView.builder(
        itemCount: 1,
        itemBuilder: (BuildContext context, int index) {
          return Center(
              child: _buildRecipeCard(context, _currentRecipes1!.hits, 0));
        },
      ),
    );
  }

  // Adds _buildRecipeCard
  Widget _buildRecipeCard(
      BuildContext topLevelContext, List<APIHits> hits, int index) {
    final recipe = hits[index].recipe;
    return GestureDetector(
      onTap: () {
        Navigator.push(topLevelContext, MaterialPageRoute(
          builder: (context) {
            return const RecipeDetails();
          },
        ));
      },
      child: recipeStringCard(recipe.image, recipe.label),
    );
  }
}
