import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'home_page.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyAC8al5YETfS8A3xjHXBcjrfojsu28ZV9E",
          authDomain: "snakegame-9b8ae.firebaseapp.com",
          projectId: "snakegame-9b8ae",
          storageBucket: "snakegame-9b8ae.appspot.com",
          messagingSenderId: "767807658992",
          appId: "1:767807658992:web:c4edcfb55e3ad88efcdb35"));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
      theme: ThemeData(brightness: Brightness.dark),
    );
  }
}
