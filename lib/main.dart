import 'package:apnavaidyatest/forgot_password.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'login_screen.dart'; // Ensure you have this file created
import 'sign_up_screen.dart'; // Ensure you have this file created
import 'dashboard_screen.dart'; // Ensure you have this file created
import 'package:firebase_auth/firebase_auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
        apiKey: "AIzaSyCDQRvz8jLfShRWMLPSobA8a8Leb_FsDe8",
        authDomain: "apna-vaidya.firebaseapp.com",
        projectId: "apna-vaidya",
        storageBucket: "apna-vaidya.appspot.com",
        messagingSenderId: "422927221797",
        appId: "1:422927221797:web:6b9e75cf5994a9ade9abcc",
        measurementId: "G-BBBDGCZM1S"),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pharmacy App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => LoginScreen(), // Default route
        '/signUp': (context) => SignUpScreen(), // Sign Up screen
        '/dashboard': (context) => DashboardScreen(), // Dashboard after login
        '/forgotPassword': (context) =>
            ForgotPasswordScreen() // Forgot Password screen
      },
    );
  }
}
