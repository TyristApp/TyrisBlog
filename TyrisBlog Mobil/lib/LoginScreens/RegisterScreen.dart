import 'package:tyrisblog/ApiClasses/userAPI.dart';
import 'package:flutter/material.dart';
import 'package:tyrisblog/Const/AppColors.dart';
import 'package:tyrisblog/Const/DeviceInfo.dart';
import 'package:tyrisblog/CustomWidgets/InputText.dart';
import 'package:tyrisblog/CustomWidgets/CustomButton.dart';
import '../MenuScreen.dart';
import 'MainMenuScreen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController name_controller = TextEditingController();
  final TextEditingController surname_controller = TextEditingController();
  final TextEditingController email_controller = TextEditingController();
  final TextEditingController username_controller = TextEditingController();
  final TextEditingController password_controller = TextEditingController();
  final TextEditingController confirm_password_controller =
      TextEditingController();
  String uyari = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [

          CustomPaint(
            painter: BackgroundPainter(),
            size: Size.infinite,
          ),
          SafeArea(
            child: SingleChildScrollView(
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
                            "Kayıt Ol",
                            style: TextStyle(
                              color: AppColors.DarkBlueLogo,
                              fontFamily: 'Poppins',
                              fontSize: (DeviceInfo.width / 15).clamp(15, 50),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: (DeviceInfo.height / 30),
                    ),
                    InputText(
                      placeholder: 'İsim',
                      controller: name_controller,
                      width: (DeviceInfo.width / 1.5).clamp(250, 400),
                      fillColor: AppColors.white,
                      hintColor: AppColors.black,
                      borderColor: AppColors.Greenlogo,
                      focusedBorderColor: AppColors.DarkBlueLogo,
                    ),
                    SizedBox(
                      height: (DeviceInfo.height / 80).clamp(10, 20),
                    ),
                    InputText(
                      placeholder: 'Soyisim',
                      controller: surname_controller,
                      width: (DeviceInfo.width / 1.5).clamp(250, 400),
                      fillColor: AppColors.white,
                      hintColor: AppColors.black,
                      borderColor: AppColors.Greenlogo,
                      focusedBorderColor: AppColors.DarkBlueLogo,
                    ),
                    SizedBox(
                      height: (DeviceInfo.height / 80).clamp(10, 20),
                    ),
                    InputText(
                      placeholder: 'Kullanıcı Adı',
                      controller: username_controller,
                      width: (DeviceInfo.width / 1.5).clamp(250, 400),
                      fillColor: AppColors.white,
                      hintColor: AppColors.black,
                      borderColor: AppColors.Greenlogo,
                      focusedBorderColor: AppColors.DarkBlueLogo,
                    ),
                    SizedBox(
                      height: (DeviceInfo.height / 80).clamp(10, 20),
                    ),
                    InputText(
                      placeholder: 'E-mail',
                      controller: email_controller,
                      keyboardType: TextInputType.emailAddress,
                      width: (DeviceInfo.width / 1.5).clamp(250, 400),
                      fillColor: AppColors.white,
                      hintColor: AppColors.black,
                      borderColor: AppColors.Greenlogo,
                      focusedBorderColor: AppColors.DarkBlueLogo,
                    ),
                    SizedBox(
                      height: (DeviceInfo.height / 80).clamp(10, 20),
                    ),
                    SizedBox(
                      height: (DeviceInfo.height / 80).clamp(10, 20),
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
                      height: (DeviceInfo.height / 80).clamp(10, 20),
                    ),
                    InputText(
                      placeholder: 'Şifre Tekrar',
                      controller: confirm_password_controller,
                      isObscure: true,
                      width: (DeviceInfo.width / 1.5).clamp(250, 400),
                      fillColor: AppColors.white,
                      hintColor: AppColors.black,
                      borderColor: AppColors.Greenlogo,
                      focusedBorderColor: AppColors.DarkBlueLogo,
                    ),
                    SizedBox(
                      height: (DeviceInfo.height / 10).clamp(30, 80),
                    ),
                    Text(uyari),
                    CustomButton(
                      text: "Kayıt Ol",
                      color: AppColors.Greenlogo,
                      onPressed: () async {
                        final email = email_controller.text.trim();
                        final name = name_controller.text.trim();
                        final surname = surname_controller.text.trim();
                        final username = username_controller.text.trim();
                        final password = password_controller.text.trim();
                        final confirmPassword =
                            confirm_password_controller.text.trim();

                        if (password == confirmPassword) {
                          var kayitclass = UserApi();
                          String sonuc = await kayitclass.register(
                              email, name, surname, username, password);
                          if (sonuc == "Kullanici olusturuldu") {
                            setState(() {
                              uyari = sonuc;
                            });

                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (context) => MenuScreen()),
                              (Route<dynamic> route) =>
                                  false,
                            );
                          } else {
                            setState(() {
                              uyari = sonuc;
                            });
                          }
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
    paint.color = AppColors.Greenlogo;
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
