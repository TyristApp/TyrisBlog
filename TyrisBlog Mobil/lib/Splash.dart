import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'ApiClasses/userAPI.dart';
import 'MenuScreen.dart';
import 'const/AppColors.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkAppInfo();
  }

  Future<void> checkAppInfo() async {
    final String apiUrl = 'http://10.0.2.2:8000/api/get-app-info/';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final bool requiredUpdate = data['UpdateRequired'] ?? false;
      final bool inCare = data['InCare'] ?? false;

      if (inCare) {
        // Incase
        _showAlertDialog(
          title: 'Bakım Arası',
          content: 'Uygulama şu anda bakımda. Lütfen daha sonra tekrar deneyin.',
          onConfirm: () {
            // close app
            SystemNavigator.pop();
          },
        );
      } else if (requiredUpdate) {
        // Update Ststus
        _showAlertDialog(
          title: 'Güncelleme Gerekli',
          content: 'Yeni bir güncelleme mevcut. Güncelleme işlemini gerçekleştirmelisiniz.',
          onConfirm: () {
            //Close app
            SystemNavigator.pop();
          },
        );
      } else {
        // Main Screen
        _navigateToNextScreen();
      }
    } else {
      _showAlertDialog(
        title: 'Hata',
        content: 'Uygulama bilgilerini alırken bir hata oluştu. Lütfen tekrar deneyin.',
        onConfirm: () {
          // Main Screen
          _navigateToNextScreen();
        },
      );
    }
  }

  void _showAlertDialog({
    required String title,
    required String content,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title, style: TextStyle(color: AppColors.white)),
          content: Text(content, style: TextStyle(color: AppColors.white)),
          backgroundColor: AppColors.SoftGray,
          actions: <Widget>[
            TextButton(
              child: Text('Tamam', style: TextStyle(color: AppColors.white)),
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
            ),
          ],
        );
      },
    );
  }

  void _navigateToNextScreen() {
    Future.delayed(Duration(seconds: 2), () async {
      var user = UserApi();
      if (await user.autologin()) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => MenuScreen()),
              (Route<dynamic> route) => false, // Bu koşul tüm önceki rotaları siler
        );
      } else {
        Navigator.of(context).pushReplacementNamed('/mainmenuscreen');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('assets/images/tyristapp.png', width: 150, height: 150),
            SizedBox(height: 20),
            Text(
              'TyrisBlog',
              style: TextStyle(
                fontSize: 24,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                color: AppColors.Greenlogo,
              ),
            ),
            Text(
              'TyristApp',
              style: TextStyle(
                fontSize: 19,
                fontFamily: 'Poppins',
                color: AppColors.DarkBlueLogo,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
