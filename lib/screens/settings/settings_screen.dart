// lib/screens/settings_screen.dart

// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import '/l10n/app_localizations.dart';
import '../l10n/locale_provider.dart';
import 'auth/login_screen.dart';
import 'edit_profile_screen.dart';
import 'change_password_screen.dart';
import 'address_management/address_list_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String userName = "Guest";
  String userEmail = "Login Required";
  final Color _goldColor = const Color(0xFFC5A028);
  final Color _darkBackground = const Color(0xFF1A1A1A);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userData = prefs.getString('user');

    if (userData != null) {
      var userMap = jsonDecode(userData);
      if (mounted) {
        setState(() {
          userName = userMap['name'] ?? "User";
          userEmail = userMap['email'] ?? "No Email";
        });
      }
    } else {
      if (mounted) {
        setState(() {
          userName = "Guest";
          userEmail = "Login Required";
        });
      }
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

  // 🔥🔥 الدالة الجديدة: عرض ديالوج التأكيد 🔥🔥
  void _showLogoutConfirmationDialog(AppLocalizations localizations) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        title: Text(
          localizations.logoutConfirmationTitle, // نص مترجم: تأكيد تسجيل الخروج
          style: TextStyle(color: _goldColor, fontWeight: FontWeight.bold),
        ),
        content: Text(
          localizations.logoutConfirmationMessage, // نص مترجم: هل أنت متأكد؟
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          // زر الإلغاء (Cancel)
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              localizations.cancelButton, // نص مترجم: إلغاء
              style: TextStyle(color: Colors.grey[500]),
            ),
          ),
          // زر التأكيد (Logout)
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // إغلاق الديالوج
              _logout(); // تنفيذ عملية تسجيل الخروج الفعلية
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(
              localizations.logout, // نص مترجم: تسجيل الخروج
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final provider = Provider.of<LocaleProvider>(context, listen: false);
    final currentLang = provider.locale.languageCode;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        title: Text(localizations.appName, style: TextStyle(color: _goldColor)),
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
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: _darkBackground,
      appBar: AppBar(
        title: Text(localizations.settings),
        backgroundColor: Colors.transparent,
        foregroundColor: _goldColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: WillPopScope(
          onWillPop: () async {
            _loadUserData();
            return true;
          },
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
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // 2. قائمة الخيارات
              _buildSettingsItem(
                Icons.location_on_outlined,
                localizations.addressesTitle,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddressListScreen(),
                    ),
                  );
                },
              ),

              _buildSettingsItem(
                Icons.person_outline,
                localizations.editProfile,
                () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditProfileScreen(),
                    ),
                  );
                  _loadUserData();
                },
              ),

              _buildSettingsItem(
                Icons.lock_outline,
                localizations.changePassword,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ChangePasswordScreen(),
                    ),
                  );
                },
              ),

              _buildSettingsItem(
                Icons.language,
                localizations.changeLanguage,
                () => _showLanguageDialog(context),
              ),

              _buildSettingsItem(
                Icons.notifications_outlined,
                localizations.notifications,
                () {
                  // Toggle Switch Placeholder
                },
              ),

              const SizedBox(height: 20),
              Divider(color: Colors.grey[800]),
              const SizedBox(height: 20),

              _buildSettingsItem(
                Icons.logout,
                localizations.logout,
                // 🔥🔥 ربط زر الخروج بدالة التأكيد 🔥🔥
                () => _showLogoutConfirmationDialog(localizations),
                isDestructive: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // دالة مساعدة
  Widget _buildSettingsItem(
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
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
