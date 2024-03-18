import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  String? email;
  String? password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sign Up")),
      body: Form(
        key: _formKey,
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
            ElevatedButton(
              child: Text('Sign Up'),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  try {
                    final newUser = await _auth.createUserWithEmailAndPassword(
                        email: email!, password: password!);
                    if (newUser != null) {
                      Navigator.pushNamed(context, '/dashboard');
                    }
                  } catch (e) {
                    Fluttertoast.showToast(msg: e.toString());
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
