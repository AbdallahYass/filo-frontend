import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  String _phone = "";
  bool _isLoading = false;
  final _goldColor = const Color(0xFFC5A028);

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    // 🔴 عدل الرابط
    final url = Uri.parse('https://www.filomenu.com/api/user/profile');

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _nameController.text = data['name'] ?? "";
          // الهاتف يحتاج معالجة خاصة إذا أردت عرضه داخل IntlPhoneField
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    // 🔴 عدل الرابط
    final url = Uri.parse('https://www.filomenu.com/api/user/update-profile');

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': _nameController.text,
          'phone': _phone.isNotEmpty ? _phone : null,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // تحديث البيانات في الذاكرة المحلية
        await prefs.setString('user', jsonEncode(data['user']));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Profile Updated!"),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context); // الرجوع للخلف
        }
      }
    } catch (e) {
      print(e);
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: Colors.transparent,
        foregroundColor: _goldColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextFormField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Full Name",
                labelStyle: const TextStyle(color: Colors.grey),
                prefixIcon: Icon(Icons.person, color: _goldColor),
                filled: true,
                fillColor: const Color(0xFF2C2C2C),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: _goldColor),
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // حقل الهاتف (اختياري للتحديث)
            IntlPhoneField(
              decoration: InputDecoration(
                labelText: 'New Phone Number',
                labelStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFF2C2C2C),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: _goldColor),
                  borderRadius: BorderRadius.circular(15),
                ),
                counterText: "",
              ),
              style: const TextStyle(color: Colors.white),
              dropdownTextStyle: const TextStyle(color: Colors.white),
              dropdownIcon: Icon(Icons.arrow_drop_down, color: _goldColor),
              initialCountryCode: 'JO',
              onChanged: (phone) {
                _phone = phone.completeNumber;
              },
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updateProfile,
                style: ElevatedButton.styleFrom(backgroundColor: _goldColor),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text(
                        "SAVE CHANGES",
                        style: TextStyle(
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
    );
  }
}
