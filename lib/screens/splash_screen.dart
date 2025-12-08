// ignore_for_file: deprecated_member_use, use_build_context_synchronously, unnecessary_cast

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart'; // مكتبة التحقق من الاتصال
import 'package:geolocator/geolocator.dart';
import '../../services/auth_service.dart';
import 'menu_screen.dart';
import 'auth/login_screen.dart';
import 'location_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  final AuthService _authService = AuthService();
  final LocationService _locationService = LocationService();
  // 🔥 التعديل: إزالة القائمة (List) من التعريف 🔥
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  bool _isWaitingForConnection = false;
  final Color _goldColor = const Color(0xFFC5A028);

  @override
  void initState() {
    super.initState();

    // 1. إعداد الفيديو (كما هو)
    _controller = VideoPlayerController.asset('assets/videos/intro.mp4')
      ..initialize().then((_) {
        setState(() => _isInitialized = true);
        _controller.setVolume(0.0);
        _controller.play();
      });

    _controller.addListener(() {
      if (_controller.value.position >= _controller.value.duration) {
        _checkAuthAndNavigate();
      }
    });

    // 2. إعداد مراقبة الاتصال (الاشتراك الآن يرجع قيمة واحدة)
    // ⚠️ تم تغيير .onConnectivityChanged.listen() لاستقبال قيمة مفردة
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen(_updateConnectionStatus)
            as StreamSubscription<
              ConnectivityResult
            >; // يتم استخدام الكاستينغ للتوافق مع الإصدارات المختلفة

    // فحص حالة الاتصال الأولية
    _checkInitialConnection();
  }

  // فحص الاتصال الأولي (الآن checkConnectivity() ترجع قيمة واحدة)
  Future<void> _checkInitialConnection() async {
    // ⚠️ checkConnectivity() الآن ترجع قيمة مفردة
    final connectivityResult = await (Connectivity().checkConnectivity());

    // ⚠️ التحقق من القيمة المفردة
    if (connectivityResult == ConnectivityResult.none) {
      setState(() => _isWaitingForConnection = true);
    }
  }

  // 🔥🔥 التعديل: دالة التحديث تستقبل قيمة مفردة (result) 🔥🔥
  void _updateConnectionStatus(ConnectivityResult result) {
    // ⚠️ التحقق الآن يتم مباشرة على النتيجة
    final bool isConnected = result != ConnectivityResult.none;

    if (mounted) {
      if (_isWaitingForConnection && isConnected) {
        // إذا كان ينتظر الاتصال وعاد الاتصال: استأنف العملية
        setState(() => _isWaitingForConnection = false);

        if (_controller.value.duration > _controller.value.position) {
          _controller.play();
        }

        _checkAuthAndNavigate();
      } else if (!isConnected) {
        // الاتصال مفقود: توقف واعرض التنبيه
        _controller.pause();
        setState(() => _isWaitingForConnection = true);
      }
    }
  }

  // 🔥 الدالة المعدلة: تبدأ بالتحقق من الاتصال قبل التوكن 🔥
  Future<void> _checkAuthAndNavigate() async {
    _controller.pause();
    if (ModalRoute.of(context)?.isCurrent == false || _isWaitingForConnection) {
      return;
    }

    // 1. التحقق النهائي من الاتصال
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      setState(() => _isWaitingForConnection = true);
      return;
    }

    // 🔥 2. جلب الموقع الجغرافي للمستخدم 🔥
    Position? userPosition = await _locationService.getCurrentPositionSafe();

    // (ملاحظة: يمكنك هنا تخزين الـ userPosition في Provider أو State Management)
    if (userPosition == null) {
      if (kDebugMode) {
        print("Could not determine user location, proceeding...");
      }
    } else {
      if (kDebugMode) {
        print(
          "User is at: ${userPosition.latitude}, ${userPosition.longitude}",
        );
      }
    }

    // 3. فحص حالة التوكن
    bool isLoggedIn = await _authService.isLoggedIn();

    // 4. تحديد الوجهة والانتقال
    Widget nextScreen = isLoggedIn ? const MenuScreen() : const LoginScreen();

    if (mounted) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (context) => nextScreen));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ... (كود الـ build لا يتغير)
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
                : Container(),
          ),

          // 2. طبقة زر التخطي (في الأمام)
          if (_isInitialized &&
              !_isWaitingForConnection) // لا يظهر زر التخطي عند انقطاع الإنترنت
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

          // 🔥 3. طبقة تنبيه انقطاع الإنترنت (تظهر فوق كل شيء) 🔥
          if (_isWaitingForConnection)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.85),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.wifi_off, color: _goldColor, size: 60),
                      const SizedBox(height: 20),
                      const Text(
                        "No Internet Connection",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Please check your network and try again.",
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                      const SizedBox(height: 40),
                      // دائرة انتظار شفافة ترمز إلى المراقبة المستمرة
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: _goldColor,
                          strokeWidth: 2,
                        ),
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
