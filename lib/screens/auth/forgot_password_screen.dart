import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '/l10n/app_localizations.dart'; // 👈 استيراد اللغات
import 'reset_password_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final Color _goldColor = const Color(0xFFC5A028);
  final Color _darkBackground = const Color(0xFF1A1A1A);

  Future<void> _sendCode() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final localizations = AppLocalizations.of(context)!;

    try {
      // 🔴 استخدم الرابط المناسب (localhost أو السيرفر)
      final url = Uri.parse(
        'https://filo-menu.onrender.com/api/auth/forgot-password',
      );

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': _emailController.text.trim()}),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                localizations.codeSentSuccess,
              ), // 👈 نص مترجم (نجاح)
              backgroundColor: Colors.green,
            ),
          );
          // الانتقال لشاشة تغيير الباسورد
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ResetPasswordScreen(email: _emailController.text.trim()),
            ),
          );
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
        elevation: 0,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localizations.forgotPassword, // 👈 نص مترجم
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                localizations.forgotPasswordInstructions, // 👈 نص مترجم
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 30),

              // حقل الإيميل
              TextFormField(
                controller: _emailController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: localizations.email, // 👈 نص مترجم
                  labelStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: Icon(Icons.email, color: _goldColor),
                  filled: true,
                  fillColor: const Color(0xFF2C2C2C),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: _goldColor),
                  ),
                ),
                validator: (val) => val!.isEmpty
                    ? localizations.requiredField
                    : null, // 👈 نص مترجم
              ),
              const SizedBox(height: 30),

              // زر إرسال الكود
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _sendCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _goldColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.black)
                      : Text(
                          localizations.sendCode, // 👈 نص مترجم
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
}
