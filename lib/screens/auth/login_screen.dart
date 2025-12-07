import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // للويب
import '../../services/auth_service.dart';
import '../menu_screen.dart';
import 'signup_screen.dart';
import 'otp_screen.dart';
import 'phone_verification_screen.dart';
import 'forgot_password_screen.dart';
// 1. استيراد المكتبات اللازمة
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart' as auth;
import 'package:shared_preferences/shared_preferences.dart'; // لتخزين التوكن

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _isObscure = true;

  final Color _goldColor = const Color(0xFFC5A028);
  final Color _darkBackground = const Color(0xFF1A1A1A);
  final Color _fieldColor = const Color(0xFF2C2C2C);

  // 2. إعداد Google Sign In
  final auth.GoogleSignIn _googleSignIn = kIsWeb
      ? auth.GoogleSignIn(
          clientId:
              "998803872990-sta5bagomnjk4h1hd4c0ra2tjldtsj5u.apps.googleusercontent.com",
        )
      : auth.GoogleSignIn();

  // 3. دالة الدخول بجوجل
  Future<void> _handleGoogleSignIn() async {
    try {
      setState(() => _isLoading = true);

      // تنظيف الجلسة لضمان اختيار الحساب
      await _googleSignIn.signOut();

      // بدء عملية الدخول
      final auth.GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        setState(() => _isLoading = false);
        return; // المستخدم ألغى العملية
      }

      // الحصول على التوكن
      final auth.GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      String? tokenToSend = googleAuth.accessToken;

      if (tokenToSend != null) {
        // إرسال التوكن للسيرفر
        final response = await http.post(
          Uri.parse('https://filo-menu.onrender.com/api/auth/google'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'accessToken': tokenToSend}),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          // 🔥 حفظ التوكن في الجهاز
          // مهم جداً: عشان التطبيق يعرف إنك مسجل دخول المرة الجاية
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', data['token']);
          if (data['user'] != null) {
            await prefs.setString('user', jsonEncode(data['user']));
          }

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Welcome ${googleUser.displayName}! 🚀"),
                backgroundColor: Colors.green,
              ),
            );

            // الانتقال للمنيو مباشرة
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MenuScreen()),
            );
          }
        } else {
          print("Server Error: ${response.body}");
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Google Login Failed: ${response.statusCode}"),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
      setState(() => _isLoading = false);
    } catch (error) {
      print("Google Error: $error");
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $error"), backgroundColor: Colors.red),
        );
      }
    }
  }

  // دالة الدخول العادي (الإيميل والباسوورد)
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    String? result = await _authService.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (result == null) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MenuScreen()),
        );
      }
    } else if (result == 'NOT_VERIFIED') {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('الإيميل غير مفعل! تم إرسال رمز جديد 📧'),
            backgroundColor: Colors.orange,
          ),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                OtpScreen(email: _emailController.text.trim()),
          ),
        );
      }
    } else if (result == 'PHONE_NOT_VERIFIED') {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('رقم الهاتف غير مفعل! يرجى استكماله 📱'),
            backgroundColor: Colors.orange,
          ),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                PhoneVerificationScreen(email: _emailController.text.trim()),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkBackground,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: _goldColor, width: 2),
                  ),
                  child: Icon(
                    Icons.restaurant_menu,
                    size: 60,
                    color: _goldColor,
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  "Welcome Back!",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  "Sign in to continue",
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                const SizedBox(height: 40),

                // حقل الإيميل
                TextFormField(
                  controller: _emailController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDecoration("Email", Icons.email_outlined),
                  validator: (val) => val!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 20),

                // حقل كلمة المرور
                TextFormField(
                  controller: _passwordController,
                  obscureText: _isObscure,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration("Password", Icons.lock_outline)
                      .copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isObscure
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () =>
                              setState(() => _isObscure = !_isObscure),
                        ),
                      ),
                  validator: (val) => val!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 10),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ForgotPasswordScreen(),
                        ),
                      );
                    },
                    child: Text(
                      "Forgot Password?",
                      style: TextStyle(color: _goldColor),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // زر الدخول العادي
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _goldColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.black)
                        : const Text(
                            "LOGIN",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 30),

                // --- 4. فاصل وزر جوجل ---
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey[700])),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text("OR", style: TextStyle(color: Colors.grey)),
                    ),
                    Expanded(child: Divider(color: Colors.grey[700])),
                  ],
                ),
                const SizedBox(height: 20),

                // زر قوقل
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _handleGoogleSignIn,
                    icon: _isLoading
                        ? const SizedBox()
                        : const Icon(Icons.login, color: Colors.black),
                    label: Text(
                      _isLoading ? "Processing..." : "Continue with Google",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),

                // -----------------------
                const SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account? ",
                      style: TextStyle(color: Colors.grey),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignupScreen(),
                          ),
                        );
                      },
                      child: Text(
                        "Sign Up",
                        style: TextStyle(
                          color: _goldColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
      fillColor: _fieldColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: _goldColor),
      ),
      errorStyle: const TextStyle(color: Colors.redAccent),
    );
  }
}
