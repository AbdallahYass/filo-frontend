// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '/l10n/app_localizations.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  // ملاحظة: يتم تحديث _phone فقط إذا قام المستخدم بتعديله
  String _phone = "";
  bool _isLoading = false;
  final _goldColor = const Color(0xFFC5A028);
  final Color _fieldColor = const Color(0xFF2C2C2C);
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

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
          // لا يمكننا إظهار الهاتف داخل IntlPhoneField بسهولة بدون فصل الكود/الرقم
          // لذا سنعتمد على أن يرى المستخدم الحقل فارغاً ويُدخل رقماً جديداً إذا أراد التغيير
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  // ----------------------------------------------------------------------
  // 🔥🔥 دالة تنفيذ تحديث البروفايل (بعد التأكيد) 🔥🔥
  // ----------------------------------------------------------------------
  Future<void> _executeProfileUpdate() async {
    setState(() => _isLoading = true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final localizations = AppLocalizations.of(context)!;

    final url = Uri.parse(
      'https://filo-menu.onrender.com/api/user/update-profile',
    );

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': _nameController.text,
          'phone': _phone.isNotEmpty
              ? _phone
              : null, // نرسل القيمة فقط إذا تم تغييرها
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await prefs.setString('user', jsonEncode(data['user']));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(localizations.profileUpdatedSuccess),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context); // الرجوع للخلف
        }
      } else {
        if (mounted) {
          final errorMsg =
              jsonDecode(response.body)['error'] ?? localizations.error;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${localizations.error}: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
      if (kDebugMode) {
        print(e);
      }
    }
    setState(() => _isLoading = false);
  }

  // ----------------------------------------------------------------------
  // 🔥🔥 دالة رسالة التأكيد (Dialog) 🔥🔥
  // ----------------------------------------------------------------------
  void _updateProfile() {
    if (!_formKey.currentState!.validate()) return;

    // 🔥 عرض مربع الحوار قبل التنفيذ
    _showConfirmationDialog();
  }

  void _showConfirmationDialog() {
    final localizations = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2C2C2C), // خلفية داكنة
          title: Text(
            localizations.confirmUpdate,
            style: TextStyle(color: _goldColor),
          ), // نص مترجم
          content: Text(
            localizations.confirmUpdateMessage,
            style: const TextStyle(color: Colors.white70),
          ), // نص مترجم
          actions: <Widget>[
            TextButton(
              child: Text(
                localizations.cancel,
                style: const TextStyle(color: Colors.grey),
              ), // إلغاء
              onPressed: () {
                Navigator.of(context).pop(); // إغلاق مربع الحوار
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: _goldColor),
              child: Text(
                localizations.confirm,
                style: const TextStyle(color: Colors.black),
              ), // تأكيد
              onPressed: () {
                Navigator.of(context).pop(); // إغلاق مربع الحوار
                _executeProfileUpdate(); // 🔥 تنفيذ التحديث الفعلي
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 🔥 الوصول لكائن الترجمة 🔥
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        title: Text(localizations.editProfile),
        backgroundColor: Colors.transparent,
        foregroundColor: _goldColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: localizations.fullName,
                  labelStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: Icon(Icons.person, color: _goldColor),
                  filled: true,
                  fillColor: _fieldColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: _goldColor),
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                validator: (val) =>
                    val!.isEmpty ? localizations.requiredField : null,
              ),
              const SizedBox(height: 20),

              // حقل الهاتف (اختياري للتحديث)
              IntlPhoneField(
                decoration: InputDecoration(
                  labelText: localizations.newPhoneNumber,
                  labelStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: Icon(Icons.phone, color: _goldColor),
                  filled: true,
                  fillColor: _fieldColor,
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
                languageCode: localizations.localeName,

                onChanged: (phone) {
                  _phone = phone.completeNumber;
                },
                // validator: (phone) { ... }
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : _updateProfile, // 🔥 استدعاء دالة التأكيد
                  style: ElevatedButton.styleFrom(backgroundColor: _goldColor),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.black)
                      : Text(
                          localizations.saveChanges,
                          style: const TextStyle(
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
      ),
    );
  }
}
