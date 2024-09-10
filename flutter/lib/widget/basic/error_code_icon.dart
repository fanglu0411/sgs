import 'package:flutter/material.dart';
import 'package:flutter_smart_genome/widget/basic/svg_icons.dart';
import 'package:flutter_svg/flutter_svg.dart';

final Map errorCodeSvgMap = {
  500: icon500,
  404: icon404,
};

class ErrorCodeIcon extends StatelessWidget {
  final Size size;
  final int code;
  final Color? color;

  const ErrorCodeIcon({super.key, required this.code, this.size = const Size(48, 48), this.color});

  @override
  Widget build(BuildContext context) {
    String icon = errorCodeSvgMap[code] ?? iconError;
    Color color = this.color ?? Theme.of(context).textTheme.bodyMedium!.color!;
    return SvgPicture.string(icon, width: size.width, height: size.height, colorFilter: ColorFilter.mode(color, BlendMode.srcIn));
  }
}