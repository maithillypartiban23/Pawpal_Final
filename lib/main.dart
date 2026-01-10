import 'package:flutter/material.dart';
import 'package:pawpal1/views/splashscreen.dart';


void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PawPal Pet Adoption and Donation App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          backgroundColor: const Color(0xFFA66A46),
          foregroundColor: Colors.white,
        ),
      ),
      home: const SplashScreen(),
    );
        
  }
}
