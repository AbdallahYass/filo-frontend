import 'package:flutter/material.dart';
import '/l10n/app_localizations.dart'; // 👈 استيراد اللغات
import 'package:pinput/pinput.dart'; // مكتبة احترافية لإدخال الكود
import '../../services/auth_service.dart';
import 'login_screen.dart';

class OtpScreen extends StatefulWidget {
  final String email;
  const OtpScreen({super.key, required this.email});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpController =
      TextEditingController(); // استخدام هذا المتحكم لـ Pinput
  bool _isLoading = false;
  final AuthService _authService = AuthService();
  final Color _goldColor = const Color(0xFFC5A028);

  void _verify() async {
    final localizations = AppLocalizations.of(context)!;

    // التحقق من أن الكود مكون من 6 خانات (عادة)
    if (_otpController.text.trim().length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.requiredField),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    String? error = await _authService.verifyOTP(
      widget.email,
      _otpController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (error == null) {
      // ✅ نجاح التفعيل
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.verificationSuccess), // 👈 نص مترجم
            backgroundColor: Colors.green,
          ),
        );

        // 🚀 الانتقال لصفحة تسجيل الدخول وحذف الصفحات السابقة من الذاكرة
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🔥 الوصول لكائن الترجمة 🔥
    final localizations = AppLocalizations.of(context)!;

    // إعدادات تصميم خانات الـ PIN
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(
        fontSize: 20,
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(15),
        color: const Color(0xFF2C2C2C),
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: _goldColor),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.mark_email_read,
              size: 80,
              color: _goldColor,
            ), // تم تحديث لون الأيقونة
            const SizedBox(height: 20),
            Text(
              localizations.checkEmailTitle, // 👈 نص مترجم
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "${localizations.otpInstruction} ${widget.email}", // 👈 نص مترجم + الإيميل
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // 🔥 استخدام Pinput بدلاً من TextField العادي 🔥
            Pinput(
              controller: _otpController,
              length: 6,
              defaultPinTheme: defaultPinTheme,
              focusedPinTheme: defaultPinTheme.copyDecorationWith(
                border: Border.all(color: _goldColor),
              ),
              onCompleted: (pin) => _verify(), // تفعيل تلقائي عند اكتمال الرقم
            ),

            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _verify,
                style: ElevatedButton.styleFrom(backgroundColor: _goldColor),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : Text(
                        localizations.verify, // 👈 نص مترجم
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
