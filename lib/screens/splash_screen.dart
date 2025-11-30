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
  // 1️⃣ متغير للتحكم في ظهور البرق
  bool _showLightning = true;
  final Color goldColor = const Color(0xFFC5A028);

  @override
  void initState() {
    super.initState();
    startAnimationsSequence();
  }

  // دالة لترتيب ظهور الانميشن
  void startAnimationsSequence() {
    // 2️⃣ المؤقت الأول: مدة ظهور البرق (مثلاً 2.5 ثانية)
    Timer(const Duration(milliseconds: 2500), () {
      // بعد انتهاء وقت البرق، نغير الحالة لإظهار الشاشة الثانية
      setState(() {
        _showLightning = false;
      });

      // 3️⃣ المؤقت الثاني: مدة ظهور شاشة التحميل العادية قبل الانتقال (مثلاً 3 ثواني إضافية)
      Timer(const Duration(seconds: 3), () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MenuScreen()),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // جعلنا الخلفية سوداء لتتناسب مع البرق
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // --- الطبقة السفلية: شاشة التحميل العادية (صورتك والمؤشر) ---
          // نستخدم AnimatedOpacity لجعلها تظهر بنعومة (Fade In)
          AnimatedOpacity(
            opacity: _showLightning
                ? 0.0
                : 1.0, // إذا البرق شغال، اختفي، وإلا اظهري
            duration: const Duration(
              milliseconds: 800,
            ), // مدة ظهور الشاشة بنعومة
            child: Stack(
              fit: StackFit.expand,
              children: [
                // الخلفية
                Image.asset('assets/icons/splash_bg.png', fit: BoxFit.cover),

                // المؤشر والنص
                Positioned(
                  bottom: 30,
                  left: 0,
                  right: 0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
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
          ),

          // --- الطبقة العلوية: انميشن البرق ---
          // تظهر فقط عندما يكون _showLightning يساوي true
          if (_showLightning)
            Center(
              // ⚠️ استبدل هذا الجزء بـ انميشن البرق الخاص بك (GIF أو Lottie)
              child: Icon(
                Icons.bolt_rounded, // أيقونة برق كمثال
                color: goldColor,
                size: 150, // حجم كبير
              ),
              // مثال لو عندك صورة GIF:
              // Image.asset('assets/animations/lightning.gif', width: 200),
            ),
        ],
      ),
    );
  }
}
