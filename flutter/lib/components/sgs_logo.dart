import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
// import 'package:jovial_svg/jovial_svg.dart';

class SgsLogo extends StatelessWidget {
  final double fontSize;
  final Color? color;
  final Color? backgroundColor;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;

  SgsLogo({
    Key? key,
    this.fontSize = 18,
    this.color,
    this.backgroundColor,
    this.padding = EdgeInsets.zero,
    this.borderRadius = const BorderRadius.only(
      topRight: Radius.circular(10),
      bottomLeft: Radius.circular(10),
      topLeft: Radius.circular(3),
      bottomRight: Radius.circular(3),
    ),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // bool _dark = Theme.of(context).brightness == Brightness.dark;
    var defColor = Theme.of(context).colorScheme.primary;
    Widget logo = DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        // borderRadius: BorderRadius.only(
        //   topRight: Radius.circular(10),
        //   bottomLeft: Radius.circular(10),
        //   topLeft: Radius.circular(3),
        //   bottomRight: Radius.circular(3),
        // ),
        // border: Border.all(
        //   color: color ?? defColor,
        //   width: 2,
        // ),
      ),
      child: CustomPaint(
        painter: LogoBackgroundPainter(
          color: color ?? defColor,
          radius: borderRadius,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Text(
            'SGS',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
              color: Colors.white,
              // fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ),
    );
    logo = Container(
      width: fontSize * 2,
      height: fontSize * 2,
      decoration: BoxDecoration(
        color: backgroundColor ?? defColor,
        borderRadius: BorderRadius.circular(fontSize * 2 * .22),
      ),
      alignment: Alignment.center,
      child: SvgPicture.asset(
        'assets/images/sgs_logo.svg',
        width: fontSize * 2 * .65,
        height: fontSize * 2 * .65,
        colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
      ),
    );
    logo = Padding(padding: padding, child: logo);
    return logo;
  }
}

class LogoBackgroundPainter extends CustomPainter {
  Color color;
  BorderRadius radius;

  Paint? _paint;
  double space = 1.5;

  LogoBackgroundPainter({
    required this.color,
    required this.radius,
  }) {
    _paint = Paint()..color = color;
  }

  @override
  void paint(Canvas canvas, Size size) {
    double sizeWidth = size.width / 2 - space / 2;
    Rect leftRect = Rect.fromLTWH(0, 0, sizeWidth, size.height);
    Rect rightRect = Rect.fromLTWH(size.width / 2 + space / 2, 0, sizeWidth, size.height);

    RRect rl = RRect.fromRectAndCorners(leftRect, topLeft: radius.topLeft, bottomLeft: radius.bottomLeft);
    RRect rr = RRect.fromRectAndCorners(rightRect, topRight: radius.topRight, bottomRight: radius.bottomRight);

    canvas.drawRRect(rl, _paint!);
    canvas.drawRRect(rr, _paint!);
  }

  @override
  bool shouldRepaint(covariant LogoBackgroundPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
