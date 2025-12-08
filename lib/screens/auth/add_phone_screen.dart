import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:filo_menu/l10n/app_localizations.dart'; // 👈 استيراد ملف اللغات
import '../menu_screen.dart';

class AddPhoneScreen extends StatefulWidget {
  const AddPhoneScreen({super.key});

  @override
  State<AddPhoneScreen> createState() => _AddPhoneScreenState();
}

class _AddPhoneScreenState extends State<AddPhoneScreen> {
  String fullPhoneNumber = '';
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  Future<void> _savePhone() async {
    // يجب أن تكون دالة التحقق من المكتبة قد تم تشغيلها عبر زر الـ ElevatedButton
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final url = Uri.parse(
      'https://filo-menu.onrender.com/api/user/update-phone',
    );

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'phone': fullPhoneNumber}),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const MenuScreen()),
            (route) => false,
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Error: ${response.statusCode}",
              ), // يمكن ترجمة هذا الخطأ لاحقاً
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    // 🔥 الوصول لكائن الترجمة 🔥
    final localizations = AppLocalizations.of(context)!;

    // تعريف الألوان
    final Color goldColor = const Color(0xFFC5A028);
    final Color darkFieldColor = const Color(0xFF2C2C2C);

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        title: Text(localizations.completeProfile), // 👈 نص مترجم
        backgroundColor: Colors.transparent,
        foregroundColor: goldColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                localizations.addPhoneNumberTitle, // 👈 نص مترجم
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                localizations.addPhoneNumberHint, // 👈 نص مترجم
                style: const TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              // 🔥🔥 حقل الهاتف الذكي الجديد 🔥🔥
              IntlPhoneField(
                decoration: InputDecoration(
                  labelText: localizations.phoneNumber, // 👈 نص مترجم
                  labelStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: darkFieldColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: goldColor),
                  ),
                  counterText: "",
                ),
                style: const TextStyle(color: Colors.white),
                dropdownTextStyle: const TextStyle(color: Colors.white),
                dropdownIcon: Icon(Icons.arrow_drop_down, color: goldColor),

                initialCountryCode: 'JO',

                // استخدام دالة التحقق الافتراضية للمكتبة
                validator: (phone) {
                  if (phone == null || !phone.isValidNumber()) {
                    return localizations.invalidPhone; // 👈 نص مترجم
                  }
                  return null;
                },

                onChanged: (phone) {
                  fullPhoneNumber = phone.completeNumber;
                },
                disableLengthCheck: false,
                showCountryFlag: true,
                languageCode: localizations
                    .localeName, // لغة أسماء الدول تتطابق مع لغة التطبيق
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _savePhone,
                  style: ElevatedButton.styleFrom(backgroundColor: goldColor),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.black)
                      : Text(
                          localizations.saveAndContinue, // 👈 نص مترجم
                          style: const TextStyle(
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
    );
  }
}
