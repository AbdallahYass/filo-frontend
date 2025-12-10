// lib/screens/main_wrapper.dart

// ignore_for_file: file_names, deprecated_member_use

import 'package:flutter/material.dart';
import '/l10n/app_localizations.dart';
import 'vendor_categories_screen.dart';
import 'settings_screen.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;
  final Color _goldColor = const Color(0xFFC5A028);
  final Color _darkColor = const Color(0xFF1A1A1A);

  // 1. استخدام GlobalKey لكل تبويب لتخزين حالة التنقل الخاصة به
  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(), // Home/Categories
    GlobalKey<NavigatorState>(), // Settings
  ];

  // 2. قائمة الشاشات الجذرية (Root Screens)
  final List<Widget> _pages = const [
    VendorCategoriesScreen(),
    SettingsScreen(),
  ];

  // دالة لمعالجة زر الرجوع (Back Button)
  Future<bool> _onWillPop() async {
    // إذا كان هناك تاريخ تنقل داخل التبويب الحالي، قم بالرجوع خطوة واحدة
    if (_navigatorKeys[_currentIndex].currentState?.canPop() ?? false) {
      _navigatorKeys[_currentIndex].currentState?.pop();
      return false;
    }
    // وإلا، إذا كنا في التبويب الأول (Home)، نترك Flutter يغلق التطبيق
    else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: _darkColor,
        // 🔥 Body يحتوي على IndexedStack لتبديل النواة (Navigators)
        body: IndexedStack(
          index: _currentIndex,
          children: _pages.asMap().entries.map((entry) {
            int index = entry.key;
            Widget page = entry.value;

            return _buildOffstageNavigator(page, index); // بناء النواة الداخلية
          }).toList(),
        ),

        // 🔥 شريط التنقل السفلي الثابت 🔥
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: _darkColor,
          selectedItemColor: _goldColor,
          unselectedItemColor: Colors.grey,
          currentIndex: _currentIndex,
          onTap: (index) {
            // إذا كنا بالفعل في التبويب، نرجع للجذر (Pop to root)
            if (_currentIndex == index) {
              _navigatorKeys[index].currentState?.popUntil(
                (route) => route.isFirst,
              );
            }
            setState(() {
              _currentIndex = index;
            });
          },
          showSelectedLabels: false,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              label: 'Categories',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }

  // 3. دالة لبناء Navigator مخصص لكل تبويب
  Widget _buildOffstageNavigator(Widget page, int index) {
    return Offstage(
      offstage: _currentIndex != index,
      child: Navigator(
        key: _navigatorKeys[index],
        onGenerateRoute: (routeSettings) {
          return MaterialPageRoute(
            builder: (context) => page, // الصفحة الجذرية (Root)
          );
        },
      ),
    );
  }
}
