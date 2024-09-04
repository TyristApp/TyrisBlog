import 'package:flutter/material.dart';
import 'package:tyrisblog/Const/AppColors.dart';
import 'package:tyrisblog/Const/DeviceInfo.dart';
import 'package:tyrisblog/CustomWidgets/CustomButton.dart';
import 'LoginScreen.dart';
import 'RegisterScreen.dart';

class MainMenuScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomPaint(
            size: Size.infinite,
            painter: BackgroundPainter(),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(30),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Text(
                      "TyrisBlog",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.DarkBlueLogo,
                        fontWeight: FontWeight.bold,
                        fontSize: (DeviceInfo.width / 10).clamp(40, 90),
                      ),
                    ),
                  ),
                ),
                Spacer(),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CustomButton(
                      text: 'Giriş Yap',
                      color: AppColors.Greenlogo,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LoginScreen()),
                        );
                      },
                      width: (DeviceInfo.width / 2.6).clamp(240, 400),
                    ),
                    SizedBox(height: 20),
                    CustomButton(
                      text: 'Kayıt Ol',
                      color: AppColors.Greenlogo,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RegisterScreen()),
                        );
                      },
                      width: (DeviceInfo.width / 2.6).clamp(240, 400),
                    ),
                  ],
                ),
                Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = AppColors.Greenlogo;
    Path path = Path();
    path.lineTo(0, size.height * 0.3);
    path.quadraticBezierTo(
        size.width / 4, size.height * 0.25, size.width / 2, size.height * 0.3);
    path.quadraticBezierTo(
        3 / 4 * size.width, size.height * 0.35, size.width, size.height * 0.3);
    path.lineTo(size.width, 0);
    path.close();
    canvas.drawPath(path, paint);

    paint.color = AppColors.DarkBlueLogo;
    path = Path();
    path.moveTo(0, size.height);
    path.lineTo(0, size.height * 0.8);
    path.quadraticBezierTo(
        size.width / 4, size.height * 0.85, size.width / 2, size.height * 0.8);
    path.quadraticBezierTo(
        3 / 4 * size.width, size.height * 0.75, size.width, size.height * 0.8);
    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
