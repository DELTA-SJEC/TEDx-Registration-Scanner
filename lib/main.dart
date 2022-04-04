import 'package:TEDxSJEC/Pages/homeScreen.dart';
import 'package:TEDxSJEC/Pages/login_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TEDx SJEC',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: token.isEmpty ? const Login() : const Home(),
    );
  }
}
