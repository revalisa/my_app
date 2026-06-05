import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:my_app/pages/login_page.dart';
import 'firebase_options.dart';
import 'package:my_app/pages/main_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LoginPage(),
      routes: {
       '/home': (context) => const MainPages(),
       '/login': (context) => const LoginPage(),
      },
    );
  }
}