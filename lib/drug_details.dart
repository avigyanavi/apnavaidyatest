import 'package:flutter/material.dart';

class DrugDetailsScreen extends StatelessWidget {
  final String itemName;
  final String price;
  final String quantityAvailable;

  const DrugDetailsScreen({
    super.key,
    required this.itemName,
    required this.price,
    required this.quantityAvailable,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(itemName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Name: $itemName", style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text("Price: $price", style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text("Quantity Available: $quantityAvailable",
                style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
