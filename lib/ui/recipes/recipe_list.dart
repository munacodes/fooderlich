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
import '../../network/recipe_service.dart';

class RecipeList extends StatefulWidget {
  const RecipeList({Key? key}) : super(key: key);

  @override
  State createState() => _RecipeListState();
}

class _RecipeListState extends State<RecipeList> {
  static const String prefSearchKey = 'previousSearches';
  late TextEditingController searchTextController;
  final ScrollController _scrollController = ScrollController();
  List<APIHits> currentSearchList = [];

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

  @override
  void initState() {
    super.initState();

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
  Future<APIRecipeQuery> getRecipeData(String query, int from, int to) async {
    final recipeJson = await RecipeService().getRecipes(query, from, to);

    final recipeMap = json.decode(recipeJson);

    return APIRecipeQuery.fromJson(recipeMap);

    /* Here’s what this does:
1. The method is asynchronous and returns a Future. It takes a query and the start
and the end positions of the recipe data, which from and to represent,
respectively.
2. You define recipeJson, which stores the results from getRecipes() after it
finishes. It uses the from and to fields from step 1.
3. The variable recipeMap uses Dart’s json.decode() to decode the string into a
map of type Map<String, dynamic>.
4. You use the JSON parsing method you created in the previous chapter to create
an APIRecipeQuery model. */
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

// Adds getPreviousSearches
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
// This method is also asynchronous. Here, you:
// 1. Use the await keyword to wait for an instance of SharedPreferences.
// 2. Check if a preference for your saved list already exists.
// 3. Get the list of previous searches.
// 4. If the list is not null, set the previous searches, otherwise initialize an empty list.
  }

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

  Widget _buildRecipeLoader(BuildContext context) {
    if (searchTextController.text.length < 3) {
      return Container();
    }
    // TODO: change with new response
    return FutureBuilder<APIRecipeQuery>(
      // TODO: change with new RecipeService
      future: getRecipeData(searchTextController.text.trim(),
          currentStartPosition, currentEndPosition),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
                textAlign: TextAlign.center,
                textScaleFactor: 1.3,
              ),
            );
          }

          loading = false;
          // TODO: change with new snapshot
          final query = snapshot.data;
          inErrorState = false;
          if (query != null) {
            currentCount = query.count;
            hasMore = query.more;
            currentSearchList.addAll(query.hits);
            if (query.to < currentEndPosition) {
              currentEndPosition = query.to;
            }
          }
          return _buildRecipeList(context, currentSearchList);
        } else {
          if (currentCount == 0) {
            // Show a loading indicator while waiting for the movies
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return _buildRecipeList(context, currentSearchList);
          }
        }
      },
      /* Here’s what’s going on:
1. You check there are at least three characters in the search term. You can change
this value, but you probably won’t get good results with only one or two
characters.
2. FutureBuilder determines the current state of the Future that APIRecipeQuery
returns. It then builds a widget that displays asynchronous data while it’s
loading.
3. You assign the Future that getRecipeData() returns to future.
4. builder is required; it returns a widget.
5. You check the connectionState. If the state is done, you can update the UI with
the results or an error.
6. If there’s an error, return a simple Text element that displays the error message.
7. If there’s no error, process the query results and add query.hits to
currentSearchList.
8. If you aren’t at the end of the data, set currentEndPosition to the current
location.
9. Return _buildRecipeList() using currentSearchList. */
    );
  }

  Widget _buildRecipeList(BuildContext recipeListContext, List<APIHits> hits) {
    final size = MediaQuery.of(context).size;
    const itemHeight = 310;
    final itemWidth = size.width / 2;
    return Flexible(
      child: GridView.builder(
        controller: _scrollController,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: (itemWidth / itemHeight),
        ),
        itemCount: hits.length,
        itemBuilder: (BuildContext context, int index) {
          return _buildRecipeCard(recipeListContext, hits, index);
        },
      ),
    );

    /* Here’s what’s going on:
1. This method returns a widget and takes recipeListContext and a list of recipe
hits.
2. You use MediaQuery to get the device’s screen size. You then set a fixed item
height and create two columns of cards whose width is half the device’s width.
3. You return a widget that’s flexible in width and height.
4. GridView is similar to ListView, but it allows for some interesting combinations
of rows and columns. In this case, you use GridView.builder() because you
know the number of items and you’ll use an itemBuilder.
5. You use _scrollController, created in initState(), to detect when scrolling
gets to about 70% from the bottom.
6. The SliverGridDelegateWithFixedCrossAxisCount delegate has two columns
and sets the aspect ratio.
7. The length of your grid items depends on the number of items in the hits list.
8. itemBuilder now uses _buildRecipeCard() to return a card for each recipe.
_buildRecipeCard() retrieves the recipe from the hits list by using
hits[index].recipe. */
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
      child: recipeCard(recipe),
    );
  }
}
