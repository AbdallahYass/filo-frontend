import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl_phone_field/intl_phone_field.dart'; // 👈 استيراد المكتبة
import '../menu_screen.dart';

class AddPhoneScreen extends StatefulWidget {
  const AddPhoneScreen({super.key});

  @override
  State<AddPhoneScreen> createState() => _AddPhoneScreenState();
}

class _AddPhoneScreenState extends State<AddPhoneScreen> {
  // متغير لحفظ الرقم الكامل مع الكود الدولي
  String fullPhoneNumber = '';
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  Future<void> _savePhone() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    // 🔴 عدل الرابط حسب سيرفرك (localhost أو Live)
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
        body: jsonEncode({'phone': fullPhoneNumber}), // نرسل الرقم الكامل
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
              content: Text("Error: ${response.statusCode}"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print(e);
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    // تعريف الألوان
    final Color goldColor = const Color(0xFFC5A028);
    final Color darkFieldColor = const Color(0xFF2C2C2C);

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        title: const Text("Complete Profile"),
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
              const Text(
                "Add Your Phone Number 📱",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Select your country and enter phone number.",
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              // 🔥🔥 حقل الهاتف الذكي الجديد 🔥🔥
              IntlPhoneField(
                decoration: InputDecoration(
                  labelText: 'Phone Number',
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
                  counterText: "", // لإخفاء عداد الأحرف أسفل الحقل
                ),
                style: const TextStyle(color: Colors.white), // لون الرقم
                dropdownTextStyle: const TextStyle(
                  color: Colors.white,
                ), // لون القائمة
                dropdownIcon: Icon(Icons.arrow_drop_down, color: goldColor),

                initialCountryCode: 'JO', // الدولة الافتراضية (الأردن مثلاً)

                onChanged: (phone) {
                  // هنا يتم حفظ الرقم كاملاً (مثال: +962791234567)
                  fullPhoneNumber = phone.completeNumber;
                },

                // هذه الخاصية تمنع الإدخال إذا كان الرقم غير صالح للدولة المختارة
                disableLengthCheck: false,
                showCountryFlag: true,
                languageCode: "en", // لغة أسماء الدول
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
                      : const Text(
                          "SAVE & CONTINUE",
                          style: TextStyle(
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
