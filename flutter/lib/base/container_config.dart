import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

const MONOSPACED_FONT = 'Consolas';
const List<String> MONOSPACED_FONT_BACK = [
  'Monospace',
  'Inconsolata',
  'Consolas',
  'PT Mono',
  'Sans Mono',
  'Droid Sans Mono',
  'Melo',
  'Monaco',
  'courier new',
  'courier',
];

BoxDecoration defaultContainerDecoration(BuildContext context, [bool showColor = true]) {
  return BoxDecoration(
    border: defaultContainerBorder(context),
    borderRadius: defaultContainerRadius,
    color: showColor ? defaultContainerColor(context) : null,
  );
}

Color defaultContainerColor(BuildContext context) {
  bool dark = Theme.of(context).brightness == Brightness.dark;
  return dark ? Colors.black12 : Colors.white;
}

const BorderRadius defaultContainerRadius = BorderRadius.all(Radius.circular(2));

Border defaultContainerBorder(BuildContext context) {
  bool dark = Theme.of(context).brightness == Brightness.dark;
  return dark ? Border.all(color: Colors.black54) : Border.all(color: Colors.grey[300]!);
}

ShapeBorder modelShape({BuildContext? context, Color? color, double radius = 10, bool bottomSheet = false}) {
//  if (kIsWeb) return null;
  return RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius));
  Radius _radius = Radius.circular(radius);
  Color? _color = color ??
      (context == null
          ? null
          : Theme.of(context).brightness == Brightness.dark
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.primary);

  return RoundedRectangleBorder(
    borderRadius: bottomSheet
        ? BorderRadius.only(topRight: _radius, topLeft: _radius) //
        : BorderRadius.only(topRight: _radius, bottomLeft: _radius, bottomRight: _radius),
    side: _color != null ? BorderSide(color: _color, width: .5) : BorderSide.none,
  );
  // return BeveledRectangleBorder(
  //   borderRadius: bottomSheet
  //       ? BorderRadius.only(topRight: _radius, topLeft: _radius) //
  //       : BorderRadius.only(topRight: _radius, bottomLeft: _radius),
  //   side: _color != null ? BorderSide(color: _color, width: .5) : BorderSide.none,
  // );
}

ShapeBorder? sliderShape({Color? color, double radius = 12}) {
  if (kIsWeb) return null;
  return BeveledRectangleBorder(
    borderRadius: BorderRadius.only(topLeft: Radius.circular(radius)),
    side: color != null ? BorderSide(color: color) : BorderSide.none,
  );
}

OutlinedBorder? buttonShape([double radius = 8]) {
  if (kIsWeb) return null;
  return RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius));
  // return BeveledRectangleBorder(
  //   borderRadius: BorderRadius.only(
  //     topRight: Radius.circular(radius),
  //     bottomLeft: Radius.circular(radius),
  //   ),
  // );
}

InputBorder inputBorder() {
  if (kIsWeb) return OutlineInputBorder();
  return OutlineInputBorder();
  // return CutCornerInputBorder(
  //   borderRadius: BorderRadius.only(
  //     topRight: Radius.circular(8),
  //     bottomLeft: Radius.circular(8),
  //   ),
  // );
}
