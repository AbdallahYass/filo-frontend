import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '/l10n/app_localizations.dart'; // 👈 استيراد اللغات
import '../../services/auth_service.dart';
import 'otp_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart' as auth;
import 'package:shared_preferences/shared_preferences.dart';
import '../main_wrapper.dart';
import 'add_phone_screen.dart';

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

  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  String _completePhoneNumber = '';

  final auth.GoogleSignIn _googleSignIn = kIsWeb
      ? auth.GoogleSignIn(
          clientId:
              "998803872990-sta5bagomnjk4h1hd4c0ra2tjldtsj5u.apps.googleusercontent.com",
        )
      : auth.GoogleSignIn();

  bool _isLoading = false;
  final Color _goldColor = const Color(0xFFC5A028);
  final Color _darkBackground = const Color(0xFF1A1A1A);
  final Color _fieldColor = const Color(0xFF2C2C2C);

  // --- دوال جوجل ---
  Future<void> _handleGoogleSignIn() async {
    final localizations = AppLocalizations.of(context)!;
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

          String? savedPhone = data['user']['phone'];

          if (mounted) {
            // 🔥 رسالة الترحيب مترجمة مع الاسم 🔥
            // [قبل] الخطأ الذي ظهر: localizations.welcomeUser.replaceAll( ... )

            // 🔥 الصيغة الصحيحة لاستخدام الدالة المولدة 🔥
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  // 1. استدعي welcomeUser كدالة
                  localizations.welcomeUser(
                    // 2. مرر الاسم المطلوب
                    googleUser.displayName ?? localizations.signUp,
                  ),
                ),
                backgroundColor: Colors.green,
              ),
            );

            if (savedPhone == null || savedPhone.isEmpty) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const AddPhoneScreen()),
              );
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MainWrapper()),
              );
            }
          }
        } else {
          if (kDebugMode) {
            print("❌ Server Error: ${response.body}");
          }
        }
      }
      setState(() => _isLoading = false);
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
      setState(() => _isLoading = false);
    }
  }

  // --- دالة التسجيل المعدلة ---
  void _register() async {
    if (!_formKey.currentState!.validate()) return;

    final localizations = AppLocalizations.of(context)!;

    // التحقق من أن الرقم تم إدخاله
    if (_completePhoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.enterValidPhone), // 👈 نص مترجم
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

  // 🔥🔥 دالة المساعدة المعدلة لاستقبال كائن الترجمة 🔥🔥
  Widget _buildTextField(
    TextEditingController controller,
    String label, // هذا سيكون النص المترجم نفسه
    IconData icon, {
    required AppLocalizations localizations, // 👈 استقبل كائن الترجمة
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
        fillColor: _fieldColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: _goldColor),
        ),
      ),
      validator: (val) {
        if (val == null || val.isEmpty) {
          return localizations.requiredField; // 👈 نص مترجم
        }
        if (isPassword && val.length < 6) {
          return localizations.tooShort; // 👈 نص مترجم
        }
        if (inputType == TextInputType.emailAddress && !val.contains('@')) {
          return localizations.invalidEmail; // 👈 نص مترجم
        }
        return null;
      },
    );
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
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Text(
                  localizations.createAccount, // 👈 نص مترجم
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),

                _buildTextField(
                  _nameController,
                  localizations.fullName, // 👈 نص مترجم
                  Icons.person,
                  localizations: localizations, // 👈 تمرير الكائن
                ),
                const SizedBox(height: 20),

                _buildTextField(
                  _emailController,
                  localizations.email, // 👈 نص مترجم
                  Icons.email,
                  inputType: TextInputType.emailAddress,
                  localizations: localizations, // 👈 تمرير الكائن
                ),
                const SizedBox(height: 20),

                // 🔥 حقل الهاتف الجديد (IntlPhoneField) 🔥
                IntlPhoneField(
                  decoration: InputDecoration(
                    labelText: localizations.phoneNumber, // 👈 نص مترجم
                    labelStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: _fieldColor,
                    prefixIcon: Icon(
                      Icons.phone,
                      color: _goldColor,
                    ), // إضافة أيقونة الهاتف
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: _goldColor),
                    ),
                    counterText: "",
                  ),
                  style: const TextStyle(color: Colors.white),
                  dropdownTextStyle: const TextStyle(color: Colors.white),
                  dropdownIcon: Icon(Icons.arrow_drop_down, color: _goldColor),
                  initialCountryCode: 'JO',
                  disableLengthCheck: false,
                  languageCode: localizations
                      .localeName, // استخدام لغة التطبيق لأسماء الدول

                  validator: (phone) {
                    if (phone == null || !phone.isValidNumber()) {
                      return localizations.enterValidPhone; // 👈 نص مترجم
                    }
                    return null;
                  },

                  onChanged: (phone) {
                    _completePhoneNumber = phone.completeNumber;
                  },
                ),

                const SizedBox(height: 20),

                _buildTextField(
                  _passwordController,
                  localizations.password, // 👈 نص مترجم
                  Icons.lock,
                  isPassword: true,
                  localizations: localizations, // 👈 تمرير الكائن
                ),
                const SizedBox(height: 30),

                // زر التسجيل
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
                        : Text(
                            localizations.signUp, // 👈 نص مترجم
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 20),

                // فاصل
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey[700])),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        localizations.or,
                        style: TextStyle(color: Colors.grey),
                      ), // 👈 نص مترجم
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
                      _isLoading
                          ? localizations.processing
                          : localizations.continueWithGoogle, // 👈 نص مترجم
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
}
