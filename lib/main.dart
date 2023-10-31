import 'dart:async';

import 'package:flutter/material.dart';
import 'package:stock_app/screen/add_item_screen.dart';
import 'package:stock_app/screen/add_order_screen.dart';
import 'package:stock_app/screen/home_screen.dart';
import 'package:stock_app/screen/login_screen.dart';
import 'package:stock_app/screen/register_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late StreamSubscription<User?> user;
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    user = _auth.authStateChanges().listen((user) {
      if (user == null) {
        print("User currently signed out");
      } else {
        print("User is signed in!");
      }
    });
  }

  @override
  void dispose() {
    user.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: _auth.currentUser == null ? LoginScreen.id : HomeScreen.id,
      routes: {
        HomeScreen.id: (context) => HomeScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        RegisterScreen.id: (context) => RegisterScreen(),
        AddItemScreen.id: (context) => AddItemScreen(),
        AddOrderScreen.id: (context) => AddOrderScreen(),
      },
    );
  }
}
