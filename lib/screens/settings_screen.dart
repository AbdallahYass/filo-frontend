// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'auth/login_screen.dart';
import 'edit_profile_screen.dart'; // سننشئها بالخطوة التالية

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

  // تحميل البيانات من الذاكرة المحلية
  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userData = prefs.getString(
      'user',
    ); // تأكد أنك خزنت الـ user object عند اللوجن

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
    await prefs.clear(); // مسح التوكن والبيانات

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkBackground,
      appBar: AppBar(
        title: const Text("Settings"),
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
                    child: Icon(Icons.person, size: 35, color: Colors.black),
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
            _buildSettingsItem(Icons.person_outline, "Edit Profile", () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfileScreen(),
                ),
              );
            }),

            _buildSettingsItem(Icons.lock_outline, "Change Password", () {
              // TODO: Navigate to Change Password Screen
            }),

            _buildSettingsItem(Icons.language, "Language", () {
              // TODO: Show Language Dialog
            }),

            _buildSettingsItem(
              Icons.notifications_outlined,
              "Notifications",
              () {
                // Toggle Switch
              },
            ),

            const SizedBox(height: 20),
            Divider(color: Colors.grey[800]),
            const SizedBox(height: 20),

            _buildSettingsItem(
              Icons.logout,
              "Logout",
              _logout,
              isDestructive: true,
            ),
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
