// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../menu_screen.dart';

class PhoneVerificationScreen extends StatefulWidget {
  final String email;
  const PhoneVerificationScreen({super.key, required this.email});

  @override
  State<PhoneVerificationScreen> createState() =>
      _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState extends State<PhoneVerificationScreen> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isCodeSent = false;
  bool _isLoading = false;

  final Color _goldColor = const Color(0xFFC5A028);

  void _sendCode() async {
    setState(() => _isLoading = true);
    bool success = await _authService.sendPhoneOtp(
      widget.email,
      _phoneController.text,
    );
    setState(() => _isLoading = false);

    if (success) {
      setState(() => _isCodeSent = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("تم إرسال الرمز (راجع الكونسول للتجربة)"),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _verifyCode() async {
    setState(() => _isLoading = true);
    bool success = await _authService.verifyPhoneOtp(
      widget.email,
      _codeController.text,
    );
    setState(() => _isLoading = false);

    if (success) {
      // 🚀 النجاح النهائي: الذهاب للمنيو
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MenuScreen()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("الرمز خطأ"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        title: const Text(
          "تأكيد الهاتف",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: _goldColor),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            if (!_isCodeSent) ...[
              const Text(
                "أدخل رقم هاتفك",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "+962 79...",
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xFF2C2C2C),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _sendCode,
                style: ElevatedButton.styleFrom(backgroundColor: _goldColor),
                child: const Text(
                  "إرسال الرمز",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ] else ...[
              const Text(
                "أدخل الرمز الذي وصلك",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "####",
                  filled: true,
                  fillColor: const Color(0xFF2C2C2C),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _verifyCode,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text(
                  "تأكيد ودخول",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
