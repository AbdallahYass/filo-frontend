// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart'; // تأكد أنك أضفت مكتبة mobile_scanner في pubspec.yaml
import '/l10n/app_localizations.dart'; // 👈 استيراد اللغات
import '../services/cart_service.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  bool isScanned = false; // لمنع المسح المتكرر
  final Color _goldColor = const Color(0xFFC5A028);

  @override
  Widget build(BuildContext context) {
    // 🔥 الوصول لكائن الترجمة 🔥
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          localizations.scanQrTitle, // 👈 نص مترجم
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: _goldColor), // ذهبي
      ),
      body: MobileScanner(
        onDetect: (capture) {
          if (!isScanned) {
            final List<Barcode> barcodes = capture.barcodes;
            for (final barcode in barcodes) {
              if (barcode.rawValue != null) {
                setState(() {
                  isScanned = true; // إيقاف المسح بعد أول قراءة
                });

                String rawValue = barcode.rawValue!;
                String tableNumber = rawValue;

                // إذا كان الكود عبارة عن رابط (مثل الويب)، نستخرج رقم الطاولة منه
                if (rawValue.contains('table=')) {
                  final uri = Uri.parse(rawValue);
                  if (uri.queryParameters.containsKey('table')) {
                    tableNumber = uri.queryParameters['table']!;
                  }
                }

                // 1. حفظ رقم الطاولة
                CartService().setTableNumber(tableNumber);

                // 2. إظهار رسالة نجاح
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      // 🔥 استخدام دالة الترجمة مع المعامل 🔥
                      localizations.tableSetSuccess(tableNumber),
                    ),
                    backgroundColor: Colors.green,
                  ),
                );

                // 3. الخروج من الكاميرا
                Navigator.pop(context);
                break;
              }
            }
          }
        },
      ),
    );
  }
}
