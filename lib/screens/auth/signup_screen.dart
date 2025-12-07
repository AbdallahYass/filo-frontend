import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // للويب
import 'package:intl_phone_field/intl_phone_field.dart'; // 👈 استيراد المكتبة
import '../../services/auth_service.dart';
import 'otp_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart' as auth;
import 'package:shared_preferences/shared_preferences.dart';
import '../menu_screen.dart';
import 'add_phone_screen.dart'; // تأكد من استيراد الشاشات اللازمة

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  // حذفنا _phoneController لأن المكتبة تدير النص بنفسها

  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  // 🔥 متغير لحفظ الرقم الكامل (مع الكود الدولي)
  String _completePhoneNumber = '';

  // تعريف كائن جوجل
  final auth.GoogleSignIn _googleSignIn = kIsWeb
      ? auth.GoogleSignIn(
          clientId:
              "998803872990-sta5bagomnjk4h1hd4c0ra2tjldtsj5u.apps.googleusercontent.com",
        )
      : auth.GoogleSignIn();

  bool _isLoading = false;
  final Color _goldColor = const Color(0xFFC5A028);
  final Color _darkBackground = const Color(0xFF1A1A1A);

  // --- دوال جوجل (كما هي) ---
  Future<void> _handleGoogleSignIn() async {
    try {
      setState(() => _isLoading = true);
      await _googleSignIn.signOut();
      final auth.GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      final auth.GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      String? tokenToSend = googleAuth.accessToken;

      if (tokenToSend != null) {
        final response = await http.post(
          Uri.parse('https://filo-menu.onrender.com/api/auth/google'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'accessToken': tokenToSend}),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', data['token']);
          if (data['user'] != null) {
            await prefs.setString('user', jsonEncode(data['user']));
          }

          // فحص هل الرقم موجود
          String? savedPhone = data['user']['phone'];

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Welcome ${googleUser.displayName}"),
                backgroundColor: Colors.green,
              ),
            );

            // التوجيه الذكي
            if (savedPhone == null || savedPhone.isEmpty) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const AddPhoneScreen()),
              );
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MenuScreen()),
              );
            }
          }
        } else {
          print("❌ Server Error: ${response.body}");
        }
      }
      setState(() => _isLoading = false);
    } catch (error) {
      print(error);
      setState(() => _isLoading = false);
    }
  }

  // --- دالة التسجيل المعدلة ---
  void _register() async {
    if (!_formKey.currentState!.validate()) return;

    // التحقق من أن الرقم تم إدخاله
    if (_completePhoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a valid phone number"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // إرسال البيانات (نرسل الرقم الكامل _completePhoneNumber)
    String? error = await _authService.register(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text,
      _completePhoneNumber, // ✅ الرقم الكامل هنا
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

                // 🔥🔥 حقل الهاتف الجديد (IntlPhoneField) 🔥🔥
                IntlPhoneField(
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    labelStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: const Color(0xFF2C2C2C),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: _goldColor),
                    ),
                    counterText: "", // إخفاء العداد
                  ),
                  style: const TextStyle(color: Colors.white),
                  dropdownTextStyle: const TextStyle(color: Colors.white),
                  dropdownIcon: Icon(Icons.arrow_drop_down, color: _goldColor),
                  initialCountryCode: 'JO', // الدولة الافتراضية
                  disableLengthCheck: false, // تفعيل التحقق من الطول
                  onChanged: (phone) {
                    // حفظ الرقم الكامل عند التغيير
                    _completePhoneNumber = phone.completeNumber;
                  },
                  languageCode: "en",
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
        return null;
      },
    );
  }
}
