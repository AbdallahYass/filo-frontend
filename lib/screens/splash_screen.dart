import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'menu_screen.dart';

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

    // 1. تحديد مسار الفيديو
    _controller = VideoPlayerController.asset('assets/videos/intro.mp4')
      ..initialize().then((_) {
        // 2. عند انتهاء التحميل، ابدأ التشغيل
        setState(() {
          _isInitialized = true;
        });
        _controller.setVolume(
          0.0,
        ); // كتم الصوت (اختياري، لضمان التشغيل التلقائي)
        _controller.play();
      });

    // 3. مراقبة الفيديو لمعرفة متى ينتهي
    _controller.addListener(() {
      // إذا وصل الفيديو للنهاية
      if (_controller.value.position >= _controller.value.duration) {
        _navigateToHome();
      }
    });
  }

  // دالة الانتقال للمنيو (تضمن عدم التكرار)
  void _navigateToHome() {
    // التأكد من عدم الانتقال أكثر من مرة
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MenuScreen()),
      );
    }
  }

  @override
  void dispose() {
    // تنظيف الذاكرة وإغلاق الفيديو عند الخروج
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // لون خلفية أثناء تحميل الفيديو
      body: Center(
        child: _isInitialized
            ? SizedBox.expand(
                child: FittedBox(
                  // هذا يجعل الفيديو يملأ الشاشة بالكامل (Full Screen)
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _controller.value.size.width,
                    height: _controller.value.size.height,
                    child: VideoPlayer(_controller),
                  ),
                ),
              )
            : Container(), // شاشة سوداء حتى يجهز الفيديو
      ),
    );
  }
}
