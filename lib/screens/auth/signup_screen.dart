import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // للويب
import '../../services/auth_service.dart';
import 'otp_screen.dart';
// 1. مكتبات الاتصال الجديدة (مهمة جداً)
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart' as auth;

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  // تعريف كائن جوجل (حسب كودك الصحيح)
  final auth.GoogleSignIn _googleSignIn = kIsWeb
      ? auth.GoogleSignIn(
          clientId:
              "998803872990-sta5bagomnjk4h1hd4c0ra2tjldtsj5u.apps.googleusercontent.com",
        )
      : auth.GoogleSignIn();

  bool _isLoading = false;
  final Color _goldColor = const Color(0xFFC5A028);
  final Color _darkBackground = const Color(0xFF1A1A1A);

  // 🔥 الدالة المعدلة بالكامل لربط السيرفر
  Future<void> _handleGoogleSignIn() async {
    try {
      setState(() => _isLoading = true);

      // 1. تنظيف الجلسة القديمة
      await _googleSignIn.signOut();

      // 2. طلب الدخول
      final auth.GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      // 3. استخراج التوكن
      final auth.GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // ✅ هنا نستخدم الـ Access Token لأنه هو اللي اشتغل معك
      String? tokenToSend = googleAuth.accessToken;

      print("🚀 Token ready to send: $tokenToSend");

      if (tokenToSend != null) {
        // 4. إرسال التوكن إلى سيرفرك (Node.js)
        final response = await http.post(
          Uri.parse('https://www.filomenu.com/api/auth/google'), // رابط السيرفر
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'accessToken': tokenToSend, // نرسل الـ Access Token
          }),
        );

        if (response.statusCode == 200) {
          // 🎉 نجاح! السيرفر رد علينا
          final data = jsonDecode(response.body);
          print("✅ Server Response: $data");

          // هنا المفروض تخزن التوكن القادم من السيرفر (data['token'])
          // وتنتقل للصفحة الرئيسية

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Login Success! Welcome ${googleUser.displayName}",
                ),
                backgroundColor: Colors.green,
              ),
            );
            // Navigator.pushReplacementNamed(context, '/home'); // مثال للانتقال
          }
        } else {
          // خطأ من السيرفر
          print("❌ Server Error: ${response.body}");
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Server Error: ${response.statusCode}"),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }

      setState(() => _isLoading = false);
    } catch (error) {
      print(error);
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Google Sign In Failed: $error"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    String? error = await _authService.register(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text,
      _phoneController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (error == null) {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                OtpScreen(email: _emailController.text.trim()),
          ),
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
    return Scaffold(
      backgroundColor: _darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: _goldColor),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Text(
                  "Create Account",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),

                _buildTextField(_nameController, "Full Name", Icons.person),
                const SizedBox(height: 20),

                _buildTextField(
                  _emailController,
                  "Email",
                  Icons.email,
                  inputType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),

                _buildTextField(
                  _phoneController,
                  "Phone Number",
                  Icons.phone,
                  inputType: TextInputType.phone,
                ),
                const SizedBox(height: 20),

                _buildTextField(
                  _passwordController,
                  "Password",
                  Icons.lock,
                  isPassword: true,
                ),
                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _goldColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.black)
                        : const Text(
                            "SIGN UP",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 20),

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
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isPassword = false,
    TextInputType inputType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: inputType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
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
      ),
      validator: (val) {
        if (val == null || val.isEmpty) return "Required";
        if (inputType == TextInputType.emailAddress && !val.contains('@')) {
          return "Invalid Email";
        }
        if (inputType == TextInputType.phone && val.length < 9) {
          return "Invalid Phone";
        }
        return null;
      },
    );
  }
}
