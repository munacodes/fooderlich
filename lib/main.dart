import 'package:flutter/material.dart';
import 'package:fooderlinch/models/models.dart';
import 'package:provider/provider.dart';

import 'fooderlich_theme.dart';
import 'home.dart';

void main() {
  runApp(const Fooderlich());
}

class Fooderlich extends StatelessWidget {
  const Fooderlich({super.key});
  @override
  Widget build(BuildContext context) {
    final theme = FooderlichTheme.dark();
    return MaterialApp(
      theme: theme,
      title: 'Fooderlich',
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => TabManager(),
          ),
          ChangeNotifierProvider(
            create: (context) => GroceryManager(),
          )
        ],
        child: const Home(),
      ),
    );
  }
}
