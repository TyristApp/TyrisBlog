import 'package:flutter/services.dart';
import 'package:tyrisblog/LoginScreens/MainMenuScreen.dart';
import 'package:tyrisblog/LoginScreens/RegisterScreen.dart';
import 'package:flutter/material.dart';
import 'package:tyrisblog/Splash.dart';
import 'Const/AppColors.dart';
import 'Const/DeviceInfo.dart';
import 'LoginScreens/LoginScreen.dart';
import 'MenuScreen.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: AppColors.DarkBlueLogo,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(FirstPage());
}

class FirstPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    DeviceInfo.setDeviceInfo(context);
    return MaterialApp(
      title: 'TyrisBlog',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.DarkBlueLogo),
          useMaterial3: true,
          fontFamily: 'Poppins'),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/mainmenuscreen': (context) => MainMenuScreen(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/menuscreen': (context) => MenuScreen(),
      },
    );
  }
}
