import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/base/chinese_colors.dart';
import 'package:flutter_smart_genome/widget/basic/custom_multi_size_layout.dart';
import 'package:responsive_builder/responsive_builder.dart' show DeviceScreenType;

const bool IDE_MODE = true;

const int SIDE_MENU_WIDTH = 260;
const int MOBILE_MAX_WIDTH = 1000;
const int TABLET_MAX_WIDTH = 1680;

const double SIDE_WIDGET_WIDTH = 400;
const double SIDE_WIDGET_WIDTH_SMALL = 300;

const double HORIZONTAL_TOOL_BAR_HEIGHT = 40;

List<Color> ThemeColors3 = chinese_colors.map((e) {
  List rgb = e['RGB'];
  Colors.primaries;
  return Color.fromARGB(255, rgb[0], rgb[1], rgb[2]);
}).toList();

List<MaterialColor> ThemeColors = Colors.primaries;

List<Color> ThemeColors2 = [
  Color(0xffc21f30),
  Color(0xffab372f),
  Color(0xFFE53E3E),
  Color(0xFFDD6B20),
  Color(0xFFD69E2E),
  Color(0xFF38A169),
  Color(0xFF43b244), //鲜绿
  Color(0xFF229453), //孔雀绿
  Color(0xFF207f4c), //薄荷绿
  Color(0xFF61ac85), //淡绿
  Color(0xFF1a6840), //荷叶绿
  Color(0xFF319795),
  Color(0xFF3182CE),
  Color(0xFF5A67D8),
  Color(0xFF805AD5),
  Color(0xFFD53F8C),
];

enum ViewSize {
  mobile,
  small_landscape,
  tablet,
  big_screen,
}

class ScreenUtil {
  static DeviceScreenType? screenType;

  DeviceScreenType getScreenType(BuildContext context) {
    return getDeviceType(MediaQuery.of(context));
  }
}

double? appBarHeight(BuildContext context) {
  ViewSize vs = getViewSize(context);
  // if (vs == ViewSize.tablet) return 40;
  if (vs == ViewSize.big_screen) return kIsWeb ? 40 : 50;
  return null;
}

bool mobilePlatform() {
  return !kIsWeb && (Platform.isAndroid || Platform.isIOS);
}

bool desktopPlatform() {
  return !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);
}

double sideWidth(BuildContext context, [Size? size]) {
  bool small = smallLandscape(context, size);
  return small ? SIDE_WIDGET_WIDTH_SMALL : SIDE_WIDGET_WIDTH;
}

bool smallLandscape(BuildContext context, [Size? size]) {
  var _size = size ?? MediaQuery.of(context).size;
  return _size.height <= 480 && _size.width / _size.height > 1.5;
}

bool portrait(BuildContext context, [Size? size]) {
  var _size = size ?? MediaQuery.of(context).size;
  return _size.width / _size.height <= .65;
}

bool isTablet(BuildContext context, [Size? size]) {
  return ViewSize.tablet == getViewSize(context, size);
}

bool isMobile(BuildContext context, [Size? size]) {
  return ViewSize.mobile == getViewSize(context, size);
}

bool isBigScreen(BuildContext context, [Size? size]) {
  return ViewSize.big_screen == getViewSize(context, size);
}

ViewSize getViewSize(BuildContext context, [Size? size]) {
  var _size = size ?? MediaQuery.of(context).size;
  if (_size.width >= defaultBreakPoints.desktop) {
    return ViewSize.big_screen;
  }
  if (_size.width >= defaultBreakPoints.tablet) {
    return ViewSize.tablet;
  }
  if (_size.width / _size.height > 4 / 3) {
    return ViewSize.small_landscape;
  }
  return ViewSize.mobile;
}
// }