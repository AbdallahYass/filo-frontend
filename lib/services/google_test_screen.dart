import 'package:flutter/material.dart';
// لاحظ هنا: أضفنا "as auth" لنميز المكتبة
import 'package:google_sign_in/google_sign_in.dart' as auth;

class TestGoogleScreen extends StatefulWidget {
  @override
  _TestGoogleScreenState createState() => _TestGoogleScreenState();
}

class _TestGoogleScreenState extends State<TestGoogleScreen> {
  // الآن نستخدم "auth." قبل اسم الكلاس لنؤكد أننا نريد المكتبة
  final auth.GoogleSignIn _googleSignIn = auth.GoogleSignIn();

  String _statusText = "اضغط الزر لتجربة الدخول";

  Future<void> _handleSignIn() async {
    try {
      // وهنا أيضاً نستخدم auth
      final auth.GoogleSignInAccount? user = await _googleSignIn.signIn();

      if (user == null) {
        setState(() => _statusText = "تم إلغاء العملية");
        return;
      }

      final auth.GoogleSignInAuthentication authentication =
          await user.authentication;

      print("====================================");
      print("TOKEN: ${authentication.idToken}");
      print("====================================");

      setState(() {
        _statusText = "نجح الدخول!\nأهلاً: ${user.displayName}";
      });
    } catch (error) {
      print(error);
      setState(() => _statusText = "حدث خطأ: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("تجربة جوجل")),
      body: Center(
        child: ElevatedButton(
          onPressed: _handleSignIn,
          child: Text("دخول عبر جوجل"),
        ),
      ),
    );
  }
}
