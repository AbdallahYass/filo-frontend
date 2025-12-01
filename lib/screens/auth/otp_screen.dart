import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class OtpScreen extends StatefulWidget {
  final String email;
  const OtpScreen({super.key, required this.email});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpController = TextEditingController();
  bool _isLoading = false;
  final AuthService _authService = AuthService();
  final Color _goldColor = const Color(0xFFC5A028);

  void _verify() async {
    setState(() => _isLoading = true);
    String? error = await _authService.verifyOTP(
      widget.email,
      _otpController.text.trim(),
    );
    setState(() => _isLoading = false);

    if (error == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم التفعيل بنجاح! ✅'),
            backgroundColor: Colors.green,
          ),
        );
        // العودة لشاشة تسجيل الدخول (نحذف كل الشاشات السابقة ونرجع للأولى)
        Navigator.of(context).popUntil((route) => route.isFirst);
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
            const Icon(Icons.mark_email_read, size: 80, color: Colors.white),
            const SizedBox(height: 20),
            const Text(
              "Check your Email",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "We sent a code to ${widget.email}",
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                letterSpacing: 5,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF2C2C2C),
                hintText: "######",
                hintStyle: TextStyle(color: Colors.grey[600]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: _goldColor),
                ),
              ),
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
                    : const Text(
                        "VERIFY",
                        style: TextStyle(
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
