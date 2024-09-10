import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';

class FixedColorPicker extends StatelessWidget {
  const FixedColorPicker({
    required this.pickerColor,
    required this.onColorChanged,
    this.enableAlpha = true,
    this.showLabel = true,
    this.displayThumbColor = false,
    this.colorPickerWidth = 300.0,
    this.pickerAreaHeightPercent = 1.0,
    this.pickerAreaBorderRadius = const BorderRadius.all(Radius.zero),
  });

  final Color pickerColor;
  final ValueChanged<Color> onColorChanged;
  final bool enableAlpha;
  final bool showLabel;
  final bool displayThumbColor;
  final double colorPickerWidth;
  final double pickerAreaHeightPercent;
  final BorderRadius pickerAreaBorderRadius;

  @override
  Widget build(BuildContext context) {
    return ColorPicker(
      color: pickerColor,
      mainAxisSize: MainAxisSize.min,
      showColorName: false,
      showMaterialName: false,
      showRecentColors: true,
      enableShadesSelection: false,
      enableOpacity: true,
      enableTonalPalette: false,
      // wheelWidth: 10,
      width: 30,
      height: 30,
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      // title: Text('Color Picker', style: Theme.of(context).textTheme.titleMedium),
      opacityTrackHeight: 30,
      // wheelDiameter: 220,
      showColorCode: true,
      pickersEnabled: {
        ColorPickerType.both: false,
        ColorPickerType.primary: false,
        ColorPickerType.accent: false,
        ColorPickerType.bw: false,
        ColorPickerType.custom: false,
        ColorPickerType.customSecondary: false,
        ColorPickerType.wheel: true,
      },
      onColorChanged: onColorChanged,
      copyPasteBehavior: ColorPickerCopyPasteBehavior(
        copyFormat: ColorPickerCopyFormat.dartCode,
        pasteButton: true,
        copyButton: true,
        editUsesParsedPaste: true,
        editFieldCopyButton: true,
      ),
    );
  }
}
