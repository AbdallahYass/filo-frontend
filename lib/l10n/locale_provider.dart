// lib/providers/locale_provider.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  // اللغة الافتراضية للتطبيق
  Locale _locale = const Locale('en', '');

  Locale get locale => _locale;

  // مفتاح تخزين اللغة في الذاكرة المحلية
  static const String _localeKey = 'user_locale';

  LocaleProvider() {
    _loadSavedLocale();
  }

  // 🔥 التحميل: قراءة اللغة المحفوظة عند بدء التطبيق
  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final String? languageCode = prefs.getString(_localeKey);

    // إذا وجدنا لغة محفوظة (ar أو en)، نعتمدها
    if (languageCode != null && languageCode.isNotEmpty) {
      _locale = Locale(languageCode, '');
      // نستخدم notifyListeners لإخبار التطبيق باللغة الافتراضية
      notifyListeners();
    }
  }

  // 🔥 التغيير: دالة تغيير اللغة
  void setLocale(Locale newLocale) async {
    if (newLocale != _locale) {
      _locale = newLocale;
      // حفظ الاختيار الجديد في الذاكرة الدائمة
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, newLocale.languageCode);

      notifyListeners(); // إخبار كل الـ Widgets بإعادة البناء باللغة الجديدة
    }
  }
}
