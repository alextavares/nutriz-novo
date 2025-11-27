import 'package:flutter/material.dart';

class FoodSearchDialog extends StatelessWidget {
  const FoodSearchDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return const Dialog(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(decoration: InputDecoration(hintText: 'Search food...')),
          ],
        ),
      ),
    );
  }
}
