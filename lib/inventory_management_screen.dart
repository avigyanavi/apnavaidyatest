import 'package:apnavaidyatest/drug_details.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'dart:io';

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
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      withReadStream: true,
    );

    if (result != null) {
      var bytes = File(result.files.single.path!).readAsBytesSync();
      var excel = Excel.decodeBytes(bytes);

      for (var table in excel.tables.keys) {
        for (var row in excel.tables[table]!.rows) {
          String itemName = (row[0]?.value ?? '').toString();
          String category = (row[1]?.value ?? '').toString();
          String price = row[2]?.value.toString() ?? '';
          String quantityAvailable = row[3]?.value.toString() ?? '';

          await _firestore
              .collection('pharmacies')
              .doc(_auth.currentUser?.uid)
              .collection('inventory')
              .add({
            'itemName': itemName,
            'category': category,
            'price': price,
            'quantityAvailable': quantityAvailable,
          });
        }
      }
      setState(() {}); // Refresh the list after adding items
    }
  }

  Future<void> deleteCategory(String category) async {
    String? pharmacyId = _auth.currentUser?.uid;
    if (pharmacyId != null) {
      var querySnapshot = await _firestore
          .collection('pharmacies')
          .doc(pharmacyId)
          .collection('inventory')
          .where('category', isEqualTo: category)
          .get();

      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
      setState(() {}); // Refresh the list after deleting items
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
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No inventory items found."));
          }

          Map<String, List<Widget>> categorizedItems = {};
          for (var doc in snapshot.data!) {
            var data = doc.data() as Map<String, dynamic>;
            String category = data['category'] ?? 'Uncategorized';
            String itemName = data['itemName'] ?? 'No Name';
            String price = data['price'] ?? 'No Price';
            String quantityAvailable = data['quantityAvailable'] ?? '0';
            categorizedItems.putIfAbsent(category, () => []).add(
                  InkWell(
                    onTap: () {
                      // Navigate to DrugDetailsScreen with the drug details
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => DrugDetailsScreen(
                          itemName: itemName,
                          price: price,
                          quantityAvailable: quantityAvailable,
                        ),
                      ));
                    },
                    child: ListTile(
                      title: Text(itemName),
                    ),
                  ),
                );
          }

          return Column(
            children: [
              Expanded(
                child: ListView(
                  children: categorizedItems.entries.map<Widget>((entry) {
                    return ExpansionTile(
                      title: Text(entry.key),
                      children: entry.value,
                      // Add a trailing icon/button to delete the category
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => deleteCategory(entry.key),
                      ),
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
