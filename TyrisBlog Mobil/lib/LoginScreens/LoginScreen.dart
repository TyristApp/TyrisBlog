import 'package:tyrisblog/ApiClasses/userAPI.dart';
import 'package:flutter/material.dart';
import 'package:tyrisblog/Const/AppColors.dart';
import 'package:tyrisblog/Const/DeviceInfo.dart';
import 'package:tyrisblog/CustomWidgets/CustomButton.dart';
import 'package:tyrisblog/CustomWidgets/InputText.dart';
import '../MenuScreen.dart';
import 'MainMenuScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController email_controller = TextEditingController();
  final TextEditingController password_controller = TextEditingController();
  String mesaj = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomPaint(
            painter: BackgroundPainter(),
            size: Size.infinite,
          ),
          SingleChildScrollView(
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(
                          vertical: (DeviceInfo.width / 20)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          IconButton(
                              icon: Icon(Icons.arrow_back_ios),
                              iconSize: 40,
                              color: AppColors.secondred,
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MainMenuScreen()),
                                );
                              }),
                          Text(
                            "Giriş Yap",
                            style: TextStyle(
                              color: AppColors.Greenlogo,
                              fontFamily: 'Poppins',
                              fontSize: (DeviceInfo.width / 15).clamp(15, 50),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: (DeviceInfo.height / 5),
                    ),
                    InputText(
                      placeholder: 'Kullanıcı adı',
                      controller: email_controller,
                      width: (DeviceInfo.width / 1.5).clamp(250, 400),
                      fillColor: AppColors.white,
                      hintColor: AppColors.black,
                      borderColor: AppColors.Greenlogo,
                      focusedBorderColor: AppColors.DarkBlueLogo,
                    ),
                    SizedBox(
                      height: (DeviceInfo.height / 80).clamp(10, 40),
                    ),
                    InputText(
                      placeholder: 'Şifre',
                      controller: password_controller,
                      isObscure: true,
                      width: (DeviceInfo.width / 1.5).clamp(250, 400),
                      fillColor: AppColors.white,
                      hintColor: AppColors.black,
                      borderColor: AppColors.Greenlogo,
                      focusedBorderColor: AppColors.DarkBlueLogo,
                    ),
                    SizedBox(
                      height: (DeviceInfo.height / 8).clamp(30, 100),
                    ),
                    Text(mesaj),
                    CustomButton(
                      text: "Giriş Yap",
                      color: AppColors.Greenlogo,
                      onPressed: () async {
                        final email = email_controller.text.trim();
                        final password = password_controller.text.trim();

                        var loginclass = UserApi();
                        sonuc loginmi = await loginclass.login(email, password);

                        if (loginmi.girisMi) {
                          setState(() {
                            mesaj = loginmi.mesaj;
                          });

                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => MenuScreen()),
                            (Route<dynamic> route) => false,
                          );
                        } else {
                          setState(() {
                            mesaj = loginmi.mesaj;
                          });
                        }
                      },
                      width: (DeviceInfo.width / 2.6).clamp(240, 400),
                    ),
                  ],
                ),
              ),
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
    final paint = Paint();
    paint.color = AppColors.DarkBlueLogo;
    paint.style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.3);
    path.quadraticBezierTo(
        size.width * 0.5, size.height * 0.4, size.width, size.height * 0.3);
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
