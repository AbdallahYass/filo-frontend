import 'package:flutter/material.dart';
import '../menu_screen.dart'; // للانتقال للمنيو بعد الدخول

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // مفاتيح التحكم بالنصوص
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // حالة التحميل وإظهار كلمة السر
  bool _isLoading = false;
  bool _isObscure = true;

  // الألوان
  final Color _goldColor = const Color(0xFFC5A028);
  final Color _darkBackground = const Color(0xFF1A1A1A);
  final Color _fieldColor = const Color(0xFF2C2C2C);

  // دالة الدخول (وهمية حالياً حتى نربطها بالسيرفر)
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // محاكاة الاتصال بالسيرفر (سنتستبدلها لاحقاً بـ API حقيقي)
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isLoading = false);

    // الانتقال للشاشة الرئيسية
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MenuScreen()),
      );
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
                // 1. الشعار أو الأيقونة
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

                // 2. حقل البريد الإلكتروني
                TextFormField(
                  controller: _emailController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDecoration("Email", Icons.email_outlined),
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Please enter email';
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // 3. حقل كلمة المرور
                TextFormField(
                  controller: _passwordController,
                  obscureText: _isObscure, // إخفاء النص
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
                          onPressed: () {
                            setState(() {
                              _isObscure = !_isObscure;
                            });
                          },
                        ),
                      ),
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Please enter password';
                    return null;
                  },
                ),

                const SizedBox(height: 10),

                // زر "نسيت كلمة المرور"
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      "Forgot Password?",
                      style: TextStyle(color: _goldColor),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // 4. زر الدخول
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

                const SizedBox(height: 20),

                // رابط التسجيل
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account? ",
                      style: TextStyle(color: Colors.grey),
                    ),
                    GestureDetector(
                      onTap: () {
                        // الانتقال لصفحة التسجيل (سنبنيها لاحقاً)
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

  // دالة مساعدة لتصميم الحقول (لتجنب تكرار الكود)
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
