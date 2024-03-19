import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  String? email;
  String? password;
  String? pharmacyName;
  String? address;
  String? contact;
  String? owner;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sign Up")),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                validator: (value) =>
                    value!.isEmpty ? "Please enter an email" : null,
                onChanged: (value) {
                  email = value.trim();
                },
                decoration: InputDecoration(hintText: "Email"),
              ),
              TextFormField(
                obscureText: true,
                validator: (value) => value!.length < 6
                    ? "Password must be at least 6 characters"
                    : null,
                onChanged: (value) {
                  password = value;
                },
                decoration: InputDecoration(hintText: "Password"),
              ),
              TextFormField(
                validator: (value) =>
                    value!.isEmpty ? "Please enter the pharmacy name" : null,
                onChanged: (value) {
                  pharmacyName = value.trim();
                },
                decoration: InputDecoration(hintText: "Pharmacy Name"),
              ),
              TextFormField(
                validator: (value) =>
                    value!.isEmpty ? "Please enter an address" : null,
                onChanged: (value) {
                  address = value.trim();
                },
                decoration: InputDecoration(hintText: "Address"),
              ),
              TextFormField(
                validator: (value) =>
                    value!.isEmpty ? "Please enter a contact number" : null,
                onChanged: (value) {
                  contact = value.trim();
                },
                decoration: InputDecoration(hintText: "Contact Number"),
              ),
              TextFormField(
                validator: (value) =>
                    value!.isEmpty ? "Please enter the owner's name" : null,
                onChanged: (value) {
                  owner = value.trim();
                },
                decoration: InputDecoration(hintText: "Owner's Name"),
              ),
              ElevatedButton(
                child: Text('Sign Up'),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      final newUser =
                          await _auth.createUserWithEmailAndPassword(
                              email: email!, password: password!);
                      if (newUser != null) {
                        await _firestore
                            .collection('pharmacies')
                            .doc(newUser.user!.uid)
                            .set({
                          'pharmacyName': pharmacyName,
                          'address': address,
                          'contact': contact,
                          'owner': owner,
                          'registrationDate': DateTime.now().toString(),
// 'type': 'chain', // Include this if needed, or add a way for users to specify the type
// 'chainId': '', // Include this if it's part of a chain
                        });
                        Navigator.pushNamed(context, '/dashboard');
                      }
                    } on FirebaseAuthException catch (e) {
                      Fluttertoast.showToast(
                          msg: e.message ?? 'An error occurred during sign up');
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
