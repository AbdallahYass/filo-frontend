// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'قائمة فيلو';

  @override
  String get settings => 'الإعدادات';

  @override
  String get editProfile => 'تعديل الملف الشخصي';

  @override
  String get changePassword => 'تغيير كلمة المرور';

  @override
  String get changeLanguage => 'تغيير اللغة';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get welcomeMessage => 'أهلاً بك مجدداً!';

  @override
  String get noInternetConnection => 'لا يوجد اتصال بالإنترنت';

  @override
  String get checkNetworkMessage => 'يرجى التحقق من الشبكة والمحاولة مرة أخرى.';

  @override
  String get skip => 'تخطي';
}
