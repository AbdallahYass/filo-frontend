import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

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

    _controller.addListener(() {
      if (_controller.value.position >= _controller.value.duration) {
        _navigateToHome();
      }
    });
  }

  void _navigateToHome() {
    // إيقاف الفيديو قبل الانتقال لضمان عدم استمرار الصوت أو العمل في الخلفية
    _controller.pause();

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
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
      // 👇👇👇 استخدمنا Stack لوضع العناصر فوق بعضها
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
          // يظهر فقط عندما يبدأ الفيديو بالعمل
          if (_isInitialized)
            Positioned(
              top: 50, // مسافة من الأعلى
              right: 20, // مسافة من اليمين
              child: GestureDetector(
                onTap: _navigateToHome, // عند الضغط، نفذ نفس دالة الانتقال
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5), // خلفية شفافة
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
