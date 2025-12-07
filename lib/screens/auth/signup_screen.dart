import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'otp_screen.dart';
// 1. استيراد مكتبة جوجل باسم مستعار لتجنب المشاكل
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

  // 2. تعريف كائن جوجل هنا
  final auth.GoogleSignIn _googleSignIn = auth.GoogleSignIn();

  bool _isLoading = false;
  final Color _goldColor = const Color(0xFFC5A028);
  final Color _darkBackground = const Color(0xFF1A1A1A);

  // 3. دالة التعامل مع جوجل (تفتح النافذة)
  Future<void> _handleGoogleSignIn() async {
    try {
      setState(() => _isLoading = true);

      // فتح نافذة جوجل
      final auth.GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // المستخدم ألغى العملية
        setState(() => _isLoading = false);
        return;
      }

      // استخراج التوكن
      final auth.GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      print("Google Token: ${googleAuth.idToken}");

      // ملاحظة: هنا لاحقاً سنرسل التوكن للسيرفر (Node.js)
      // حالياً سنظهر رسالة نجاح فقط
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Welcome ${googleUser.displayName}!"),
            backgroundColor: Colors.green,
          ),
        );
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

                // الاسم
                _buildTextField(_nameController, "Full Name", Icons.person),
                const SizedBox(height: 20),

                // الإيميل
                _buildTextField(
                  _emailController,
                  "Email",
                  Icons.email,
                  inputType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),

                // الهاتف
                _buildTextField(
                  _phoneController,
                  "Phone Number",
                  Icons.phone,
                  inputType: TextInputType.phone,
                ),
                const SizedBox(height: 20),

                // كلمة المرور
                _buildTextField(
                  _passwordController,
                  "Password",
                  Icons.lock,
                  isPassword: true,
                ),
                const SizedBox(height: 30),

                // زر التسجيل العادي
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

                // ------------ فاصل (OR) ------------
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

                // ------------ زر جوجل الجديد ------------
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _handleGoogleSignIn,
                    icon: _isLoading
                        ? const SizedBox() // إخفاء الأيقونة عند التحميل
                        : const Icon(
                            Icons.login,
                            color: Colors.black,
                          ), // أيقونة مؤقتة
                    label: Text(
                      _isLoading ? "Processing..." : "Continue with Google",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.white, // خلفية بيضاء كلاسيكية لجوجل
                      foregroundColor: Colors.black,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                // ----------------------------------------
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
        if (inputType == TextInputType.emailAddress && !val.contains('@'))
          return "Invalid Email";
        if (inputType == TextInputType.phone && val.length < 9)
          return "Invalid Phone";
        return null;
      },
    );
  }
}
