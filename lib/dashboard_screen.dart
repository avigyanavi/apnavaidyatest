import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'orders_screen.dart';
import 'inventory_management_screen.dart';

class DashboardScreen extends StatelessWidget {
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard"),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              _auth.signOut();
              Navigator.popUntil(context, ModalRoute.withName('/'));
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName:
                  Text(user?.email ?? 'No User'), // Safe check for null user
              accountEmail: Text("Pharmacy Dashboard"),
            ),
            ListTile(
              leading: Icon(Icons.dashboard),
              title: Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.shopping_cart),
              title: Text('Orders'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => OrdersScreen()));
              },
            ),
            ListTile(
              leading: Icon(Icons.list_alt),
              title: Text('Inventory Management'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => InventoryManagementScreen()));
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Text(
            "Welcome to the Pharmacy Dashboard, ${user?.email ?? 'User'}!"),
      ),
    );
  }
}
