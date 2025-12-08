// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import '/l10n/app_localizations.dart';
import '../l10n/locale_provider.dart';
import 'auth/login_screen.dart';
import 'edit_profile_screen.dart';
import 'change_password_screen.dart'; // 👈 تأكد من استيراد هذه الشاشة

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String userName = "Loading...";
  String userEmail = "Loading...";
  final Color _goldColor = const Color(0xFFC5A028);
  final Color _darkBackground = const Color(0xFF1A1A1A);

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userData = prefs.getString('user');

    if (userData != null) {
      var userMap = jsonDecode(userData);
      setState(() {
        userName = userMap['name'] ?? "User";
        userEmail = userMap['email'] ?? "No Email";
      });
    }
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  // 🔥🔥🔥 الدالة الجديدة لتغيير اللغة 🔥🔥🔥
  void _showLanguageDialog(BuildContext context) {
    final provider = Provider.of<LocaleProvider>(context, listen: false);
    final currentLang = provider.locale.languageCode;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        title: Text(
          AppLocalizations.of(context)!.appName,
          style: TextStyle(color: _goldColor),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text(
                "English",
                style: TextStyle(color: Colors.white),
              ),
              trailing: currentLang == 'en'
                  ? Icon(Icons.check, color: _goldColor)
                  : null,
              onTap: () {
                provider.setLocale(const Locale('en', ''));
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text(
                "العربية",
                style: TextStyle(color: Colors.white),
              ),
              trailing: currentLang == 'ar'
                  ? Icon(Icons.check, color: _goldColor)
                  : null,
              onTap: () {
                provider.setLocale(const Locale('ar', ''));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // الوصول إلى نصوص الترجمة
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: _darkBackground,
      appBar: AppBar(
        title: Text(localizations.settings), // استخدام نص مترجم لعنوان الشاشة
        backgroundColor: Colors.transparent,
        foregroundColor: _goldColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // 1. كارت المعلومات الشخصية
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2C),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _goldColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: _goldColor,
                    child: const Icon(
                      Icons.person,
                      size: 35,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        userEmail,
                        style: TextStyle(color: Colors.grey[400], fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // 2. قائمة الخيارات
            _buildSettingsItem(
              Icons.person_outline,
              localizations.editProfile, // نص مترجم
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditProfileScreen(),
                  ),
                );
              },
            ),

            _buildSettingsItem(
              Icons.lock_outline,
              localizations.changePassword, // نص مترجم
              () {
                // 🔥🔥 التعديل: تفعيل التوجيه إلى شاشة تغيير كلمة المرور 🔥🔥
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChangePasswordScreen(),
                  ),
                );
              },
            ),

            // 🔥🔥 ربط زر اللغة بالدالة الجديدة 🔥🔥
            _buildSettingsItem(
              Icons.language,
              localizations.changeLanguage, // نص مترجم
              () => _showLanguageDialog(context),
            ),

            _buildSettingsItem(
              Icons.notifications_outlined,
              localizations.notifications,
              () {
                // Toggle Switch
              },
            ),

            const SizedBox(height: 20),
            Divider(color: Colors.grey[800]),
            const SizedBox(height: 20),

            _buildSettingsItem(
              Icons.logout,
              localizations.logout,
              _logout,
              isDestructive: true,
            ), // نص مترجم
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem(
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    // هذه الدالة تم استخدامها سابقاً
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDestructive
              ? Colors.red.withOpacity(0.1)
              : const Color(0xFF2C2C2C),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isDestructive ? Colors.red : _goldColor,
          size: 22,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: Colors.grey[600],
        size: 16,
      ),
    );
  }
}
