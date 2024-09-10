import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

Widget CustomSpin({double size = 24, Color? color}) {
  return SizedBox(width: size, height: size, child: SpinKitChasingDots(size: size, color: color));
}
