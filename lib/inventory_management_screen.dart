import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';

class InventoryManagementScreen extends StatefulWidget {
  @override
  _InventoryManagementScreenState createState() =>
      _InventoryManagementScreenState();
}

class _InventoryManagementScreenState extends State<InventoryManagementScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  Future<void> addInventoryItem() async {
    String? pharmacyId = _auth.currentUser?.uid;
    if (pharmacyId != null) {
      await _firestore
          .collection('pharmacies')
          .doc(pharmacyId)
          .collection('inventory')
          .add({
        'itemName': _itemNameController.text,
        'category': _categoryController.text,
        'price': _priceController.text,
        'quantityAvailable': _quantityController.text,
      }).then((value) {
        // Clear the text fields
        _itemNameController.clear();
        _categoryController.clear();
        _priceController.clear();
        _quantityController.clear();
        // Optionally trigger a state update to refresh the inventory list
        setState(() {});
      });
    }
  }

  Future<void> pickAndParseExcelFile() async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['xlsx']);

    if (result != null) {
      // Logic to handle the Excel file will be here
    }
  }

  Stream<List<QueryDocumentSnapshot>> getInventoryStream() {
    String? pharmacyId = _auth.currentUser?.uid;
    if (pharmacyId != null) {
      return _firestore
          .collection('pharmacies')
          .doc(pharmacyId)
          .collection('inventory')
          .snapshots()
          .map((snapshot) => snapshot.docs);
    } else {
      return Stream.empty();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Inventory Management"),
      ),
      body: StreamBuilder<List<QueryDocumentSnapshot>>(
        stream: getInventoryStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Text("No inventory items found.");
          }

          Map<String, List<Widget>> categorizedItems = {};
          for (var doc in snapshot.data!) {
            var data = doc.data() as Map<String, dynamic>;
            String category = data['category'] ?? 'Uncategorized';
            String itemName = data['itemName'] ?? 'No Name';
            categorizedItems
                .putIfAbsent(category, () => [])
                .add(ListTile(title: Text(itemName)));
          }

          return Column(
            children: [
              Expanded(
                child: ListView(
                  children: categorizedItems.entries.map<Widget>((entry) {
                    return ExpansionTile(
                      title: Text(entry.key),
                      children: entry.value,
                    );
                  }).toList(),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _itemNameController,
                      decoration: InputDecoration(
                        labelText: "Item Name",
                      ),
                    ),
                    TextField(
                      controller: _categoryController,
                      decoration: InputDecoration(
                        labelText: "Category",
                      ),
                    ),
                    TextField(
                      controller: _priceController,
                      decoration: InputDecoration(
                        labelText: "Price",
                      ),
                    ),
                    TextField(
                      controller: _quantityController,
                      decoration: InputDecoration(
                        labelText: "Quantity Available",
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: addInventoryItem,
                      child: Text("Add Inventory Item"),
                    ),
                    ElevatedButton(
                      onPressed: pickAndParseExcelFile,
                      child: Text("Upload from Excel File"),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    // Dispose of controllers when the widget is removed from the widget tree
    _itemNameController.dispose();
    _categoryController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }
}
