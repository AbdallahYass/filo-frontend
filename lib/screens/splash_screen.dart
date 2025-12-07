// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'auth/login_screen.dart';
import '../../services/auth_service.dart';
import 'menu_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  final AuthService _authService = AuthService(); // تعريف خدمة التحقق

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.asset('assets/videos/intro.mp4')
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
        });
        _controller.setVolume(0.0);
        _controller.play();
      });

    // عند انتهاء الفيديو، نفذ دالة التحقق والانتقال
    _controller.addListener(() {
      if (_controller.value.position >= _controller.value.duration) {
        _checkAuthAndNavigate(); // 👈 استدعاء الدالة الجديدة
      }
    });
  }

  // 🔥🔥🔥 الدالة المعدلة التي تتحقق من التوكن وتحدد الوجهة 🔥🔥🔥
  Future<void> _checkAuthAndNavigate() async {
    // نوقف الفيديو أولاً لمنع استمراره في الخلفية
    _controller.pause();

    // للتأكد من عدم تنفيذ الدالة أكثر من مرة عند انتهاء الفيديو والضغط على تخطي في نفس الوقت
    if (ModalRoute.of(context)?.isCurrent == false) return;

    // 1. فحص حالة التوكن
    bool isLoggedIn = await _authService.isLoggedIn();

    // 2. تحديد الوجهة بناءً على حالة تسجيل الدخول
    Widget nextScreen = isLoggedIn ? const MenuScreen() : const LoginScreen();

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => nextScreen,
        ), // 👈 الانتقال الذكي
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. طبقة الفيديو (في الخلفية)
          Center(
            child: _isInitialized
                ? SizedBox.expand(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _controller.value.size.width,
                        height: _controller.value.size.height,
                        child: VideoPlayer(_controller),
                      ),
                    ),
                  )
                : Container(), // شاشة سوداء حتى يجهز
          ),

          // 2. طبقة زر التخطي (في الأمام)
          if (_isInitialized)
            Positioned(
              top: 50,
              right: 20,
              child: GestureDetector(
                onTap: _checkAuthAndNavigate, // 👈 عند الضغط، نفذ دالة التحقق
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        "Skip",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(width: 5),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 12,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
