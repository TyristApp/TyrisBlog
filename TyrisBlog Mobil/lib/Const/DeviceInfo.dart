import 'package:flutter/widgets.dart';

class DeviceInfo {
  static double width = 0.0;
  static double height = 0.0;

  static void setDeviceInfo(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    width = mediaQuery.size.width;
    height = mediaQuery.size.height;
  }
}
