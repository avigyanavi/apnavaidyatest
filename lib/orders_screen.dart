import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrdersScreen extends StatefulWidget {
  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<QuerySnapshot>? getOrdersStream() {
    User? currentUser = _auth.currentUser;
    // Assuming that pharmacyId is the same as the user's UID.
    if (currentUser != null) {
      String pharmacyId = currentUser.uid;
      return _firestore
          .collection('orders')
          .where('pharmacyId', isEqualTo: pharmacyId) // Filter by pharmacyId
          .orderBy('patientName') // Order by patient name
          .snapshots();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Orders"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: getOrdersStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No orders for this pharmacy."));
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> order =
                  document.data() as Map<String, dynamic>;
              return Card(
                child: ExpansionTile(
                  title: Text(order['patientName'] ?? 'No name provided'),
                  subtitle: Text('Order ID: ${order['orderId']}'),
                  children: <Widget>[
                    ListTile(
                      title: Text('Order Date: ${order['orderDate'].toDate()}'),
                      subtitle: Text('Status: ${order['status']}'),
                    ),
                    ExpansionTile(
                      title: Text('Items'),
                      children: order['orderItems']
                          .map<Widget>((item) => ListTile(
                                title: Text(item),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
