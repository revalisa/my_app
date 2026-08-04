import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:my_app/pages/welcome_pages.dart';
import 'firebase_options.dart';
import 'package:my_app/pages/main_pages.dart';
import 'package:my_app/pages/login_page.dart';

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
      // meenghilangkan tulisan debug
      debugShowCheckedModeBanner: false,
      home: const WelcomePage(),
      // mengatur navigasi antar halaman
      routes: {
       '/home': (context) => const MainPages(),
       '/welcome': (context) => const WelcomePage(),
       '/login': (context) => const LoginPage(),
      },
    );
  }
}