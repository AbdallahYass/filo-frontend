// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Filo Menu';

  @override
  String get settings => 'Settings';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get changePassword => 'Change Password';

  @override
  String get changeLanguage => 'Change Language';

  @override
  String get notifications => 'Notifications';

  @override
  String get logout => 'Logout';

  @override
  String get welcomeMessage => 'Welcome Back!';

  @override
  String get noInternetConnection => 'No Internet Connection';

  @override
  String get checkNetworkMessage => 'Please check your network and try again.';

  @override
  String get skip => 'Skip';
}
