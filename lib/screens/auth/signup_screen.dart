import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'otp_screen.dart'; // استيراد شاشة الكود

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController(); // 📱 1. كنترولر الهاتف
  final _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  final Color _goldColor = const Color(0xFFC5A028);
  final Color _darkBackground = const Color(0xFF1A1A1A);

  void _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // 🚀 2. إرسال الهاتف مع البيانات
    String? error = await _authService.register(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text,
      _phoneController.text.trim(), // إرسال الهاتف
    );

    setState(() => _isLoading = false);

    if (error == null) {
      if (mounted) {
        // نجاح! انتقل لشاشة تفعيل الإيميل
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

                // 📱 3. حقل الهاتف الجديد
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  // دالة بناء الحقول المحسنة
  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isPassword = false,
    TextInputType inputType = TextInputType.text, // إضافة نوع الإدخال
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: inputType, // تحديد نوع الكيبورد (أرقام، إيميل، نص)
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
