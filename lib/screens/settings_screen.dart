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
// 🔥🔥 استيراد شاشة العناوين (افترض المسار: lib/screens/address_management/address_list_screen.dart) 🔥🔥
import 'address_management/address_list_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // قيم افتراضية لضمان عدم ظهور "null"
  String userName = "Guest";
  String userEmail = "Login Required";
  final Color _goldColor = const Color(0xFFC5A028);
  final Color _darkBackground = const Color(0xFF1A1A1A);

  @override
  void initState() {
    super.initState();
    // 💡 نستخدم addPostFrameCallback لضمان أن الـ context جاهز وأننا نتابع البيانات
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  // 🔥🔥 دالة تحميل البيانات الأكثر موثوقية 🔥🔥
  Future<void> _loadUserData() async {
    // 1. استخدام المفتاح الموحد 'user'
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userData = prefs.getString('user');

    if (userData != null) {
      var userMap = jsonDecode(userData);
      // 2. استخدام setState بشكل آمن
      if (mounted) {
        setState(() {
          userName = userMap['name'] ?? "User";
          userEmail = userMap['email'] ?? "No Email";
        });
      }
    } else {
      // 3. مسح الحالة إذا لم يكن المستخدم مسجلاً
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

  void _showLanguageDialog(BuildContext context) {
    // الوصول إلى نصوص الترجمة من جديد داخل الدالة
    final localizations = AppLocalizations.of(context)!;

    final provider = Provider.of<LocaleProvider>(context, listen: false);
    final currentLang = provider.locale.languageCode;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        title: Text(
          localizations.appName, // استخدام نص مترجم
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

  // 💡 إبقاء didChangeDependencies فارغاً والاعتماد على _loadUserData بعد pop
  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  // }

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
        // 🔥 WillPopScope يستخدم هنا فقط للـ Back Button في الـ Android/iOS
        child: WillPopScope(
          onWillPop: () async {
            // إعادة تحميل البيانات لمرة واحدة عند الخروج من الشاشة (لتحديث الاسم/الإيميل)
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

              // 🔥🔥 خيار إدارة العناوين الجديد 🔥🔥
              _buildSettingsItem(
                Icons.location_on_outlined,
                localizations.addressesTitle, // عنوان العناوين المترجم
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      // التوجيه إلى شاشة العناوين
                      builder: (context) => const AddressListScreen(),
                    ),
                  );
                },
              ),

              _buildSettingsItem(
                Icons.person_outline,
                localizations.editProfile,
                () async {
                  // استخدام async
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditProfileScreen(),
                    ),
                  );
                  _loadUserData(); // إعادة تحميل البيانات بعد العودة من التعديل
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
                _logout,
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
