import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '/l10n/app_localizations.dart'; // 👈 استيراد اللغات

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  const ResetPasswordScreen({super.key, required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final Color _goldColor = const Color(0xFFC5A028);
  final Color _darkBackground = const Color(0xFF1A1A1A);

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final localizations = AppLocalizations.of(context)!;

    try {
      final url = Uri.parse(
        'https://filo-menu.onrender.com/api/auth/reset-password',
      );

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': widget.email,
          'otp': _otpController.text.trim(),
          'newPassword': _newPasswordController.text,
        }),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                localizations.passwordChangedSuccess,
              ), // 👈 نص مترجم (نجاح)
              backgroundColor: Colors.green,
            ),
          );
          // العودة لشاشة تسجيل الدخول (نحذف كل الصفحات السابقة)
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      } else {
        if (mounted) {
          final errorMsg =
              jsonDecode(response.body)['error'] ?? localizations.error;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        final localizations = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${localizations.error}: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    // 🔥 الوصول لكائن الترجمة 🔥
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: _darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: _goldColor),
        title: Text(
          localizations.resetPassword,
          style: TextStyle(color: _goldColor),
        ), // 👈 نص مترجم
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text(
                localizations.newPasswordTitle, // 👈 نص مترجم
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),

              // OTP Field
              TextFormField(
                controller: _otpController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                decoration: _inputDecoration(
                  localizations.enterOtpCode, // 👈 نص مترجم
                  Icons.lock_clock,
                ),
                validator: (val) => val!.length < 6
                    ? localizations.invalidCode
                    : null, // 👈 نص مترجم
              ),
              const SizedBox(height: 20),

              // New Password Field
              TextFormField(
                controller: _newPasswordController,
                style: const TextStyle(color: Colors.white),
                obscureText: true,
                decoration: _inputDecoration(
                  localizations.password,
                  Icons.lock,
                ), // 👈 نص مترجم
                validator: (val) => val!.length < 6
                    ? localizations.tooShort
                    : null, // 👈 نص مترجم
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _resetPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _goldColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.black)
                      : Text(
                          localizations.changePasswordButton, // 👈 نص مترجم
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey),
      prefixIcon: Icon(icon, color: _goldColor),
      filled: true,
      fillColor: const Color(0xFF2C2C2C),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: _goldColor),
      ),
    );
  }
}
