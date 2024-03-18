import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
              accountName: Text(user!.email!), // Assuming the user is not null
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
                // Navigate to Orders Screen
              },
            ),
            ListTile(
              leading: Icon(Icons.list_alt),
              title: Text('Inventory Management'),
              onTap: () {
                // Navigate to Inventory Management Screen
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Text("Welcome to the Pharmacy Dashboard, ${user.email}!"),
      ),
    );
  }
}
