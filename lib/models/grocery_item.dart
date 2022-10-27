import 'package:flutter/material.dart';

enum Importance { low, medium, high }

class GroceryItem {
  final String id;
  final String name;
  final Importance importance;
  final Color color;
  final int quantity;
  final DateTime date;
  final bool isComplete;

  GroceryItem(
      {required this.id,
      required this.name,
      required this.importance,
      required this.color,
      required this.quantity,
      required this.date,
      this.isComplete = false});

  GroceryItem copyWith({
    required String id,
    required String name,
    required Importance importance,
    required Color color,
    required int quantity,
    required DateTime date,
    required bool isComplete,
  }) {
    return GroceryItem(
        id: id,
        name: name,
        importance: importance,
        color: color,
        quantity: quantity,
        date: date,
        isComplete: isComplete);
  }
}
