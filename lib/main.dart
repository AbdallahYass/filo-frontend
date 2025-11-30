import 'package:flutter/material.dart';
import 'screens/splash_screen.dart'; // استدعاء ملف السبلاش الجديد

void main() {
  runApp(const FiloMenuApp());
}

class FiloMenuApp extends StatelessWidget {
  const FiloMenuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Filo Menu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        primaryColor: Colors.black,
        // ... (بقية الثيم الخاص بك كما هو)
      ),
      // اجعل نقطة البداية هي شاشة السبلاش
      home: const SplashScreen(),
    );
  }
}
