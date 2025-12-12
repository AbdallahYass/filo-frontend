import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // 👈 Provider
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'l10n/locale_provider.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    ChangeNotifierProvider(
      create: (context) => LocaleProvider(),
      child: const FiloMenuApp(),
    ),
  );
}

class FiloMenuApp extends StatelessWidget {
  const FiloMenuApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 2. قراءة كائن اللغة من الـ Provider (في كل مرة يتغير فيها، يعيد بناء هذا الـ Widget)
    final localeProvider = Provider.of<LocaleProvider>(context);

    return MaterialApp(
      title: 'Filo Menu',
      debugShowCheckedModeBanner: false,

      // 🔥 تعيين اللغة المفروضة من الـ Provider 🔥
      locale: localeProvider.locale,

      // 🚩 يجب أن تبقى هذه الإعدادات لتحديد كيفية التعامل مع اللغات
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', ''), Locale('ar', '')],

      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        primaryColor: Colors.black,
      ),
      home: SplashScreen(),
    );
  }
}
