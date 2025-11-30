// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import 'menu_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // ⚠️ تصحيح: تم تعديل الوقت من 300 إلى 3 ثوانٍ
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MenuScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color goldColor = Color(0xFFC5A028);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // الخلفية
          Image.asset('assets/icons/splash_bg.png', fit: BoxFit.cover),

          // المؤشر والنص
          Positioned(
            // 👇 هنا التعديل: غيرنا القيمة من 80 إلى 30 لينزل للأسفل أكثر
            bottom: 30,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  color: goldColor,
                  strokeWidth: 3,
                ),
                const SizedBox(height: 20),
                Text(
                  "جاري تحضير القائمة...",
                  style: TextStyle(
                    color: goldColor.withOpacity(0.8),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
