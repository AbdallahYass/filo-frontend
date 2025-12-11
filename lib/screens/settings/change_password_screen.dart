// lib/screens/change_password_screen.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '/l10n/app_localizations.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final Color _goldColor = const Color(0xFFC5A028);
  final Color _darkBackground = const Color(0xFF1A1A1A);
  final Color _fieldColor = const Color(0xFF2C2C2C);

  Future<void> _changePassword() async {
    final localizations = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;

    // 1. التحقق الإضافي لتطابق كلمة المرور الجديدة والتأكيد
    if (_newPasswordController.text != _confirmPasswordController.text) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.passwordsDoNotMatch),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() => _isLoading = true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    // 🔴 هام: تأكد من استخدام الرابط الصحيح (Live/Localhost)
    final url = Uri.parse(
      'https://filo-menu.onrender.com/api/user/change-password',
    );

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'oldPassword': _oldPasswordController.text,
          'newPassword': _newPasswordController.text,
        }),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(localizations.passwordChangedSuccess),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context); // العودة لشاشة الإعدادات
        }
      } else {
        if (mounted) {
          // عرض رسالة الخطأ من السيرفر
          final errorMsg =
              jsonDecode(response.body)['error'] ?? localizations.error;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
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
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: _darkBackground,
      appBar: AppBar(
        title: Text(localizations.changePassword), // عنوان مترجم
        backgroundColor: Colors.transparent,
        foregroundColor: _goldColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text(
                localizations.updateYourPassword, // نص مترجم
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),

              // 1. كلمة المرور القديمة
              _buildPasswordField(
                _oldPasswordController,
                localizations.oldPassword,
              ),
              const SizedBox(height: 20),

              // 2. كلمة المرور الجديدة
              _buildPasswordField(
                _newPasswordController,
                localizations.newPasswordTitle,
              ),
              const SizedBox(height: 20),

              // 3. تأكيد كلمة المرور الجديدة
              _buildPasswordField(
                _confirmPasswordController,
                localizations.confirmNewPassword,
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _changePassword,
                  style: ElevatedButton.styleFrom(backgroundColor: _goldColor),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.black)
                      : Text(
                          localizations.changePasswordButton, // زر مترجم
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

  // 🔥 دالة مساعدة لحقول كلمة المرور (للتكرار)
  Widget _buildPasswordField(TextEditingController controller, String label) {
    final localizations = AppLocalizations.of(context)!;
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      obscureText: true,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(Icons.lock, color: _goldColor),
        filled: true,
        fillColor: _fieldColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: _goldColor),
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      validator: (val) {
        if (val == null || val.isEmpty) return localizations.requiredField;
        if (val.length < 6) return localizations.tooShort;
        // هنا لا نحتاج للتحقق من تطابق الباسوورد، لأنه يتم في دالة _changePassword()
        return null;
      },
    );
  }
}
