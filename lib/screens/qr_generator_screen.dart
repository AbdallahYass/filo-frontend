// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRGeneratorScreen extends StatefulWidget {
  const QRGeneratorScreen({super.key});

  @override
  State<QRGeneratorScreen> createState() => _QRGeneratorScreenState();
}

class _QRGeneratorScreenState extends State<QRGeneratorScreen> {
  final TextEditingController _controller = TextEditingController();
  String _dataToGenerate = ""; // البيانات التي سنحولها لـ QR

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Generate Table QR',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Color(0xFFC5A028)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            // 1. منطقة عرض الـ QR Code
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: _dataToGenerate.isEmpty
                  ? const SizedBox(
                      height: 200,
                      width: 200,
                      child: Center(
                        child: Text(
                          "Enter table number to generate QR",
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : QrImageView(
                      data:
                          _dataToGenerate, // 👈 هنا البيانات التي ستتحول لصورة
                      version: QrVersions.auto,
                      size: 250.0,
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                    ),
            ),

            const SizedBox(height: 40),

            // 2. حقل إدخال رقم الطاولة
            TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number, // لوحة مفاتيح أرقام
              decoration: InputDecoration(
                hintText: "Enter Table Number (e.g., 5)",
                hintStyle: TextStyle(color: Colors.grey[600]),
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(
                  Icons.table_restaurant,
                  color: Color(0xFFC5A028),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 3. زر التوليد
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    // 👇👇👇 التغيير هنا: نصنع رابطاً بدلاً من رقم مجرد
                    // هام: استبدل 192.168.1.XX برقم الـ IP الخاص بجهازك
                    String myIP = "192.168.1.26";
                    String tableNum = _controller.text;

                    // إذا كان الحقل فارغاً لا نفعل شيئاً
                    if (tableNum.isEmpty) return;

                    // الرابط النهائي الذي سيفتح نسخة الويب
                    // المنفذ 8080 هو المنفذ الافتراضي لـ flutter web server
                    _dataToGenerate = "http://$myIP:8081/?table=$tableNum";
                  });

                  // إخفاء لوحة المفاتيح
                  FocusScope.of(context).unfocus();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC5A028),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  "Generate Web QR",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
            const Text(
              "Note: This QR will open the web version on any phone.",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
